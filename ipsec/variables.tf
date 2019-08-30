#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
######################### Basic Variables Configuration along wth VCN Details ##############################+
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ------ Create a new VCN
variable "VCN-CIDR" { default = "10.88.0.0/16" }

# ------ Create namespace description for tag
variable "tag_namespace_description" {
  default = "seh-ipsec-vpn"
}

# ------ Create tag namespace name
variable "tag_namespace_name" {
  default = "seh-ipsec-connection-namespace"
}

# ------ Create compartment ocid
variable "compartment_ocid" {}

# ------ Tenancy ocid
variable "tenancy_ocid" {}

# ------ User ocid
variable "user_ocid" {}

# ------ fingerprint
variable "fingerprint" {}

# ------ private_key_path
variable "private_key_path" {}

# ------ region, instances, AD and Instance Shape
variable "region" {}
variable "NumInstances" {}
variable "AD" {}
variable "InstanceShape" {}

# ------ IP's for VCN and Security Rules
variable "authorized_ips" {}
variable "authorized_ips_icmp" {}
variable "authorized_ips_ext" {}

# ------ Declaring ssh variables
variable "ssh_public_key_file_ol7" {}
variable "ssh_private_key_file_ol7" {}
variable "BootStrapFile_ol7" {}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##############################             IPSEC Configuration Details          ###################################+
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "ip_sec_connection_cpe_local_identifier" {
  #default = "132.145.9.103"
}

variable "ip_sec_connection_cpe_local_identifier_type" {
  default = "IP_ADDRESS"
}

variable "ip_sec_connection_defined_tags_value" {
  default = "seh-ipsec-VPN"
}

variable "ip_sec_connection_display_name" {
  default = "seh-ipsec-conn"
}

variable "ip_sec_connection_freeform_tags" {
  default = {
    "seh_demo" = "seh-oci-ipsec-conn"
  }
}

variable "ip_sec_connection_static_routes" {
  default = ["172.0.0.0/16"]
}

variable "ip_sec_connection_tunnel_configuration_bgp_session_config_customer_bgp_asn" {
  default = "1587232876"
}

variable "ip_sec_connection_tunnel_configuration_bgp_session_config_customer_interface_ip" {
  default = "10.0.0.16/31"
}

variable "ip_sec_connection_tunnel_configuration_bgp_session_config_oracle_interface_ip" {
  default = "10.0.0.17/31"
}

variable "ip_sec_connection_tunnel_configuration_display_name" {
  default = "seh-isec-tunnel-mgmt-others"
}

variable "ip_sec_connection_tunnel_configuration_routing" {
  default = "static"   # BGP is also an option
}

variable "ip_sec_connection_tunnel_configuration_shared_secret" {
  default = "0gTp35x1aY9WhxGp22UWRpB6C68chKh9ju3ZSBWtsPt5dx3hCwY0K1l5UX2CeFOz"
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
