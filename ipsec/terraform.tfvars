# -- Tenant Information
tenancy_ocid = ""
user_ocid= "" 
fingerprint = ""
private_key_path = "/home/opc/sehub/.oci/oci_api_key.pem"
compartment_ocid = ""
region = "us-ashburn-1"

# ---- availability domain (1, 2 or 3)
AD= "1"

# ---- Instance Shape
InstanceShape = "VM.Standard2.1"

# ---- Number of instnaces
NumInstances = "1"

# ---- Volumes Per Instance
#NumVolumesPerInstance = "1"

# ---- Volume size
#VolSize = "50"

# ---- Authorized public IPs ingress (0.0.0.0/0 means all Internet)

authorized_ips="0.0.0.0/0" # all Internet or a specific public IP on Internet or a specific Class B network on Internet

authorized_ips_icmp="10.88.0.0/16"  # for ICMP only VCN Subnet

authorized_ips_ext="172.0.0.0/16"   # External route details

# ----- keys to access compute instance

ssh_public_key_file_ol7 = "/home/opc/.ssh/id_rsa_ol7.pub"
ssh_private_key_file_ol7 = "/home/opc/.ssh/id_rsa"

# ---- variables for BM/VM creation
BootStrapFile_ol7 = "userdata/bootstrap_ol7"
