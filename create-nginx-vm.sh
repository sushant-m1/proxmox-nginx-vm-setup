#!/usr/bin/env bash
APP="Nginx"
VMID=$(pvesh get /cluster/nextid)       # Automatically get the next available VM ID
ISO_PATH="/mnt/storage1/template/iso/jammy-server-cloudimg-amd64-disk-kvm.img " # Full path to ISO
var_disk="20G"                           # Disk size in GB
var_cpu="2"                              # Number of CPU cores
var_ram="2048"                           # RAM size in MB

function header_info {
  clear
  cat <<"EOF"
      __  ___                       ____  ____ 
     /  |/  /___  ____  ____ _____ / __ \/ __ )
    / /|_/ / __ \/ __ \/ __ `/ __ \/ / / / __  |
   / /  / / /_/ / / / / /_/ / /_/ / /_/ / /_/ / 
  /_/  /_/\____/_/ /_/\__, /\____/_____/_____/  
                     /____/                     
EOF
}
header_info
echo -e "Creating VM for ${APP}..."

# Create the VM with initial configuration
qm create $VMID --name "$APP" --memory "$var_ram" --cores "$var_cpu" --net0 virtio,bridge=vmbr0

# Attach the Disk and CD-ROM Drive with ISO
qm set $VMID --scsihw virtio-scsi-pci --scsi0 "storage1:$var_disk"  # Attach main disk
qm set $VMID --ide2 "/mnt/storage1/template/iso/jammy-server-cloudimg-amd64-disk-kvm.img ",media=cdrom                         # Attach ISO to IDE2

# Set boot order to prioritize CD-ROM, then Disk
qm set $VMID --boot order=ide2  # Ensures VM attempts to boot from CD-ROM first

# Specify the OS type for Linux
qm set $VMID --ostype l26  # Linux OS type

# Start the VM
qm start $VMID
echo "VM $VMID created and started successfully!"

# Wait for VM to initialize
qm wait $VMID  # Wait until the VM has fully booted

# SSH installation of Nginx (replace <IP_ADDRESS> with your VM’s IP)
IP_ADDRESS="192.168.1.20"  # Confirm this IP is correct for your network
ssh -o StrictHostKeyChecking=no root@$IP_ADDRESS <<EOF
  apt update -y
  apt install -y nginx
  systemctl enable nginx
  systemctl start nginx
EOF

echo "Nginx has been successfully installed on VM $VMID!"




