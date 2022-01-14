output vm_id {
  description = "Generated VM ID"
  value       = azurerm_linux_virtual_machine.cluster_vm.id
}

output vm_name {
  description = "Name of the VM"
  value       = azurerm_linux_virtual_machine.cluster_vm.name
}

