# ------- Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
    compartment_id = "${var.tenancy_ocid}"
}

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

resource "oci_core_instance" "lb-vm-instance-01-ol7" {
  depends_on = ["oci_core_nat_gateway.seh_lb_priv_nat_gateway"]
  count = "${var.num_instances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD1 - 1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-lb-demo-01-instance${count.index}"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
  source_details {
    source_type = "image"
    source_id   = "${data.oci_core_images.OracleLinux-7_6.images.*.id[0]}"
   }
  hostname_label = "${var.instance_hostname_label}0"
  shape = "${var.instance_shape}"
  subnet_id = "${oci_core_subnet.private-lb-subnet.id}"
  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_file_ol7)}"
    user_data = "${base64encode(file(var.BootStrapFile_ol7))}"
  }
  timeouts {
    create = "5m"
  }
}

resource "oci_core_instance" "lb-vm-instance-02-ol7" {
  depends_on = ["oci_core_nat_gateway.seh_lb_priv_nat_gateway"]
  count = "${var.num_instances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD2 - 1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-lb-demo-02-instance${count.index}"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
  source_details {
    source_type = "image"
    source_id   = "${data.oci_core_images.OracleLinux-7_6.images.*.id[0]}"
   }

  hostname_label = "${var.instance_hostname_label}1"
  shape = "${var.instance_shape}"
  subnet_id = "${oci_core_subnet.private-lb-subnet.id}"
  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_file_ol7)}"
    user_data = "${base64encode(file(var.BootStrapFile_ol7))}"
  }
  timeouts {
    create = "5m"
  }
}

resource "oci_core_instance" "lb-bastian-instance-ol7" {
  count = "${var.num_instances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD3 - 1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "seh-lb-bastian-instance${count.index}"
  defined_tags   = {
                    "root_namespace.owner":"se_hub"
                    "root_namespace.team":"michael_charbonnier"
                   }
  source_details {
    source_type = "image"
    source_id   = "${data.oci_core_images.OracleLinux-7_6.images.*.id[0]}"
   }
  hostname_label = "${var.bastian_instance_hostname_label}"
  shape = "${var.instance_shape}"
  subnet_id = "${oci_core_subnet.public-lb-subnet.id}"
  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_file_ol7)}"
    user_data = "${base64encode(file(var.BootStrapFile_ol7))}"
  }
  timeouts {
    create = "5m"
  }
}

# ------ Display the public IP of instance

output "Private-IP-of-instance-01" {
  value = ["${oci_core_instance.lb-vm-instance-01-ol7.*.private_ip}"]
}

output "Private-IP-of-instance-02" {
  value = ["${oci_core_instance.lb-vm-instance-02-ol7.*.private_ip}"]
}

output "Public-IP-of-Bastian-instance" {
  value = ["${oci_core_instance.lb-bastian-instance-ol7.*.public_ip}"]
}

output "Private-IP-of-Bastian-instance" {
  value = ["${oci_core_instance.lb-bastian-instance-ol7.*.private_ip}"]
}
