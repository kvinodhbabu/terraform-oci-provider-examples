resource "oci_core_virtual_network" "seh_lb_vcn" {
  cidr_block     = "10.88.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "seh_lb_vcn"
  dns_label      = "sehlbvcn"
}

resource "oci_core_subnet" "public-lb-subnet-AD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD1 - 1],"name")}"
  cidr_block          = "10.88.20.0/24"
  display_name        = "seh-lb-subnet-ad1"
  dns_label           = "sehlbsubnetad1"
  security_list_ids   = ["${oci_core_security_list.seh_lb_public_securitylist.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.seh_lb_vcn.id}"
  route_table_id      = "${oci_core_route_table.seh_vcn_lb_route.id}"
  dhcp_options_id     = "${oci_core_virtual_network.seh_lb_vcn.default_dhcp_options_id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_subnet" "public-lb-subnet-AD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD2 - 1],"name")}"
  cidr_block          = "10.88.21.0/24"
  display_name        = "seh-lb-subnet-ad2"
  dns_label           = "sehlbsubnetad2"
  security_list_ids   = ["${oci_core_security_list.seh_lb_public_securitylist.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.seh_lb_vcn.id}"
  route_table_id      = "${oci_core_route_table.seh_vcn_lb_route.id}"
  dhcp_options_id     = "${oci_core_virtual_network.seh_lb_vcn.default_dhcp_options_id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# ------ Create a new Internet Gateway

resource "oci_core_internet_gateway" "seh_lb_ig" {
   compartment_id = "${var.compartment_ocid}"
   display_name = "seh-internet-gateway-ipsec-demo"
   vcn_id = "${oci_core_virtual_network.seh_lb_vcn.id}"
   defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
}

# ------ Create a new Route Table

resource "oci_core_route_table" "seh_vcn_lb_route" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.seh_lb_vcn.id}"
  display_name = "seh-lb-ig-route-table"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
 route_rules {
   destination = "0.0.0.0/0"
   destination_type  = "CIDR_BLOCK"
   network_entity_id = "${oci_core_internet_gateway.seh_lb_ig.id}"
  }

}

# ------- Create security list

resource "oci_core_security_list" "seh_lb_public_securitylist" {
  display_name   = "seh_lb_public_security_list"
  compartment_id = "${oci_core_virtual_network.seh_lb_vcn.compartment_id}"
  vcn_id         = "${oci_core_virtual_network.seh_lb_vcn.id}"
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }
}
