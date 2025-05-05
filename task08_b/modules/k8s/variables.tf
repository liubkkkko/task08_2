variable "acr_login_server" {
  type        = string
  description = "Login server of the Azure Container Registry."
}

variable "app_image_name" {
  type        = string
  description = "Name of the application's Docker image."
}

variable "image_tag" {
  type        = string
  description = "Tag of the application's Docker image."
}

variable "kv_name" {
  type        = string
  description = "Name of the Azure Key Vault."
}

variable "redis_url_secret_name" {
  type        = string
  description = "Name of the Key Vault secret for Redis hostname."
}

variable "redis_password_secret_name" {
  type        = string
  description = "Name of the Key Vault secret for Redis password."
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID."
}

variable "aks_kv_access_identity_id" {
  type        = string
  description = "Object ID of the identity AKS nodes use to access Key Vault (usually Kubelet Identity)."
}

variable "k8s_manifests_path" {
  type        = string
  description = "Path to the directory containing Kubernetes manifest templates."
}