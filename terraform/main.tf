terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "local_file" "cloud_init" {
  filename = "${path.module}/config/cloud_init.yml"
}

data "azurerm_image" "image_azdo_agent_pool" {
  name                = "image-azdo-agent-pool-20220522-13"
  resource_group_name = "rg-packer"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.suffix_resource_name}"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.suffix_resource_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet" {
  name                 = "snet-${var.suffix_resource_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.suffix_resource_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic_vm" {
  name                = "nic-${var.suffix_resource_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-${var.suffix_resource_name}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  admin_username                  = "AzDevOps"
  admin_password                  = var.vm_admin_passwd
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.image_azdo_agent_pool.id
  custom_data                     = base64encode(data.local_file.cloud_init.content)

  network_interface_ids = [
    azurerm_network_interface.nic_vm.id,
  ]

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

  tags = var.tags
}
