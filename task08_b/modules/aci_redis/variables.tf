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

variable "aci_name" {
  type        = string
  description = "Name for the Azure Container Instance group for Redis."
}

variable "aci_sku" {
  type        = string
  description = "SKU for the Azure Container Instance."
}

variable "kv_id" {
  type        = string
  description = "ID of the Azure Key Vault."
}

variable "redis_password_secret_name" {
  type        = string
  description = "Name for the Key Vault secret storing the Redis password."
}

variable "redis_hostname_secret_name" {
  type        = string
  description = "Name for the Key Vault secret storing the Redis hostname (FQDN)."
}