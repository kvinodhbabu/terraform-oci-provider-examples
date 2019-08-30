# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

resource "oci_core_virtual_network" "seh_vcn_uk_libreswan" {
  cidr_block = "${var.VCN-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-vcn-uk-demo"
  dns_label = "vcnukipsecdemo"
  defined_tags = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                }
}

# ------ Create a new Internet Gateway

resource "oci_core_internet_gateway" "ipsec_uk_ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-internet-gateway-uk-ipsec-demo"
  vcn_id = "${oci_core_virtual_network.seh_vcn_uk_libreswan.id}"
   defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
}

# ------ Create a new Route Table

resource "oci_core_route_table" "seh-vcn-uk-ipsec-route" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.seh_vcn_uk_libreswan.id}"
  display_name = "seh-ig-uk-ipsec-route-table"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
 route_rules {
   destination = "0.0.0.0/0"
   network_entity_id = "${oci_core_internet_gateway.ipsec_uk_ig.id}"
  }
}

# ------ Create a new security list to be used in the new subnet

resource "oci_core_security_list" "vcn-uk-ipsec-demo-subnet-sl" {
 compartment_id = "${var.compartment_ocid}"
 display_name = "seh-vcn-ipsec-demo-subnet-security-list"
 vcn_id = "${oci_core_virtual_network.seh_vcn_uk_libreswan.id}"
 egress_security_rules  {
   protocol = "all"
   destination = "${var.authorized_ips}"
 }

 ingress_security_rules {
   protocol = "6" # tcp
   source = "${var.authorized_ips}"
   }

 ingress_security_rules {
   protocol = "6" # tcp
   source = "${var.authorized_ips}"
   tcp_options  {
     min = 22
     max = 22
   }
  }

 ingress_security_rules {
   protocol = "6" # tcp
   source = "${var.authorized_ips_icmp}"
   tcp_options  {
     min = 22
     max = 22
   }
  }

 ingress_security_rules {
   protocol = "6" # tcp
    source = "${var.authorized_ips}"
    tcp_options {
      min = 500
      max = 500
      }
    }
    ingress_security_rules {
    protocol = "17" # udp
    source = "${var.authorized_ips}"
    udp_options  {
      min = 500
      max = 500
      }
    }
    ingress_security_rules {
    protocol = "6" # udp
    source = "${var.authorized_ips}"
    tcp_options {
      min = 4500
      max = 4500
      }
    }
    ingress_security_rules {
    protocol = "17" # udp
    source = "${var.authorized_ips}"
    udp_options {
      min = 4500
      max = 4500
      }
    }
 ingress_security_rules {
   protocol = "1" # ICMP
   source = "${var.authorized_ips_icmp}"
   icmp_options {
    type = 3
    code = 4
   }
   }
 ingress_security_rules {
    protocol = "all" # All Protocols
    source = "${var.authorized_ips}"
   }
    defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
 }

# ------ Create a private subnet regional in the UK VCN
resource "oci_core_subnet" "Private_Subnet_UK_AD1" {
#####  Regional Subnet will not need an Availability Domain   #######
# availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block = "${var.VCN-CIDR}"
  display_name = "seh-uk-ipsec-private-subnet"
  dns_label = "sehuksubnet"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.seh_vcn_uk_libreswan.id}"
  defined_tags = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                 }
  route_table_id = "${oci_core_route_table.seh-vcn-uk-ipsec-route.id}"
  security_list_ids = ["${oci_core_security_list.vcn-uk-ipsec-demo-subnet-sl.id}"]
  dhcp_options_id = "${oci_core_virtual_network.seh_vcn_uk_libreswan.default_dhcp_options_id}"
}
