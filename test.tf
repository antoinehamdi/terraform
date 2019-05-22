provider "azurerm" {
}
resource "azurerm_resource_group" "rg" {
    name = "testResourceGroup"
    location = "westus"
}

resource "azurerm_resource_group" "rg2" {
    name = "testResourceGroup2"
    location = "eastus"
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["192.168.0.0/17"]
    location            = "westus"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_virtual_network" "myterraformnetwork2" {
    name                = "myVnet2"
    address_space       = ["192.168.128.0/17"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.rg2.name}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "myterraformsubnet1" {
    name                 = "mySubnet1"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "192.168.1.0/24"
}

resource "azurerm_subnet" "myterraformsubnet2" {
    name                 = "${var.test}"
    resource_group_name  = "${azurerm_resource_group.rg2.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork2.name}"
    address_prefix       = "192.168.129.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip" {
    count = 3
    name                         = "myPublicIP_${count.index}"
    location                     = "westus"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"
    domain_name_label            = "marwow219${count.index}"
    tags {
        environment = "Terraform Demo"
    }
}
resource "azurerm_public_ip" "myterraformpublicip2" {
    count = 2
    name                         = "myPublicIP_${count.index+3}"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.rg2.name}"
    allocation_method            = "Dynamic"
    domain_name_label            = "marwow219${count.index+3}"
    tags {
        environment = "Terraform Demo"
    }
}
resource "azurerm_network_security_group" "myterraformnsg" {
    count = 3
    name                = "myNetworkSecurityGroup__${count.index}"
    location            = "westus"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}


resource "azurerm_network_security_group" "myterraformnsg2" {
    count = 2
    name                = "myNetworkSecurityGroup__${count.index+3}"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.rg2.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    count = 3
    name                = "myNIC_${count.index}"
    location            = "westus"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_id = "${element(azurerm_network_security_group.myterraformnsg.*.id, count.index)}"

    ip_configuration {
        name                          = "myNicConfiguration_${count.index}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet1.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, count.index)}"
    }
}

resource "azurerm_network_interface" "myterraformnic2" {
    count = 2
    name                = "myNICK_${count.index}"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.rg2.name}"
    network_security_group_id = "${element(azurerm_network_security_group.myterraformnsg2.*.id, count.index)}"

    ip_configuration {
        name                          = "myNicConfiguration_${count.index}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet2.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip2.*.id, count.index+3)}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.rg.name}"
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount2" {
    name                = "diag2${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg2.name}"
    location            = "eastus"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location            = "westus"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}
resource "azurerm_virtual_machine" "myterraformvm" {
    count = 3
    name                  = "myVM_${count.index}"
    location              = "westus"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id, count.index)}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "myOsDisk${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm${count.index}"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/dClOwbFTW4A8s2HM7G4T342+ZCIvazQZUuHaFxY3xd3Pw71pqXeRwipsSQvtdCjziUtck7fsW4gIF37FF/g+L75fpMVq/f+xQgeQJUGz+ydTqN3dyUAArXmlgyXdNGl67uxbwEeE4feOOIuRgIt7Sg3IY+74bswNghdi1I5r1EwViC/dB1Hq2FNod9pcNyhIF2svCm/TFCTTDskxvz0w06VsU6wb9V0OYw5KMVeBTTww5Sxm/9o44k9bbXI+OiwKo5M4vsfOe/voXxIbke9HbM6yDzeQIYOfApiBI//O5uyw1HScUJV1USS3v7IVloGB8x9o/viVchAcjPbjm2+/ user02@pc-71.home"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_virtual_machine" "myterraformvm2" {
    count = 2
    name                  = "myVM_${count.index+3}"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.rg2.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic2.*.id, count.index)}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "myOsDisk${count.index+3}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm${count.index+3}"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/dClOwbFTW4A8s2HM7G4T342+ZCIvazQZUuHaFxY3xd3Pw71pqXeRwipsSQvtdCjziUtck7fsW4gIF37FF/g+L75fpMVq/f+xQgeQJUGz+ydTqN3dyUAArXmlgyXdNGl67uxbwEeE4feOOIuRgIt7Sg3IY+74bswNghdi1I5r1EwViC/dB1Hq2FNod9pcNyhIF2svCm/TFCTTDskxvz0w06VsU6wb9V0OYw5KMVeBTTww5Sxm/9o44k9bbXI+OiwKo5M4vsfOe/voXxIbke9HbM6yDzeQIYOfApiBI//O5uyw1HScUJV1USS3v7IVloGB8x9o/viVchAcjPbjm2+/ user02@pc-71.home"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount2.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}