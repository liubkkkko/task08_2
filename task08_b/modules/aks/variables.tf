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

variable "kubelet_uami_id" {
  type        = string
  description = "The ID of the User Assigned Managed Identity to be used by AKS (for Control Plane and Kubelet)."
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID."
}

# ВИДАЛЕНО: змінна key_vault_secrets_provider_enabled, оскільки вона не використовується.
# variable "key_vault_secrets_provider_enabled" {
#   description = "Flag to indicate if key_vault_secrets_provider is configured."
#   type        = bool
#   default     = true 
# }
variable "kubelet_uami_client_id" {
  type        = string
  description = "The Client ID of the User Assigned Managed Identity explicitly assigned to Kubelet."
}

variable "kubelet_uami_object_id" {
  type        = string
  description = "The Object ID (Principal ID) of the User Assigned Managed Identity explicitly assigned to Kubelet."
}