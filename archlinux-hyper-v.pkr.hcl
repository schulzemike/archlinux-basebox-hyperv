packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
    sshkey = {
      version = "~> 1"
      source = "github.com/ivoronin/sshkey"
    }
    vagrant = {
      version = "~> 1"
      source = "github.com/hashicorp/vagrant"
    }
  }
}
variable "download_mirror" {
  type    = string
  default = "ftp.halifax.rwth-aachen.de"
}

variable "arch_version" {
  type    = string
  default = "2025.01.01"
}

data "sshkey" "vagrant" {
  name = "vagrant_id"
}


source "hyperv-iso" "arch-builder" {
  boot_command         = [
							"<enter><wait20>",
							"/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/user_configuration.json<enter><wait1>", 
							"/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/user_credentials.json<enter><wait1>",
							"archinstall --config user_configuration.json --creds user_credentials.json --silent<enter><wait4m>",
							"reboot<enter>"
						]
  boot_wait            = "3s"
  first_boot_device    = "SCSI:0:0"
  boot_order           = [
							"SCSI:0:0",
							"SCSI:0:1"
						 ]
  cpus                 = 5
  communicator         = "ssh"
  disk_size            = 81920
  enable_secure_boot   = false
  generation           = 2
  headless             = false
  http_directory       = "./srv"
  iso_checksum         = "file:https://${var.download_mirror}/archlinux/iso/${var.arch_version}/sha256sums.txt"
  iso_url              = "https://${var.download_mirror}/archlinux/iso/${var.arch_version}/archlinux-${var.arch_version}-x86_64.iso"
  shutdown_command     = "sudo shutdown -P now"
  disable_shutdown     = false
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "20m"
  switch_name          = "Default Switch"
}

build {
  sources = ["source.hyperv-iso.arch-builder"]
 
  provisioner "shell" {
	inline = [
		"#!/bin/bash -e",
	    "echo 'Saving public SSH key for vagrant user...'",
	    "[[ -d /home/vagrant/.ssh ]] || mkdir /home/vagrant/.ssh",
		"echo ${data.sshkey.vagrant.public_key} > /home/vagrant/.ssh/authorized_keys"
	]
  }
  
  provisioner "shell" {
	script = "provision/00_pikaur.sh"
  }

  provisioner "shell" {
 	script = "provision/01_install-xrdp.sh"
  }
  
  provisioner "shell" {
 	script = "provision/02_config-xrdp.sh"
	execute_command = "echo 'packer' | sudo -S env {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
 	script = "provision/03_install-pipewire-xrdp.sh"
  }
  
  post-processor "vagrant" {
    architecture         = "amd64"
 	output               = "output/my-arch-base.box"
 	keep_input_artifact  = true
 	provider_override    = "hyperv"
 	vagrantfile_template = "vagrant/Vagrantfile"
 	include              = [
                             "packer_cache/ssh_private_key_vagrant_id_rsa.pem"					   
 	                       ]
  }
}
