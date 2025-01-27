# Create a Vagrant Basebox for Archlinux and Hyper-V

## Used documentation
- Vagrant / Hyper-V / [Creating a Base Box](https://developer.hashicorp.com/vagrant/docs/providers/hyperv/boxes)

## Prereqisites

With the Windows 11 22H2 a Hyper-V Firewall was introduced. You can find further information [here](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/hyper-v-firewall)

- Adjust the Hyper-V Firewall, so that the Guest can download files from the Http-Server that is created by packer
```
New-NetFirewallHyperVRule -DisplayName "Allow Packer HTTP" -Direction Inbound -VMCreatorId '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -Action Allow -Protocol TCP -LocalPort 8000-9000
```


## Configuration
last updated for version 3.0.1

### Disk configuration
- the start points of a partition has to be given in the unit 'B'
- between the partitions there a gap of 1MiB
```
Calculation example:
Disk size: 20480 MiB
Size of boot partition: 1024MiB
-------------------------------
Resulting size of root partition = 20480 - 1 - 1024 - 1 = 19454MiB
```

### Preparation for Vagrant
- The Basebox contains an initial Vagrantfile that handles the integration of the SSH key and the sync folder via rsync.
NOTICE: On my windows system I can not use SMB due to security policies on any other system it might work.


### Contents
- bash completion
- dex to autostart desktop applications
- man pages
- pikaur as an AUR helper
- pipewire and pipewire-module-xrdp
- reflector to update pacman mirror lists
- xrdp and xorgxrdp
- unzip

# Register the Basebox to your local vagrant installation
vagrant box add --provider hyperv my-arch-basebox .\output\my-arch-base.box
