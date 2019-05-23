mytag = "Terraform Demo"
ipallocationmethod = "Dynamic"
privateipallocationmethod = "Dynamic"
domainprefix = "marwaouh132"
ipprefix = "mypublicip_"
nsprefix = "mynetworksecuritygroup_"
nicprefix = "myNic_"
ipconfname = "mynicconf_"
vmprefix = "myVm_"
vmsize = "Standard_B1ms"
locations = [
    "eastus",
    "westus"
]

resourcegroups = [
    "rg1",
    "rg2"
]

networks = [
    "mynet1",
    "mynet2"
]

subnets = [
    "subnet1",
    "subnet2"
]

counts = [
    3,
    2
]

adressspaces = [
    "192.168.0.0/17",
    "192.168.128.0/17"
]

subadressspaces = [
    "192.168.1.0/24",
    "192.168.129.0/24"
]

name                       = "SSH"
priority                   = 1001
direction                  = "Inbound"
access                     = "Allow"
protocol                   = "Tcp"
source_port_range          = "*"
destination_port_range     = "22"
source_address_prefix      = "*"
destination_address_prefix = "*"

disknameprefix = "myOsDisk"
diskcachinge ="ReadWrite"
diskcreateoption ="FromImage"
diskmanagedtype ="Premium_LRS"
imagepublisher = "Canonical"
imageoffer = "UbuntuServer"
imagesku = "16.04.0-LTS"
imageversion = "latest"
osprofilenameprefix = "myvm"
adminusername = "azureuser"
sshpath = "/home/azureuser/.ssh/authorized_keys"
sshkeydata ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/dClOwbFTW4A8s2HM7G4T342+ZCIvazQZUuHaFxY3xd3Pw71pqXeRwipsSQvtdCjziUtck7fsW4gIF37FF/g+L75fpMVq/f+xQgeQJUGz+ydTqN3dyUAArXmlgyXdNGl67uxbwEeE4feOOIuRgIt7Sg3IY+74bswNghdi1I5r1EwViC/dB1Hq2FNod9pcNyhIF2svCm/TFCTTDskxvz0w06VsU6wb9V0OYw5KMVeBTTww5Sxm/9o44k9bbXI+OiwKo5M4vsfOe/voXxIbke9HbM6yDzeQIYOfApiBI//O5uyw1HScUJV1USS3v7IVloGB8x9o/viVchAcjPbjm2+/ user02@pc-71.home"