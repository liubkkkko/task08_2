output "redis_fqdn" {
  description = "FQDN of Redis in Azure Container Instance"
  value       = module.aci_redis.fqdn
}

output "aca_fqdn" {
  description = "FQDN of App in Azure Container App"
  value       = module.aca.fqdn
}

output "aks_lb_ip" {
  description = "Load Balancer IP address of APP in AKS"
  value       = module.k8s.load_balancer_ip
}


# Додані для зручності діагностики kubectl
output "rg_name" {
  description = "Name of the main resource group."
  value       = azurerm_resource_group.main.name
}

output "aks_name" {
  description = "Name of the AKS cluster."
  # Припускаємо, що модуль aks має вихід "name" або ви використовуєте local.aks_name
  # Якщо модуль aks називається aks_cluster, то може бути module.aks.aks_cluster_name
  # Перевірте, як називається вихідне ім'я AKS у вашому модулі aks/outputs.tf
  # або використовуйте local.aks_name, якщо воно там визначено.
  # Для прикладу, я припущу, що у вас є local.aks_name в кореневому locals.tf
  value = local.aks_name 
}