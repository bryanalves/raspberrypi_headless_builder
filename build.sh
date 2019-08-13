#!/bin/bash

if [ -f "build_params" ]; then
  . build_params
fi

if [[ -z "${RHB_BASE}" ]]; then
  echo "Missing RHB_BASE"
  exit 1
fi

if [[ -z "${RHB_GITHUBUSER}" ]]; then
  echo "Missing RHB_GITHUBUSER"
  exit 1
fi

if [[ -z "${RHB_HOSTNAME}" ]]; then
  echo "Missing RHB_HOSTNAME"
  exit 1
fi

if [[ -z "${RHB_SSID}" ]]; then
  echo "Missing RHB_SSID"
  exit 1
fi

if [[ -z "${RHB_PSK}" ]]; then
  echo "Missing RHB_PSK"
  exit 1
fi

echo RHB_BASE=$RHB_BASE
echo RHB_GITHUBUSER=$RHB_GITHUBUSER
echo RHB_HOSTNAME=$RHB_HOSTNAME
echo RHB_SSID=$RHB_SSID
echo RHB_PSK=$RHB_PSK

echo
echo "Starting build in 3 seconds"
sleep 3

mountbootstart=$(fdisk -l bases/$RHB_BASE | grep img1 | awk '{print $2}')
mountrootstart=$(fdisk -l bases/$RHB_BASE | grep img2 | awk '{print $2}')

MNTBASE=rhb_mnt

mkdir -p $MNTBASE

cp bases/$RHB_BASE out/build.img

# Do things to boot partition
sudo mount -o loop,offset=$(($mountbootstart * 512)) out/build.img $MNTBASE/

## Set video mem to minimum
echo "gpu_mem=16" | sudo tee $MNTBASE/config.txt > /dev/null

## Enable ssh
sudo touch $MNTBASE/ssh

## Set up initial wireless connection
RHB_SSID=$RHB_SSID RHB_PSK=$RHB_PSK envsubst < templates/wpa_supplicant.conf.tmpl | sudo tee $MNTBASE/wpa_supplicant.conf > /dev/null

sudo umount $MNTBASE

# Do things to root partition
sudo mount -o loop,offset=$(($mountrootstart * 512)) out/build.img $MNTBASE/

## Disable password login
sudo sed -ie s/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g $MNTBASE/etc/ssh/sshd_config

## Set up ssh keys
sudo mkdir -p $MNTBASE/home/pi/.ssh/
sudo chmod 700 $MNTBASE/home/pi/.ssh

curl https://github.com/$RHB_GITHUBUSER.keys | sudo tee $MNTBASE/home/pi/.ssh/authorized_keys > /dev/null
sudo chmod 600 $MNTBASE/home/pi/.ssh/authorized_keys

## Set up hostname
sudo sed -ie s/raspberrypi/$RHB_HOSTNAME/g $MNTBASE/etc/hostname
sudo sed -ie s/raspberrypi/$RHB_HOSTNAME/g $MNTBASE/etc/hosts

sudo umount $MNTBASE
