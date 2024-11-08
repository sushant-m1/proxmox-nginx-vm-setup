\#!/usr/bin/env bash
APP="Nginx"
VMID=$(pvesh get /cluster/nextid)  # Automatically get the next available VM ID
ISO_PATH="ubuntu-22.04.5-desktop-amd64.iso"           # Name of the ISO file in /var/lib/vz/template/iso/
var_disk="20"                      # Disk size in GB
var_cpu="2"                        # Number of CPU cores
var_ram="2048"                     # RAM size in MB

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
qm set $VMID --scsihw virtio-scsi-pci --scsi0 storage1:32G  # Attach main disk
qm set $VMID --ide2 storage1:iso/ubuntu-22.04.5-desktop-amd64.iso,media=cdrom                    # Attach ISO to IDE2

# Set boot order to prioritize CD-ROM, then Disk
qm set $VMID --boot order=ide2,scsi0  # Ensures VM attempts to boot from CD-ROM first

# Specify the OS type for Linux
qm set $VMID --ostype l26  # Linux OS type

# Start the VM
qm start $VMID
echo "VM $VMID created and started successfully!"

# Wait for VM to initialize and install Nginx via SSH
sleep 30  # Allow some time for the VM to boot and complete setup

# Assuming we can SSH into the VM at a known IP (replace <IP_ADDRESS> with your VM’s IP)
IP_ADDRESS="192.168.1.20"
ssh root@192.168.1.20 <<EOF
  apt update -y
  apt install -y nginx
  systemctl enable nginx
  systemctl start nginx
EOF

echo "Nginx has been successfully installed on VM $VMID!"



