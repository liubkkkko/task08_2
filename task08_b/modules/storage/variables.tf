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

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account."
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the storage account."
}

variable "container_name" {
  type        = string
  description = "Name for the storage container."
}

variable "blob_name" {
  type        = string
  description = "Name for the storage blob (archive)."
}

variable "app_content_path" {
  type        = string
  description = "Path to the application content directory to archive."
}