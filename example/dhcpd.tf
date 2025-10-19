module "dhcp" {
  source = "../"

  ip_addr      = "192.168.0.1"
  dhcp_subnets = local.dhcp_subnets
  global_settings = {
    authoritative         = true
    default_lease_time    = 600
    max_lease_time        = 7200
    options               = {}
    ddns_updates          = true
    ddns_domain_name      = "lan"
    ddns_update_style     = "interim"
    ignore_client_updates = true
    ddns_rev_domainname   = "in-addr.arpa"
    domain_name           = "lan"

  }
  setup_ddns = true
  ssh_key    = "~/.ssh/id_rsa"
}