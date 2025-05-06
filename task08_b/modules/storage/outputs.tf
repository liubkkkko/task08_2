output "id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "The Name of the Storage Account."
  value       = azurerm_storage_account.main.name
}

output "container_name" {
  description = "The name of the Storage Container."
  value       = azurerm_storage_container.main.name
}

output "blob_url" {
  description = "The URL of the uploaded application archive blob (without SAS)."
  value       = "${azurerm_storage_account.main.primary_blob_endpoint}${azurerm_storage_container.main.name}/${azurerm_storage_blob.app_archive.name}"
}

output "blob_sas_token" {
  description = "Shared Access Signature (SAS) token scoped for the application archive blob (query string)."
  value       = data.azurerm_storage_account_sas.app_archive_blob_sas.sas
  sensitive   = true
}

output "container_sas_token" {
  description = "Shared Access Signature (SAS) token for the storage container (query string)."
  value       = data.azurerm_storage_account_blob_container_sas.container_sas_for_acr_task_or_other_needs.sas
  sensitive   = true
}