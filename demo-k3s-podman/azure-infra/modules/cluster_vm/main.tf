resource "azurerm_public_ip" "cluster_vm_pip" {
    name                         = "${var.name}-pip"
    location                     = var.location
    resource_group_name          = var.resource_group
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "cluster_vm_nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "vmNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cluster_vm_pip.id 
  }
}

resource "azurerm_network_security_group" "cluster_vm_nsg" {
    name                = "${var.name}-nsg"
    location            = var.location
    resource_group_name = var.resource_group
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.cluster_vm_nic.id
  network_security_group_id = azurerm_network_security_group.cluster_vm_nsg.id 
}

resource "azurerm_linux_virtual_machine" "cluster_vm" {
  name                            = "${var.name}-vm"
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.cluster_vm_nic.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = var.name
  admin_username                  = var.vm_user
  disable_password_authentication = true

  os_disk {
    name                 = "${var.name}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    public_key = file(var.ssh_public_key_path)
    username   = var.vm_user
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutdown_sched" {
  virtual_machine_id = azurerm_linux_virtual_machine.cluster_vm.id
  location           = azurerm_linux_virtual_machine.cluster_vm.location
  enabled            = var.vm_shutdown_enabled

  daily_recurrence_time = var.vm_shutdown_time
  timezone              = var.vm_shutdown_time_zone

  notification_settings {
    enabled         = false
  }
}