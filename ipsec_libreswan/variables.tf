#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
######################### Basic Variables Configuration along wth VCN Details ##############################+
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ------ Create a new VCN
variable "VCN-CIDR" { default = "172.0.0.0/16" }

# ------ Create compartment ocid
variable "compartment_ocid" {}

# ------ Assign Public IP to Instance
variable "public_ip" {}

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
