output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "name" {
  description = "The Name of the Key Vault."
  value       = azurerm_key_vault.main.name
}

output "uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "tenant_id" {
  description = "The Tenant ID associated with the Key Vault."
  value       = azurerm_key_vault.main.tenant_id
}