#!/bin/bash

echo "Installing xorgxrdp"

gpg --recv-keys 03993B4065E7193B
pikaur -S --noconfirm --needed xorgxrdp

sudo systemctl enable xrdp
sudo systemctl enable xrdp-sesman

echo "Installation of xorgxrdp is complete."
