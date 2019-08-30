#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
################################              IPSEC Resource Creation and Tunnel Management     ############################################+
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ------- Provides the CPE resource in Oracle Cloud Infrastructure Core service
resource "oci_core_cpe" "ipsec_cpe" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "seh-cpe"
  ip_address     = "${var.ip_sec_connection_cpe_local_identifier}"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
}

# ------- Creates a new dynamic routing gateway (DRG) in the specified compartment.
resource "oci_core_drg" "ipsec_drg" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "seh-drg-for-dc"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
}

# ------- Attaches the specified DRG to the specified VCN
resource "oci_core_drg_attachment" "ipsec_drg_attachment" {
    #Required
    compartment_id = "${var.compartment_ocid}"

    drg_id = "${oci_core_drg.ipsec_drg.id}"
    vcn_id = "${oci_core_virtual_network.vcn_ipsec_demo.id}"
    depends_on = [
      oci_core_virtual_network.vcn_ipsec_demo,oci_core_drg.ipsec_drg,
    ]

}

# ------- Creates a new IPSec connection between the specified DRG and CPE
resource "oci_core_ipsec" "ip_sec_connection" {
  # Required
     compartment_id = "${var.compartment_ocid}"
     cpe_id         = "${oci_core_cpe.ipsec_cpe.id}"
     drg_id         = "${oci_core_drg.ipsec_drg.id}"
     static_routes  = "${var.ip_sec_connection_static_routes}"

  # Optional
    cpe_local_identifier      = "${var.ip_sec_connection_cpe_local_identifier}"
    cpe_local_identifier_type = "${var.ip_sec_connection_cpe_local_identifier_type}"

   defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
   display_name              = "${var.ip_sec_connection_display_name}"
   freeform_tags             = "${var.ip_sec_connection_freeform_tags}"
}

# ------ Data source provides details about a specific Configuration resource in OCI Audit service
data "oci_core_ipsec_connections" "ip_sec_connections" {
 # Required
  compartment_id = "${var.compartment_ocid}"

 # Optional
  cpe_id = "${oci_core_cpe.ipsec_cpe.id}"
  drg_id = "${oci_core_drg.ipsec_drg.id}"
}

data "oci_core_ipsec_connection_tunnels" "ip_sec_connection_tunnels" {
  ipsec_id = "${oci_core_ipsec.ip_sec_connection.id}"
}

data "oci_core_ipsec_connection_tunnel" "ipsec_connection_tunnel" {
  ipsec_id  = "${oci_core_ipsec.ip_sec_connection.id}"
  tunnel_id = "${data.oci_core_ipsec_connection_tunnels.ip_sec_connection_tunnels.ip_sec_connection_tunnels.0.id}"
}

data "oci_core_ipsec_connection_tunnel" "ipsec_connection_tunnel_1" {
  ipsec_id  = "${oci_core_ipsec.ip_sec_connection.id}"
  tunnel_id = "${data.oci_core_ipsec_connection_tunnels.ip_sec_connection_tunnels.ip_sec_connection_tunnels.0.id}"
}

data "oci_core_ipsec_connection_tunnel" "ipsec_connection_tunnel_2" {
  ipsec_id  = "${oci_core_ipsec.ip_sec_connection.id}"
  tunnel_id = "${data.oci_core_ipsec_connection_tunnels.ip_sec_connection_tunnels.ip_sec_connection_tunnels.1.id}"
}


# ----- IPSEC Tunnel Management

#resource "oci_core_ipsec_connection_tunnel_management" "ipsec_connection_tunnel_management" {
 #depends_on = ["oci_core_ipsec.ip_sec_connection"]
#    ipsec_id   = "${oci_core_ipsec.ip_sec_connection.id}"
#     tunnel_id  = "${data.oci_core_ipsec_connection_tunnels.ip_sec_connection_tunnels.ip_sec_connection_tunnels.0.id}"
#
#    routing    = "${var.ip_sec_connection_tunnel_configuration_routing}"

# Optional
   #bgp_session_info {
   #  customer_bgp_asn      = "${var.ip_sec_connection_tunnel_configuration_bgp_session_config_customer_bgp_asn}"
   #  customer_interface_ip = "${var.ip_sec_connection_tunnel_configuration_bgp_session_config_customer_interface_ip}"
   #  oracle_interface_ip   = "${var.ip_sec_connection_tunnel_configuration_bgp_session_config_oracle_interface_ip}"
   #}

   #display_name  = "${var.ip_sec_connection_tunnel_configuration_display_name}"
 #  shared_secret = "${var.ip_sec_connection_tunnel_configuration_shared_secret}"
#}

# ------ Display the public IP of Oracle's VPN headend

output "Details_of_ipsec_tunnels" {
  value = ["${data.oci_core_ipsec_connection_tunnels.ip_sec_connection_tunnels.*}"]
}

output "Public-Ip-Of-IpSec-Connection-Tunnel_1" {
  value = ["${data.oci_core_ipsec_connection_tunnel.ipsec_connection_tunnel_1.*.vpn_ip}"]
}

output "Public-Ip-Of-IpSec-Connection-Tunnel_2" {
  value = ["${data.oci_core_ipsec_connection_tunnel.ipsec_connection_tunnel_2.*.vpn_ip}"]
}

