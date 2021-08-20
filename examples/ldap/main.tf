module "ldap" {

  source = "../../modules/ldap"

  enable               = true

  hostname             = var.hostname
  domain               = var.ibmcloud_domain
  ssh_key_ids          = ["${ibm_compute_ssh_key.key.id}"]
  os_reference_code    = "CentOS_8_64"
  datacenter           = var.datacenter
  network_speed        = 10
  hourly_billing       = true
  private_network_only = false
  cores                = "2"
  memory               = "4096"
  disks                = [25]
  local_disk           = false

}

# Generate an SSH key/pair to be used to provision the classic VSI
resource tls_private_key ssh {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "ssh-private-key" {
  content = tls_private_key.ssh.private_key_pem
  filename = "generated_key_rsa"
  file_permission = "0600"
}

resource "local_file" "ssh-public-key" {
  content = tls_private_key.ssh.public_key_openssh
  filename = "generated_key_rsa.pub"
  file_permission = "0600"
}

resource "ibm_compute_ssh_key" "key" {
  label      = "ldap-vm-to-migrate"
  public_key = tls_private_key.ssh.public_key_openssh
  notes = "created by terraform"
}

output "CLASSIC_ID" {

value = var.enable && length(ibm_compute_vm_instance.ldap) > 0 ? ibm_compute_vm_instance.ldap.0.id : ""

}

output "CLASSIC_IP_ADDRESS" {

  value = var.enable && length(ibm_compute_vm_instance.ldap) > 0 ? ibm_compute_vm_instance.ldap.0.ipv4_address: ""

}