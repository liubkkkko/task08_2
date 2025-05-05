resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  default_node_pool {
    name         = var.default_node_pool_name
    node_count   = var.default_node_pool_instance_count
    vm_size      = var.default_node_pool_vm_size
    os_disk_type = var.default_node_pool_os_disk_type
    # Ephemeral requires specific VM sizes and sufficient cache/temp disk space
    os_disk_size_gb = (var.default_node_pool_os_disk_type == "Ephemeral") ? null : 30 # Only set size for Managed
    # Enable Host Encryption if desired/supported
    # enable_host_encryption = true
    tags = var.tags
  }

  # Use System Assigned Identity for the cluster control plane and Kubelet
  identity {
    type = "SystemAssigned"
  }

  # Enable Azure Key Vault Secrets Provider Addon for CSI Driver
  key_vault_secrets_provider {
    secret_rotation_enabled = true
    # secret_rotation_interval = "2m" # Optional: configure rotation interval
  }

  # Network profile (default Kubenet is fine unless specific CNI needed)
  # Network profile (default Kubenet is fine unless specific CNI needed)
  network_profile {
    network_plugin = "kubenet"
    # Change "Standard" to "standard" (lowercase)
    load_balancer_sku = "standard"
  }

  # Optional: Enable RBAC (recommended)
  # role_based_access_control_enabled = true

  # Optional: Link Azure Monitor for logs/metrics
  # oms_agent {
  #   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id # Requires a Log Analytics Workspace
  # }

  # Enable CSI Storage Driver addon (implicitly enabled by key_vault_secrets_provider, but good to be explicit)
  storage_profile {
    snapshot_controller_enabled = true # Required by CSI Secret Store driver
  }

  # Ensure the Kubelet identity is enabled (used by CSI Secret Store Driver with useVMManagedIdentity: true)
  kubelet_identity {
    client_id                 = null # Not needed for SystemAssigned
    object_id                 = null # Not needed for SystemAssigned
    user_assigned_identity_id = null # Not needed for SystemAssigned
  }
}

# Grant AKS Kubelet Identity permission to pull from ACR
resource "azurerm_role_assignment" "aks_kubelet_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  # Use the principal ID of the Kubelet identity associated with the SystemAssigned identity
  principal_id = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# Grant AKS Kubelet Identity permission to get secrets from Key Vault (for CSI Driver)
resource "azurerm_key_vault_access_policy" "aks_kubelet_kv_access" {
  key_vault_id = var.kv_id
  tenant_id    = var.tenant_id
  # Use the principal ID of the Kubelet identity
  object_id = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id

  secret_permissions = [
    "Get", "List" # CSI driver needs Get, List might be helpful for debugging
  ]
}