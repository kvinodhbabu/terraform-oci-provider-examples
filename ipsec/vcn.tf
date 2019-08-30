# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

resource "oci_core_virtual_network" "vcn_ipsec_demo" {
  cidr_block = "${var.VCN-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-vcn-ipsec-demo"
  dns_label = "vcnipsecdemo"
  defined_tags = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                }
}

# ------ Create a new Internet Gateway

resource "oci_core_internet_gateway" "ipsec_ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-internet-gateway-ipsec-demo"
  vcn_id = "${oci_core_virtual_network.vcn_ipsec_demo.id}"
   defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
}

# ------ Create a new Route Table

resource "oci_core_route_table" "vcn-ipsec-route" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.vcn_ipsec_demo.id}"
  display_name = "seh-ig-drg-ipsec-route-table"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
 route_rules {
   destination = "0.0.0.0/0"
   network_entity_id = "${oci_core_internet_gateway.ipsec_ig.id}"
  }
 route_rules {
   destination = "172.0.0.0/16"
   network_entity_id = "${oci_core_drg.ipsec_drg.id}"
 }
 depends_on = [
   oci_core_drg.ipsec_drg,
 ]
}

# ------ Create a new security list to be used in the new subnet

resource "oci_core_security_list" "vcn-ipsec-demo-subnet-sl" {
 compartment_id = "${var.compartment_ocid}"
 display_name = "seh-vcn-ipsec-demo-subnet-security-list"
 vcn_id = "${oci_core_virtual_network.vcn_ipsec_demo.id}"
 egress_security_rules  {
   protocol = "all"
   destination = "${var.authorized_ips}"
 }

 ingress_security_rules {
   protocol = "6" # tcp
   source = "${var.authorized_ips_icmp}"
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

# ------ Create a private subnet regional in the new VCN
resource "oci_core_subnet" "Private_Subnet_AD1" {
#####  Regional Subnet will not need an Availability Domain   #######
# availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block = "${var.VCN-CIDR}"
  display_name = "seh-ipsec-private-subnet"
  dns_label = "sehsubnet"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.vcn_ipsec_demo.id}"
   defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
  route_table_id = "${oci_core_route_table.vcn-ipsec-route.id}"
  security_list_ids = ["${oci_core_security_list.vcn-ipsec-demo-subnet-sl.id}"]
  dhcp_options_id = "${oci_core_virtual_network.vcn_ipsec_demo.default_dhcp_options_id}"
}
