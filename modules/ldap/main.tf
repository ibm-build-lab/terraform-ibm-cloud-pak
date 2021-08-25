resource "ibm_compute_vm_instance" "ldap" {

  count                = var.enable ? 1 : 0

  hostname             = var.hostname
  domain               = var.ibmcloud_domain
  ssh_key_ids          = ["${ibm_compute_ssh_key.key.id}"]
  os_reference_code    = var.os_reference_code
  datacenter           = var.datacenter
  network_speed        = var.network_speed
  hourly_billing       = var.hourly_billing
  private_network_only = var.private_network_only
  cores                = var.cores
  memory               = var.memory
  disks                = var.disks
  local_disk           = var.local_disk

  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.ssh.private_key_pem
    agent       = false
    host        = ibm_compute_vm_instance.ldap[count.index].ipv4_address
  }

  provisioner "file" {
    source      = "files/install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "file" {
    source      = "files/DB2_AWSE_Restricted_Activation_11.1.zip"
    destination = "/tmp/DB2_AWSE_Restricted_Activation_11.1.zip"
  }

  provisioner "file" {
    source      = "files/sds64-premium-feature-act-pkg.zip"
    destination = "/tmp/sds64-premium-feature-act-pkg.zip"
  }

  provisioner "file" {
    source      = "files/cp.ldif"
    destination = "/tmp/cp.ldif"
  }

  provisioner "file" {
    source      = "files/db2server-V11.1.rsp"
    destination = "/tmp/db2server-V11.1.rsp"
  }

  provisioner "remote-exec" {
    # install required libraries and software
    inline = [
      "touch this_file_was_created_in_classic",
      "yum install -y epel-release",
      "yum install -y tar",
      "yum install -y unzip",
      "yum install -y libstdc++.i686",
      "yum install -y pam.i686",
      "yum install -y gcc-c++",
      "yum install -y ksh",
      "yum install -y libaio",
      "chmod +x /tmp/install.sh",
      "sh /tmp/install.sh",
    ]
  }
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
