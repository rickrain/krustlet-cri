variable "location" {
  description = "The Azure region to deploy in"
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The resource group name, which will contain the k8s controlplane and worker nodes"
  default     = "krustlet-cri-demo-rg"
}

variable "vnet_name" {
  description = "The virtual network name"
  default     = "tinyedge-vnet"
}

variable "vm_size" {
  description = "Default VM size for controlplane and worker nodes"
  default     = "Standard_D2_v2"
}

variable "vm_user" {
  description = "Admin user name - same for all VM's"
  type        = string
  default     = "tinyedge"
}

variable ssh_public_key_path {
  description = "Path to ssh public key used to SSH into VM's"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}