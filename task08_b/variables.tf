variable "name_prefix" {
  type        = string
  description = "Prefix for all resource names."
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
  default     = "uksouth" # Or choose another default region
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
}

variable "arm_client_id" {
  type        = string
  description = "Client ID for the Azure Service Principal (used for KV access policy)."
  sensitive   = true
}

# variable "arm_client_secret" { # Not strictly needed if using Azure CLI auth, but might be used for SP login
#   type        = string
#   description = "Client Secret for the Azure Service Principal."
#   sensitive = true
# }

variable "arm_subscription_id" {
  type        = string
  description = "Azure Subscription ID."
}

variable "arm_tenant_id" {
  type        = string
  description = "Azure Tenant ID."
}

variable "aci_redis_sku" {
  type        = string
  description = "SKU for the Azure Container Instance hosting Redis."
  default     = "Standard"
}

variable "storage_account_replication_type" {
  type        = string
  description = "Replication type for the Storage Account."
  default     = "LRS"
}

variable "storage_container_name" {
  type        = string
  description = "Name of the container within the Storage Account."
  default     = "app-content"
}

variable "keyvault_sku" {
  type        = string
  description = "SKU for the Azure Key Vault."
  default     = "standard"
}

variable "redis_password_secret_name" {
  type        = string
  description = "Name of the Key Vault secret for the Redis password."
  default     = "redis-password"
}

variable "redis_hostname_secret_name" {
  type        = string
  description = "Name of the Key Vault secret for the Redis hostname."
  default     = "redis-hostname"
}

variable "acr_sku" {
  type        = string
  description = "SKU for the Azure Container Registry."
  default     = "Basic"
}

variable "aca_workload_profile_type" {
  type        = string
  description = "Workload profile type for ACA and ACAE."
  default     = "Consumption"
}

variable "aks_default_node_pool_name" {
  type        = string
  description = "Name of the default node pool in AKS."
  default     = "system"
}

variable "aks_default_node_pool_instance_count" {
  type        = number
  description = "Number of instances in the default AKS node pool."
  default     = 1
}

variable "aks_default_node_pool_vm_size" {
  type        = string
  description = "VM size for the default AKS node pool instances."
  default     = "Standard_D2ads_v5"
}

variable "aks_default_node_pool_os_disk_type" {
  type        = string
  description = "OS disk type for the default AKS node pool."
  default     = "Ephemeral"
}

variable "docker_image_tag" {
  type        = string
  description = "Tag for the docker image."
  default     = "latest"
}

variable "app_source_code_path" {
  type        = string
  description = "Path to the application source code directory."
  default     = "./application"
}

variable "k8s_manifests_path" {
  type        = string
  description = "Path to the Kubernetes manifests directory."
  default     = "./k8s-manifests"
}