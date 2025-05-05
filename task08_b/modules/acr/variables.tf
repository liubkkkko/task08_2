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

variable "acr_name" {
  type        = string
  description = "Name for the Azure Container Registry."
}

variable "acr_sku" {
  type        = string
  description = "SKU for the Azure Container Registry."
}

variable "docker_image_name" {
  type        = string
  description = "Name for the Docker image to be built."
}

variable "docker_image_tag" {
  type        = string
  description = "Tag for the Docker image."
}

variable "app_archive_blob_url" {
  type        = string
  description = "URL of the application archive blob in Azure Storage."
}

variable "app_archive_container_sas" {
  type        = string
  description = "SAS token granting read access to the storage container holding the archive."
  sensitive   = true
}

variable "app_archive_blob_name" {
  type        = string
  description = "Name of the blob archive file within the container."
}