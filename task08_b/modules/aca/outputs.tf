output "fqdn" {
  description = "The FQDN of the Azure Container App."
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "identity_principal_id" {
  description = "The Principal ID of the User Assigned Identity created for ACA."
  value       = azurerm_user_assigned_identity.aca_identity.principal_id
}

output "id" {
  description = "The ID of the Azure Container App."
  value       = azurerm_container_app.main.id
}