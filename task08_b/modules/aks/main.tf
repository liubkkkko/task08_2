resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  default_node_pool {
    name                        = var.default_node_pool_name
    node_count                  = var.default_node_pool_instance_count
    vm_size                     = var.default_node_pool_vm_size
    os_disk_type                = var.default_node_pool_os_disk_type
    os_disk_size_gb             = (var.default_node_pool_os_disk_type == "Ephemeral") ? null : 30
    enable_host_encryption      = false
    tags                        = var.tags
    temporary_name_for_rotation = "temp${replace(var.default_node_pool_name, "-", "")}"
  }

  identity {
    type = "UserAssigned"
    # Це UAMI, яка буде використовуватися для control plane AKS, 
    # а також для Kubelet, якщо kubelet_identity не вказано явно, АЛЕ, як ми бачили, це не завжди так.
    identity_ids = [var.kubelet_uami_id]
  }

  # Явно вказуємо Kubelet identity на нашу створену UAMI
  kubelet_identity { # Явно вказуємо цю ж UAMI для Kubelet
    client_id                 = var.kubelet_uami_client_id
    object_id                 = var.kubelet_uami_object_id
    user_assigned_identity_id = var.kubelet_uami_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}