# ------- Get the OCID for the more recent for Oracle Linux 7.6 disk image

data "oci_core_images" "OracleLinux-7_6" {
  compartment_id = "${var.compartment_ocid}"
  operating_system = "Oracle Linux"
  operating_system_version = "7.6"

# exclude GPU specific images
   filter {
     name   = "display_name"
     values = ["^([a-zA-z]+)-([a-zA-z]+)-([\\.0-9]+)-([\\.0-9-]+)$"]
     regex  = true
   }
}

# ------ Create a compute instance in london with different VCN CIDR BLOCK

resource "oci_core_instance" "ipsec-demo-uk-instance-ol7" {
  count = "${var.NumInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-ipsec-uk-demo-instance${count.index}"
  shape = "${var.InstanceShape}"

  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
  source_details {
    source_type = "image"
    source_id   = "${data.oci_core_images.OracleLinux-7_6.images.*.id[0]}"
   }

  create_vnic_details {
      assign_public_ip = false
      display_name = "TFPrimaryVnic"
      subnet_id = "${oci_core_subnet.Private_Subnet_UK_AD1.id}"
      skip_source_dest_check = "true"
  }
  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_file_ol7)}"
    user_data = "${base64encode(file(var.BootStrapFile_ol7))}"
  }
   timeouts {
     create = "5m"
   }
 }

# ------ Gets a list of VNIC attachments on the instance

data "oci_core_vnic_attachments" "TFInstanceVnics" {
  count = "${var.NumInstances}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}" 
  instance_id         = "${oci_core_instance.ipsec-demo-uk-instance-ol7[count.index].id}"
}

# ------ Gets the OCID of the first VNIC

data "oci_core_vnic" "TFInstanceVnic1" {
   count = "${var.NumInstances}"
  vnic_id = "${lookup(data.oci_core_vnic_attachments.TFInstanceVnics[count.index].vnic_attachments[0],"vnic_id")}"
}

# ------ Gets a list of private IPs on the first VNIC

data "oci_core_private_ips" "TFPrivateIps1" {
  count = "${var.NumInstances}"
  vnic_id = "${data.oci_core_vnic.TFInstanceVnic1[count.index].id}"
}

# ------ Assign a reserved public IP to the private IP

resource "oci_core_public_ip" "ReservedPublicIPAssigned" {
  count = "${var.NumInstances}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "TFReservedPublicIPAssigned"
  lifetime       = "RESERVED"
  private_ip_id  = "${lookup(data.oci_core_private_ips.TFPrivateIps1[count.index].private_ips[0],"id")}"
}

data "oci_core_instance" "ipsec_libreswan_instance" {
  depends_on = ["oci_core_public_ip.ReservedPublicIPAssigned"]
  count = "${var.NumInstances}"
  instance_id = "${oci_core_instance.ipsec-demo-uk-instance-ol7[count.index].id}"
}

output "Reserved-Public-IP-cpe-device" {
   value = ["${oci_core_public_ip.ReservedPublicIPAssigned[0].ip_address}"]
}
