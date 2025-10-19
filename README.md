terraform-module-isc-dhcp-server
==============================================================================

I got _really_ annoyed while attempting to setup DHCP on my pi, so much so I
created a terraform module so any minor changes in the future would be trivial.

Uses null_resources and provisioners to copy the file over along with restarting
isc-dhcp-server.

Assumptions:

- isc-dhcp-server is installed. If [`setup_ddns`](#input\_setup\_ddns) is true,
then install bind9 as well.
- Authentication via an ssh key, and user has NOPASSWD sudo access

I use this on my L3 switch stack, DNS is still pointed at my firewall, but
I domain override the DNS resolver to point at my pi for my internal FQDN.

Example usage can be found under [example](example/)

Requirements
------------------------------------------------------------------------------

| Name | Version |
|------|---------|
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

Providers
------------------------------------------------------------------------------

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |

Resources
------------------------------------------------------------------------------

| Name | Type |
|------|------|
| [null_resource.forward_zone_db](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.recreate_ddns_conf](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.recreate_dhcpd_conf](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.reverse_zone_db](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

Inputs
------------------------------------------------------------------------------

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dhcp_subnets"></a> [dhcp\_subnets](#input\_dhcp\_subnets) | A map of DHCP subnet configurations. | <pre>map(object({<br/>    network_address = string<br/>    range_start     = string<br/>    range_end       = string<br/>    broadcast       = string<br/>    netmask         = string<br/>    gateways         = list(string)<br/>    dns_servers     = optional(list(string))<br/>    use_gateways_as_dns  = optional(bool)<br/>    domain_name     = string<br/>    domain_search   = list(string)<br/>    reverse_zones   = list(string)<br/>    dns_ip          = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global DHCP settings. | <pre>object({<br/>    default_lease_time    = number<br/>    max_lease_time        = number<br/>    authoritative         = bool<br/>    options               = map(any)<br/>    dns_servers           = optional(list(string))<br/>    ddns_updates          = bool<br/>    ddns_domain_name      = string<br/>    ddns_rev_domainname   = string<br/>    ddns_update_style     = string<br/>    ignore_client_updates = bool<br/>  })</pre> | <pre>{<br/>  "authoritative": true,<br/>  "ddns_domain_name": "lan",<br/>  "ddns_rev_domainname": "in-addr.arpa",<br/>  "ddns_update_style": "none",<br/>  "ddns_updates": false,<br/>  "default_lease_time": 600,<br/>  "ignore_client_updates": false,<br/>  "max_lease_time": 7200,<br/>  "options": {}<br/>}</pre> | no |
| <a name="input_ip_addr"></a> [ip\_addr](#input\_ip\_addr) | The IP address of the host DHCP server. | `string` | n/a | yes |
| <a name="input_setup_ddns"></a> [setup\_ddns](#input\_setup\_ddns) | Whether to set up DDNS updates. | `bool` | `false` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Path to the SSH private key for authentication. | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_static_leases"></a> [static\_leases](#input\_static\_leases) | A list of static DHCP leases to create. | <pre>list(object({<br/>    mac = string<br/>    ip          = string<br/>  }))</pre> | `[]` | no |
| <a name="input_user"></a> [user](#input\_user) | Username for SSH connection. | `string` | `"root"` | no |

