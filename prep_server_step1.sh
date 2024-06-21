#!/bin/bash -xe

# mount external disk
sudo mkdir -p -m 777 /mnt/disks/$HOST-data
DATA_DISK_UUID=$(sudo blkid -s UUID -o value /dev/disk/by-id/google-$HOST-data)
sudo tee -a /etc/fstab <<EOF
UUID=$DATA_DISK_UUID /mnt/disks/$HOST-data ext4 discard,defaults,nofail 0 2
EOF

sudo systemctl daemon-reload
sudo mount /mnt/disks/$HOST-data
sudo ln -s /mnt/disks/$HOST-data /data
sudo mkdir -p -m 755 /mnt/disks/$HOST-data/$HOME
sudo chown $USER:$USER /mnt/disks/$HOST-data/$HOME
tar c . | tar x -C /mnt/disks/$HOST-data/$HOME

sudo tee -a /etc/fstab <<EOF
/data/home /home none bind
EOF
sudo systemctl daemon-reload
sudo mount /data/home
cd $HOME

# from: https://docs.docker.com/engine/install/debian/

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
	sudo apt-get remove $pkg
done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
