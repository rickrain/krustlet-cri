variable name {
  type = string
}

variable resource_group {
  type = string
}

variable location {
  type = string
}

variable vnet_id {
  description = "ID of the VNET where jumpbox VM will be installed"
  type        = string
}

variable subnet_id {
  description = "ID of subnet where jumpbox VM will be installed"
  type        = string
}

variable vm_user {
  description = "Admin user name"
  type        = string
}

variable ssh_public_key_path {
  description = "Path to ssh public key used to SSH into jumpbox"
  type        = string
}

variable vm_shutdown_enabled {
  description = "Enable VM shutdown on a schedule."
  type        = bool
}

variable vm_shutdown_time {
  description = "If vm_shutdown_enabled, the time of day (in military time) to shutdown the VM."
  type        = string
}

variable vm_shutdown_time_zone {
  description = "If vm_shutdown_enabled, the timezone for which to apply the vm_shutdown_time."
  type        = string
}