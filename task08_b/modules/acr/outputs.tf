output "id" {
  description = "The ID of the Azure Container Registry."
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "The Name of the Azure Container Registry."
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "The Login Server endpoint of the Azure Container Registry."
  value       = azurerm_container_registry.main.login_server
}