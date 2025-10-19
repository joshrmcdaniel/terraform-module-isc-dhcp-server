locals {
  #

  #
  # Subnet Settings
  # ----------------------------------------------------
  #
  # --- Main Subnet ---
  #
  subnet1_subnet      = "192.168.1.0/24"
  subnet1_domain      = "lan"
  subnet1_in_addr     = ["1.168.192"]
  subnet1_in_addr_dns = { for i in local.subnet1_in_addr : i => local.subnet1.gateways[0] }
  subnet1 = {
    network_address = cidrhost(local.subnet1_subnet, 0)
    range_start     = cidrhost(local.subnet1_subnet, 10)
    range_end       = cidrhost(local.subnet1_subnet, 200)
    netmask         = cidrnetmask(local.subnet1_subnet)
    broadcast       = cidrhost(local.subnet1_subnet, -1)
    gateways        = [cidrhost(local.subnet1_subnet, 1)]
    domain_name     = local.subnet1_domain
    domain_search = [
      local.subnet1_domain,
      local.subnet2_domain,
      local.subnet3_domain,
    ]
    reverse_zones = local.subnet1_in_addr
  }
  #
  # --- Subnet2 ---
  #
  subnet2_domain      = "sn2.lan"
  subnet2_subnet      = "192.168.2.0/24"
  subnet2_in_addr     = ["2.168.192"]
  subnet2_in_addr_dns = { for i in local.subnet2_in_addr : i => local.subnet2.gateways[0] }
  subnet2 = {
    network_address = cidrhost(local.subnet2_subnet, 0)
    range_start     = cidrhost(local.subnet2_subnet, 100)
    range_end       = cidrhost(local.subnet2_subnet, 254)
    broadcast       = cidrhost(local.subnet2_subnet, -1)
    netmask         = cidrnetmask(local.subnet2_subnet)
    gateways        = [cidrhost(local.subnet2_subnet, 1)]
    domain_name     = local.subnet2_domain
    domain_search = [
      local.subnet2_domain,
      local.subnet3_domain,
    ]
    reverse_zones = local.subnet2_in_addr
  }
  #
  # --- Subnet3 ---
  #
  subnet3_subnet      = "192.168.3.0/24"
  subnet3_domain      = "sn3.lan"
  subnet3_in_addr     = ["3.168.192"]
  subnet3_in_addr_dns = { for i in local.subnet3_in_addr : i => local.subnet3.gateways[0] }
  subnet3 = {
    network_address = cidrhost(local.subnet3_subnet, 0)
    range_start     = cidrhost(local.subnet3_subnet, 10)
    range_end       = cidrhost(local.subnet3_subnet, 254)
    broadcast       = cidrhost(local.subnet3_subnet, -1)
    netmask         = cidrnetmask(local.subnet3_subnet)
    gateways        = [cidrhost(local.subnet3_subnet, 1)]
    domain_name     = local.subnet3_domain
    domain_search = [
      local.subnet2_domain,
      local.subnet3_domain,
    ]
    reverse_zones = local.subnet3_in_addr
  }

  #
  dhcp_subnets = {
    "Main"      = local.subnet1,
    "Secondary" = local.subnet2,
    "Etc"       = local.subnet3,
  }

}