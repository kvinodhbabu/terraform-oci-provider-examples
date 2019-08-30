# -- Tenant Information
tenancy_ocid = ""
user_ocid= "" 
fingerprint = ""
private_key_path = "/home/opc/sehub/.oci/oci_api_key.pem"
compartment_ocid = ""
region = "us-ashburn-1"

# ---- availability domain (1, 2 or 3)
AD= "1"
AD1 = "1"
AD2 = "2"
AD3 = "3"
# ---- OCI Core subnet
bandwidth_shape="100Mbps"

# ---- Instance Shape
instance_shape = "VM.Standard2.1"

# ---- Number of instnaces
num_instances = "1"

# ---- Load Balancer private
load_balancer_is_private= "true"
# ---- Volumes Per Instance

#NumVolumesPerInstance = "1"
instance_hostname_label= "lbprivhost"
bastian_instance_hostname_label = "lbbastianhost"

# ---- Volume size
#VolSize = "50"

nat_gateway_display_name = "nat_for_private_ips"
# ---- Authorized public IPs ingress (0.0.0.0/0 means all Internet)

authorized_ips="0.0.0.0/0" # all Internet or a specific public IP on Internet or a specific Class B network on Internet

authorized_ips_icmp="10.88.0.0/16"  # for ICMP only VCN Subnet

authorized_ips_ext="10.0.0.0/16"   # External route details

# ----- keys to access compute instance
 ssh_public_key_file_ol7 = "/home/opc/.ssh/id_rsa_ol7.pub"
 ssh_private_key_file_ol7 = "/home/opc/.ssh/id_rsa"

# ---- variables for BM/VM creation
BootStrapFile_ol7 = "userdata/bootstrap_ol7"
