terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.90.0"
    }
  }
}

provider "azurerm" {
    features {
      
    }
}

resource "azurerm_resource_group" "MAIN" {
    name = "testing"
    location = "eastus"
}

resource "azurerm_virtual_network" "MAIN" {
    name = "testing_vnet"
    location = "eastus"
    resource_group_name = "testing"
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "MAIN"{
    name = "testing_subnet"
    virtual_network_name = azurerm_virtual_network.MAIN.name
    resource_group_name = azurerm_resource_group.MAIN.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "internal" {
    name = "testing_nic"
    location = azurerm_resource_group.MAIN.location
    resource_group_name = azurerm_resource_group.MAIN.name
    
    ip_configuration {
      name ="internal"
      subnet_id = azurerm_subnet.MAIN.id
      private_ip_address_allocation = "Dynamic"
    }
  
}

resource "azurerm_windows_virtual_machine" "MAIN" {
    name = "testing-vm"
    resource_group_name = azurerm_resource_group.MAIN.name
    location = azurerm_resource_group.MAIN.location
    size = "Standard_B1s"
    admin_username = "caltman"
    admin_password ="Rehau123"

    network_interface_ids = [
        azurerm_network_interface.internal.id
    ]

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"

    }
    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer = "WindowsServer"
      sku = "2016-DataCenter"
      version = "latest"
    }
}