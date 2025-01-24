#!/bin/bash
#
# Enable usage for Hyper-V enhanced session mode
# based on: https://github.com/Hinara/linux-vm-tools/blob/master/ubuntu/24.04/install.sh and
#           https://github.com/Hinara/linux-vm-tools/blob/master/arch/install-config.sh
#
echo "Configuring xorgxrdp"

systemctl stop xrdp
systemctl stop xrdp-sesman

# Configure the installed XRDP ini files.
# use vsock transport.
sed -i_orig -e 's/port=3389/port=vsock:\/\/-1:3389/g' /etc/xrdp/xrdp.ini
# use rdp security.
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
# remove encryption validation.
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
# disable bitmap compression since its local its much faster
sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini
# rename the redirected drives to 'shared-drives'
sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini
# Changed the allowed_users
[[ -e /etc/X11/Xwrapper.config ]] && sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" > /etc/X11/Xwrapper.config


# Blacklist the vmw module - deactivated for arch
if [ ! -e /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf ]; then
  echo "blacklist vmw_vsock_vmci_transport" > /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf
fi

#Ensure hv_sock gets loaded
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
  echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
fi

# Configure the policy xrdp session
mkdir -p /etc/polkit-1/localauthority/50-local.d/
cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF


# reconfigure the service
systemctl daemon-reload
systemctl start xrdp


 
#
###############################################################################
# .xinitrc has to be modified manually.
#
echo "You will have to configure .xinitrc to start your windows manager, see https://wiki.archlinux.org/index.php/Xinit"
echo "Reboot your machine to begin using XRDP."
