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

# ------ Create a compute instance from the more recent Oracle Linux 7.6 image

 resource "oci_core_instance" "ipsec-vm-demo-ol7" {
  count = "${var.NumInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-ipsec-demo-instance${count.index}"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
  source_details {
    source_type = "image"
    source_id   = "${data.oci_core_images.OracleLinux-7_6.images.*.id[0]}"
    #"${var.instance_image_ocid[var.region]}"
   }

  shape = "${var.InstanceShape}"
  subnet_id = "${oci_core_subnet.Private_Subnet_AD1.id}"
  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_file_ol7)}"
    user_data = "${base64encode(file(var.BootStrapFile_ol7))}"
  }
   timeouts {
     create = "5m"
   }
 }

 # ------ Display the public IP of instance
 output "Public-IP-of-instance" {
   value = ["${oci_core_instance.ipsec-vm-demo-ol7.*.public_ip}"]
 }

 output "Private-IP-of-instance" {
   value = ["${oci_core_instance.ipsec-vm-demo-ol7.*.private_ip}"]
 }
