resource "null_resource" "libreswansetup" {
   depends_on = ["oci_core_public_ip.ReservedPublicIPAssigned","oci_core_instance.ipsec-demo-uk-instance-ol7",]
   count = "${var.NumInstances}"
   
# copy files to enable libreswan to communicate
    provisioner "file" {
    source      = "oci-ipsec.conf"
    destination = "/home/opc/oci-ipsec.conf"
	
    connection {
    type = "ssh"
    host = "${data.oci_core_instance.ipsec_libreswan_instance.*.public_ip[count.index]}" 
    user = "opc"
    private_key = file("~/.ssh/id_rsa")
       }
    }
    provisioner "file" {
    source      = "ipsec.secrets"
    destination = "/home/opc/ipsec.secrets"
	
    connection {
    type = "ssh"
    host = "${data.oci_core_instance.ipsec_libreswan_instance.*.public_ip[count.index]}"
#"${oci_core_instance.ipsec-demo-uk-instance-ol7.*.public_ip[count.index]}" 
    user = "opc"
    private_key = file("~/.ssh/id_rsa")
       }
    }
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "30m"
        host = "${data.oci_core_instance.ipsec_libreswan_instance.*.public_ip[count.index]}"
        user = "opc"
        private_key = file("~/.ssh/id_rsa")
    }
      inline = [
                #"sudo yum update -y",
                "sudo yum -y install libreswan",
                "sudo chmod 666 /etc/sysctl.conf",
                "sudo printf 'net.ipv4.ip_forward=1\nnet.ipv4.conf.all.accept_redirects=0\nnet.ipv4.conf.all.send_redirects=0\nnet.ipv4.conf.default.send_redirects=0\nnet.ipv4.conf.ens3.send_redirects=0\nnet.ipv4.conf.default.accept_redirects=0\nnet.ipv4.conf.ens3.accept_redirects=0\n' >> /etc/sysctl.conf",
                "sudo chmod 644 /etc/sysctl.conf",
                "sudo sysctl -p",
                "sudo ipsec start",
                "sudo systemctl restart ipsec.service",
                "sudo chmod 666 /etc/ipsec.conf",
                "sudo mv /etc/ipsec.conf /etc/ipsec.conf.bck",
                "sudo touch /etc/ipsec.conf",
                "sudo chmod 666 /etc/ipsec.conf",
                "sudo printf 'config setup\ninclude /etc/ipsec.d/*.conf\n' >> /etc/ipsec.conf",
                "sudo chmod 644 /etc/ipsec.conf",
                "sudo cp /home/opc/oci-ipsec.conf /etc/ipsec.d/",
                "sudo cp /home/opc/ipsec.secrets /etc/",
                "sudo systemctl stop firewalld",
                "sudo systemctl disable firewalld",
                "sudo ipsec restart",
                "exit"
      ]
    }
}
