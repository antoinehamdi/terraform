

data "azurerm_resource_group" "test" {
  name =   "tp3"
}
// terraform import azurerm_virtual_machine.test /subscriptions/1cc58a60-a375-42e0-a6ed-7116aae6845a/resourceGroups/tp3/providers/Microsoft.Compute/virtualMachines/tp3vm0

data "azurerm_virtual_network" "test" {
  name                = "tp3-vnet"
  resource_group_name = "tp3"
}


data "azurerm_subnet" "test" {
  name                 = "tp3subnet0"
  virtual_network_name = "${data.azurerm_virtual_network.test.name}"
  resource_group_name  = "tp3"
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "ip1"
    location                     = "westus"
    resource_group_name          = "tp3"
    allocation_method            = "${var.ipallocationmethod}"
    domain_name_label            = "${var.domainprefix}1121231"
}
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.nsprefix}1"
    location            = "westus"
    resource_group_name = "tp3"
    
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
}
resource "azurerm_network_interface" "myterraformnic" {
    name                = "${var.nicprefix}1"
    location            = "westus"
    resource_group_name = "tp3"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "${var.ipconfname}1"
        subnet_id                     = "${data.azurerm_subnet.test.id}"
        private_ip_address_allocation = "${var.privateipallocationmethod}"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }
}



resource "azurerm_virtual_machine" "newwebserver" {
  name                  = "newwebservervm1"
  location              = "westus"
  resource_group_name   = "tp3"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
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
}
