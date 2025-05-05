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

variable "aca_name" {
  type        = string
  description = "Name for the Azure Container App."
}

variable "aca_env_name" {
  type        = string
  description = "Name for the Azure Container App Environment."
}

variable "workload_profile_type" {
  type        = string
  description = "Workload profile type for the Container App Environment."
}

variable "kv_id" {
  type        = string
  description = "ID of the Azure Key Vault."
}

variable "kv_uri" {
  type        = string
  description = "URI of the Azure Key Vault."
}

variable "acr_id" {
  type        = string
  description = "ID of the Azure Container Registry."
}

variable "acr_login_server" {
  type        = string
  description = "Login server of the Azure Container Registry."
}

variable "docker_image_name" {
  type        = string
  description = "Name of the Docker image in ACR."
}

variable "docker_image_tag" {
  type        = string
  description = "Tag of the Docker image in ACR."
}

variable "redis_url_secret_name" {
  type        = string
  description = "Name of the Key Vault secret containing the Redis hostname."
}

variable "redis_password_secret_name" {
  type        = string
  description = "Name of the Key Vault secret containing the Redis password."
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID."
}