locals {
  dns_conf = templatefile("${path.module}/files/dns.conf.tftpl", {
    subnets = var.dhcp_subnets
  })
  in_addr_dns_map = merge([
    for subnet_name, subnet in var.dhcp_subnets : {
      for r_zone in subnet.reverse_zones : r_zone => subnet.gateways[0]
    }
  ]...)

  flattened_in_addr = flatten([for k1, v1 in var.dhcp_subnets : [for r_zone in v1.reverse_zones : r_zone]])
}


resource "null_resource" "recreate_ddns_conf" {
  count = var.setup_ddns ? 1 : 0
  triggers = {
    cfg = local.dns_conf
  }
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.ssh_key)
    host        = var.ip_addr
    timeout     = "2m"
  }

  provisioner "file" {
    content     = local.dns_conf
    destination = "/tmp/named.conf.local"
  }
  provisioner "remote-exec" {
    inline = [
      "[ -f /etc/bind/ddns-keys.conf ] || sudo tsig-keygen -a hmac-sha256 dhcpupdate | sudo tee /etc/bind/ddns-keys.conf",
      "chown -R root:bind /etc/bind",
      "chmod 750 /etc/bind",
      "sudo named-checkconf /tmp/named.conf.local || exit 1",
      "sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak.$(date +%s) || true",
      "sudo mv /tmp/named.conf.local /etc/bind/named.conf.local",
      "sudo chown root:bind /etc/bind/named.conf.local",
      "sudo chmod 644 /etc/bind/named.conf.local",
      "sudo systemctl restart bind9",
      "sudo systemctl status bind9 --no-pager",
      "sudo systemctl is-active bind9 --quiet || (sudo journalctl -u bind9 -n 50 --no-pager && exit 1)"
    ]
  }
}

resource "null_resource" "forward_zone_db" {
  for_each = var.setup_ddns ? {
    for name, subnet in var.dhcp_subnets :
    name => { domain_name = subnet.domain_name, dns_server_ip = subnet.gateways[0] }
  } : {}
  triggers = {
    domain_name = each.value.domain_name
  }
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.ssh_key)
    host        = var.ip_addr
    timeout     = "2m"
  }
  provisioner "file" {
    content = templatefile(
      "${path.module}/files/dns.db.tftpl",
      {
        domain_name   = each.value.domain_name,
        serial        = formatdate("YYYYMMDD", timestamp()),
        dns_server_ip = each.value.dns_server_ip
      }
    )
    destination = "/tmp/db.${each.value.domain_name}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/db.${each.value.domain_name} /etc/bind/db.${each.value.domain_name}",
      "sudo chown bind:bind /etc/bind/db.${each.value.domain_name}",
      "sudo chmod 664 /etc/bind/db.${each.value.domain_name}",
    ]
  }
}

resource "null_resource" "reverse_zone_db" {
  for_each = var.setup_ddns ? {
    for zone in local.flattened_in_addr :
    zone => { dns_server_ip = local.in_addr_dns_map[zone] }...
  } : {}

  triggers = {
    zone = each.key
  }

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.ssh_key)
    host        = var.ip_addr
    timeout     = "2m"
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/files/dns.db.tftpl",
      {
        domain_name   = "${each.key}.in-addr.arpa",
        serial        = formatdate("YYYYMMDD", timestamp()),
        dns_server_ip = each.value.dns_server_ip
      }
    )
    destination = "/tmp/db.${each.key}.in-addr.arpa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/db.${each.key}.in-addr.arpa /etc/bind/db.${each.key}.in-addr.arpa",
      "sudo chown bind:bind /etc/bind/db.${each.key}.in-addr.arpa",
      "sudo chmod 660 /etc/bind/db.${each.key}.in-addr.arpa.jnl"
    ]
  }
}
