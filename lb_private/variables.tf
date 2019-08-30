# ------ Create a new VCN
variable "VCN-CIDR" { default = "10.88.20.0/16" }

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

# ------ bandwidth shape
variable "bandwidth_shape" {}

# ------ region, instances, AD and Instance Shape
variable "region" {}
variable "num_instances" {}
variable "AD" {}
variable "AD1" {}
variable "AD2" {}
variable "AD3" {}
variable "instance_shape" {}
variable "load_balancer_is_private" {}
variable "instance_hostname_label" {}
variable "nat_gateway_display_name" {}
variable "bastian_instance_hostname_label" {}

# ------ IP's for VCN and Security Rules
variable "authorized_ips" {}
variable "authorized_ips_icmp" {}
variable "authorized_ips_ext" {}


# ------ Declaring ssh variables
variable "ssh_public_key_file_ol7" {}
variable "ssh_private_key_file_ol7" {}
variable "BootStrapFile_ol7" {}
