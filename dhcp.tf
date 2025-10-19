locals {
  template_vars = {
    subnets         = var.dhcp_subnets
    global_settings = var.global_settings
    static_leases   = var.static_leases
    setup_ddns      = var.setup_ddns
    has_static_leases = var.static_leases != null && length(var.static_leases) > 0
  }
  dhcp_conf = templatefile("${path.module}/files/dhcpd.conf.tftpl", local.template_vars)
}


resource "null_resource" "recreate_dhcpd_conf" {
  triggers = {
    cfg = local.dhcp_conf
  }
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.ssh_key)
    host        = var.ip_addr
    timeout     = "2m"
  }

  provisioner "file" {
    content     = local.dhcp_conf
    destination = "/tmp/dhcpd.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/dhcpd.conf /etc/dhcp/dhcpd.conf",
      "sudo chown root:root /etc/dhcp/dhcpd.conf",
      "sudo systemctl restart isc-dhcp-server",
      "sudo systemctl status isc-dhcp-server --no-pager"
    ]
  }

}