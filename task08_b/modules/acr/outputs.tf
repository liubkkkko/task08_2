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

output "task_id" {
  description = "The ID of the ACR task definition."
  value       = azurerm_container_registry_task.build_app_image.id
}

# Додаємо вихід для ресурсу запуску, щоб на нього можна було посилатися
output "task_initial_run_id" {
  description = "The ID of the ACR task initial schedule run now resource."
  value       = azurerm_container_registry_task_schedule_run_now.trigger_initial_build.id
}