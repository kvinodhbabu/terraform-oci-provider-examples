resource "oci_core_virtual_network" "seh_lb_vcn" {
  cidr_block     = "10.88.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "seh_lb_vcn"
  dns_label      = "sehlbvcn"
}

# ----- Regionl Subnet for Application instances with Private Subnet

resource "oci_core_subnet" "private-lb-subnet" {
  #availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD1 - 1],"name")}"
  cidr_block          = "10.88.20.0/24"
  display_name        = "seh-lb-private-subnet"
  dns_label           = "sehlbprivsubnet"
  compartment_id      = "${var.compartment_ocid}"
  #security_list_ids   = ["${oci_core_virtual_network.seh_lb_vcn.default_security_list_id}"]
  
  security_list_ids   = ["${oci_core_security_list.seh_lb_private_securitylist.id}"]
  vcn_id              = "${oci_core_virtual_network.seh_lb_vcn.id}"
  route_table_id      = "${oci_core_route_table.seh_vcn_lb_nat_route.id}"
  dhcp_options_id     = "${oci_core_virtual_network.seh_lb_vcn.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic = "true"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# ----- Regional Subnet for Public Bastion Host
resource "oci_core_subnet" "public-lb-subnet" {
  #availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD2 - 1],"name")}"
  cidr_block          = "10.88.21.0/24"
  display_name        = "seh-lb-public-subnet"
  dns_label           = "sehlbpubsubnet"
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

 resource "oci_core_route_table" "seh_vcn_lb_nat_route" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.seh_lb_vcn.id}"
  display_name = "seh-lb-nat-route-table"
 defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
 route_rules {
   destination = "0.0.0.0/0"
   destination_type  = "CIDR_BLOCK"
   network_entity_id = "${oci_core_nat_gateway.seh_lb_priv_nat_gateway.id}"
  }

}

# ------- Create security list
 resource "oci_core_security_list" "seh_lb_public_securitylist" {
  display_name   = "seh_lb_public_security_list"
  compartment_id = "${oci_core_virtual_network.seh_lb_vcn.compartment_id}"
  vcn_id         = "${oci_core_virtual_network.seh_lb_vcn.id}"

  egress_security_rules {
    protocol    = "all"
    destination = "${var.authorized_ips}"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "${var.authorized_ips}"

    tcp_options {
      min = 80
      max = 80
    }
  }

 ingress_security_rules {
    protocol = "6"
    source   = "${var.authorized_ips}"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "${var.authorized_ips}"

    tcp_options {
      min = 443
      max = 443
    }
  }
 }

resource "oci_core_security_list" "seh_lb_private_securitylist" {
  display_name   = "seh_lb_private_security_list"
  compartment_id = "${oci_core_virtual_network.seh_lb_vcn.compartment_id}"
  vcn_id         = "${oci_core_virtual_network.seh_lb_vcn.id}"

  egress_security_rules {
    protocol    = "all"
    destination = "${var.authorized_ips}"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "${var.authorized_ips_icmp}"

    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "${var.authorized_ips_icmp}"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
   protocol = "1"
   source = "${var.authorized_ips_icmp}"
#   icmp_options {
#    type = 3
#    code = 4
#   }
  }

  ingress_security_rules {
    protocol = "6"
    source   ="${var.authorized_ips_icmp}"

    tcp_options {
      min = 443
      max = 443
    }
  }
 }


resource "oci_core_nat_gateway" "seh_lb_priv_nat_gateway" {
  #Required
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_virtual_network.seh_lb_vcn.id}"
  #Optional
    display_name = "${var.nat_gateway_display_name}"
    defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
}

