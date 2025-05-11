# task08_b/modules/aks/main.tf

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  default_node_pool {
    name                   = var.default_node_pool_name
    node_count             = var.default_node_pool_instance_count
    vm_size                = var.default_node_pool_vm_size
    os_disk_type           = var.default_node_pool_os_disk_type
    os_disk_size_gb        = (var.default_node_pool_os_disk_type == "Ephemeral") ? null : 30 # Для керованих дисків, для Ephemeral розмір залежить від VM
    enable_host_encryption = false
    tags                   = var.tags
  }

  # Використовуємо одну User Assigned Managed Identity для всього кластера
  identity {
    type         = "UserAssigned"
    identity_ids = [var.kubelet_uami_id] 
  }

  # Блок kubelet_identity тут не потрібен, оскільки головний блок identity вже
  # налаштований на використання UAMI для всього кластера, включаючи Kubelet.

  key_vault_secrets_provider {
    secret_rotation_enabled = true
    # secret_rotation_interval = "5m" # Приклад, якщо потрібна часта ротація
  }
  
  network_profile {
    network_plugin    = "kubenet" # Або "azure" якщо потрібен Azure CNI
    load_balancer_sku = "standard"
  }
  
  # role_based_access_control_enabled = true # Зазвичай ввімкнено за замовчуванням для нових кластерів
  # http_application_routing_enabled = false # Зазвичай не потрібно, якщо не використовується addon
}