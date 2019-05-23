provider "azurerm" {
}
resource "azurerm_resource_group" "rg" {
    name =  "${element(var.resourcegroups,0)}"
    location = "${element(var.locations,0)}"
}

resource "azurerm_resource_group" "rg2" {
    name =  "${element(var.resourcegroups,1)}"
    location = "${element(var.locations,1)}"
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "${element(var.networks,0)}"
    address_space       = ["${element(var.adressspaces,0)}"]
    location            = "${element(var.locations,0)}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    tags {
        environment = "${var.mytag}"
    }
}

resource "azurerm_virtual_network" "myterraformnetwork2" {
    name                = "${element(var.networks,1)}"
    address_space       = ["${element(var.adressspaces,1)}"]
    location            = "${element(var.locations,1)}"
    resource_group_name = "${azurerm_resource_group.rg2.name}"

    tags {
        environment = "${var.mytag}"
    }
}

resource "azurerm_subnet" "myterraformsubnet1" {
    name                 = "${element(var.subnets,0)}"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "${element(var.subadressspaces,0)}"
}

resource "azurerm_subnet" "myterraformsubnet2" {
    name                 = "${element(var.subnets,1)}"
    resource_group_name  = "${azurerm_resource_group.rg2.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork2.name}"
    address_prefix       = "${element(var.subadressspaces,1)}"
}

resource "azurerm_public_ip" "myterraformpublicip" {
    count = "${element(var.counts,0)}"
    name                         = "${var.ipprefix}${count.index}"
    location                     = "${element(var.locations,0)}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "${var.ipallocationmethod}"
    domain_name_label            = "${var.domainprefix}${count.index}"
    tags {
        environment = "${var.mytag}"
    }
}
resource "azurerm_public_ip" "myterraformpublicip2" {
    count = "${element(var.counts,1)}"
    name                         = "${var.ipprefix}${count.index+3}"
    location                     =  "${element(var.locations,1)}"
    resource_group_name          = "${azurerm_resource_group.rg2.name}"
    allocation_method            = "${var.ipallocationmethod}"
    domain_name_label            = "${var.domainprefix}${count.index+3}"
    tags {
        environment = "${var.mytag}"
    }
}
resource "azurerm_network_security_group" "myterraformnsg" {
    count = "${element(var.counts,0)}"
    name                = "${var.nsprefix}${count.index}"
    location            = "${element(var.locations,0)}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    
    security_rule {
        name                       = "${var.name}"
        priority                   = "${var.priority}"
        direction                  = "${var.direction}"
        access                     = "${var.access}"
        protocol                   = "${var.protocol}"
        source_port_range          = "${var.source_port_range}"
        destination_port_range     = "${var.destination_port_range}"
        source_address_prefix      = "${var.source_address_prefix}"
        destination_address_prefix = "${var.destination_address_prefix}"
    }

    tags {
        environment = "${var.mytag}"
    }
}


resource "azurerm_network_security_group" "myterraformnsg2" {
    count = "${element(var.counts,1)}"
    name                = "${var.nsprefix}${count.index+3}"
    location            = "${element(var.locations,1)}"
    resource_group_name = "${azurerm_resource_group.rg2.name}"
    
    security_rule {
        name                       = "${var.name}"
        priority                   = "${var.priority}"
        direction                  = "${var.direction}"
        access                     = "${var.access}"
        protocol                   = "${var.protocol}"
        source_port_range          = "${var.source_port_range}"
        destination_port_range     = "${var.destination_port_range}"
        source_address_prefix      = "${var.source_address_prefix}"
        destination_address_prefix = "${var.destination_address_prefix}"
    }

    tags {
        environment = "${var.mytag}"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    count = "${element(var.counts,0)}"
    name                = "${var.nicprefix}${count.index}"
    location            = "${element(var.locations,0)}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_id = "${element(azurerm_network_security_group.myterraformnsg.*.id, count.index)}"

    ip_configuration {
        name                          = "${var.ipconfname}${count.index}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet1.id}"
        private_ip_address_allocation = "${var.privateipallocationmethod}"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, count.index)}"
    }
}

resource "azurerm_network_interface" "myterraformnic2" {
    count = "${element(var.counts,1)}"
    name                = "${var.nicprefix}${count.index}"
    location            = "${element(var.locations,1)}"
    resource_group_name = "${azurerm_resource_group.rg2.name}"
    network_security_group_id = "${element(azurerm_network_security_group.myterraformnsg2.*.id, count.index)}"

    ip_configuration {
        name                          = "${var.ipconfname}${count.index}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet2.id}"
        private_ip_address_allocation = "${var.privateipallocationmethod}"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip2.*.id, count.index+3)}"
    }

    tags {
        environment = "${var.mytag}"
    }
}

/* resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.rg.name}"
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount2" {
    name                = "diag2${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg2.name}"
    location            = "${element(var.locations,1)}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "${var.mytag}"
    }
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location            = "${element(var.locations,0)}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "${var.mytag}"
    }
} */
resource "azurerm_virtual_machine" "myterraformvm" {
    count = "${element(var.counts,0)}"
    name                  = "${var.vmprefix}${count.index}"
    location              = "${element(var.locations,0)}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id, count.index)}"]
    vm_size               = "${var.vmsize}"

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

/*     boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    } */

    tags {
        environment = "${var.mytag}"
    }
}

resource "azurerm_virtual_machine" "myterraformvm2" {
    count = "${element(var.counts,1)}"
    name                  = "${var.vmprefix}${count.index+3}"
    location              = "${element(var.locations,1)}"
    resource_group_name   = "${azurerm_resource_group.rg2.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic2.*.id, count.index)}"]
    vm_size               = "${var.vmsize}"

    storage_os_disk {
        name              = "${var.disknameprefix}${count.index+3}"
        caching           = "${var.diskcachinge}"
        create_option     = "${var.diskcreateoption}"
        managed_disk_type = "${var.diskmanagedtype}"
    }

    storage_image_reference {
        publisher = "${var.imagepublisher}"
        offer     = "${var.imageoffer}"
        sku       = "${var.imagesku}"
        version   = "${var.imageversion}"
    }

    os_profile {
        computer_name  = "${var.osprofilenameprefix}${count.index+3}"
        admin_username = "${var.adminusername}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "${var.sshpath}"
            key_data = "${var.sshkeydata}"
        }
    }
/* 
    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount2.primary_blob_endpoint}"
    } */

    tags {
        environment = "${var.mytag}"
    }
}