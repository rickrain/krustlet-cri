terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.77.0"
    }
  }
  required_version = "~> 1.1.3"
}

provider "azurerm" {
  features {}
}

locals {
  controlplane_name_prefix = "controlplane"
  worker_name_prefix       = "node"
}

resource "azurerm_resource_group" "demo_rg" {
  name     = var.resource_group_name
  location = var.location
}

module "virtual_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.demo_rg.name
  location            = azurerm_resource_group.demo_rg.location
  vnet_name           = var.vnet_name
  address_space       = ["10.0.1.0/24"]
  subnets = [
    { # Order of subnets is important!
      # If you re-order, update references below.
      name : "${local.controlplane_name_prefix}-subnet"
      address_prefixes : ["10.0.1.0/26"]
    },
    {
      name : "${local.worker_name_prefix}-subnet"
      address_prefixes : ["10.0.1.64/26"]
    }
  ]
}

module controlplane {
  source                  = "./modules/cluster_vm"
  name                    = local.controlplane_name_prefix
  vm_user                 = var.vm_user
  resource_group          = azurerm_resource_group.demo_rg.name
  location                = azurerm_resource_group.demo_rg.location
  vnet_id                 = module.virtual_network.vnet_id
  subnet_id               = module.virtual_network.subnet_ids["${local.controlplane_name_prefix}-subnet"]
  vm_shutdown_enabled     = true
  vm_shutdown_time_zone   = "Central Standard Time"
  vm_shutdown_time        = "1900"  # 7PM
  ssh_public_key_path     = var.ssh_public_key_path
}

resource "azurerm_virtual_machine_extension" "controlplane_vm_ext" {
  name                 = "${module.controlplane.vm_name}-ext"
  virtual_machine_id   = module.controlplane.vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "curl -sfL https://get.k3s.io | sh -"
    }
SETTINGS
}

# node01 will be a default k3s worker node. As such, it will use
# containerd as the container engine.
module node01 {
  source                  = "./modules/cluster_vm"
  name                    = "${local.worker_name_prefix}01"
  vm_user                 = var.vm_user
  resource_group          = azurerm_resource_group.demo_rg.name
  location                = azurerm_resource_group.demo_rg.location
  vnet_id                 = module.virtual_network.vnet_id
  subnet_id               = module.virtual_network.subnet_ids["${local.worker_name_prefix}-subnet"]
  vm_shutdown_enabled     = true
  vm_shutdown_time_zone   = "Central Standard Time"
  vm_shutdown_time        = "1900"  # 7PM
  ssh_public_key_path     = var.ssh_public_key_path
}

# node02 will also be part of the k3s worker node pool, but will use
# podman as the container engine.
module node02 {
  source                  = "./modules/cluster_vm"
  name                    = "${local.worker_name_prefix}02"
  vm_user                 = var.vm_user
  resource_group          = azurerm_resource_group.demo_rg.name
  location                = azurerm_resource_group.demo_rg.location
  vnet_id                 = module.virtual_network.vnet_id
  subnet_id               = module.virtual_network.subnet_ids["${local.worker_name_prefix}-subnet"]
  vm_shutdown_enabled     = true
  vm_shutdown_time_zone   = "Central Standard Time"
  vm_shutdown_time        = "1900"  # 7PM
  ssh_public_key_path     = var.ssh_public_key_path
}

resource "azurerm_virtual_machine_extension" "node02_vm_ext" {
  name                 = "${module.node02.vm_name}-ext"
  virtual_machine_id   = module.node02.vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "commandToExecute": ". /etc/os-release && sudo bash -c 'echo \"deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$${VERSION_ID}/ /\" > /etc/apt/sources.list.d/podman.list' && curl -L \"https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$${VERSION_ID}/Release.key\" -o key-data && sudo apt-key add key-data"
    }
SETTINGS
}
