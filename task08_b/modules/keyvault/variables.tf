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

variable "kv_name" {
  type        = string
  description = "Name of the Key Vault."
}

variable "sku_name" {
  type        = string
  description = "SKU for the Key Vault."
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID."
}

variable "current_user_object_id" {
  type        = string
  description = "Object ID of the current user/principal running Terraform (for access policy)."
}