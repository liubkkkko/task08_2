# modules/aks/variables.tf

variable "location" {
  type        = string
  description = "Azure region."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "aks_name" {
  type        = string
  description = "Name for the Azure Kubernetes Service cluster."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the AKS cluster."
}

variable "default_node_pool_name" {
  type        = string
  description = "Name of the default node pool."
}

variable "default_node_pool_instance_count" {
  type        = number
  description = "Number of nodes in the default node pool."
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "VM size for nodes in the default node pool."
}

variable "default_node_pool_os_disk_type" {
  type        = string
  description = "OS Disk type for the default node pool ('Managed' or 'Ephemeral')."
}

variable "kv_id" {
  type        = string
  description = "ID of the Azure Key Vault."
}

variable "acr_id" {
  type        = string
  description = "ID of the Azure Container Registry."
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID."
}