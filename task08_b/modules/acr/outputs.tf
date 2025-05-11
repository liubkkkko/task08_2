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

output "acr_task_id" { # Додано для time_sleep
  description = "The ID of the ACR task."
  value       = azurerm_container_registry_task.build_app_image.id
}
output "task_id" {
  description = "The ID of the ACR task."
  value       = azurerm_container_registry_task.build_app_image.id
}