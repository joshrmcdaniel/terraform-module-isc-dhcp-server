variable "ip_addr" {
  description = "The IP address of the host DHCP server."
  type        = string
}

variable "static_leases" {
  description = "A list of static DHCP leases to create."
  type = list(object({
    mac = string
    ip          = string
  }))
  default = []
  validation {
    condition     = alltrue([for lease in var.static_leases : can(regex("^([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})$", lease.mac))])
    error_message = "One or more provided static lease IP addresses are not valid."
  }
}

variable "user" {
  description = "Username for SSH connection."
  type        = string
  default     = "root"
}

variable "ssh_key" {
  description = "Path to the SSH private key for authentication."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "dhcp_subnets" {
  description = "A map of DHCP subnet configurations."
  type = map(object({
    network_address = string
    range_start     = string
    range_end       = string
    broadcast       = string
    netmask         = string
    gateways         = list(string)
    dns_servers     = optional(list(string))
    use_gateways_as_dns  = optional(bool)
    domain_name     = string
    domain_search   = list(string)
    reverse_zones   = list(string)
    dns_ip          = optional(list(string))
  }))
}

variable "global_settings" {
  description = "Global DHCP settings."
  type = object({
    default_lease_time    = number
    max_lease_time        = number
    authoritative         = bool
    options               = map(any)
    dns_servers           = optional(list(string))
    ddns_updates          = bool
    ddns_domain_name      = string
    ddns_rev_domainname   = string
    ddns_update_style     = string
    ignore_client_updates = bool
  })
  default = {
    authoritative         = true
    default_lease_time    = 600
    max_lease_time        = 7200
    options               = {}
    ddns_updates          = false
    ddns_domain_name      = "lan"
    ddns_update_style     = "none"
    ignore_client_updates = false
    ddns_rev_domainname   = "in-addr.arpa"
  }
}

variable "setup_ddns" {
  description = "Whether to set up DDNS updates."
  type        = bool
  default     = false
}

