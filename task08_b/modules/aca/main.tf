# User Assigned Identity for ACA
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "${var.aca_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Grant ACA Identity access to Key Vault secrets
resource "azurerm_key_vault_access_policy" "aca_kv_access" {
  key_vault_id = var.kv_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.aca_identity.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Grant ACA Identity access to pull images from ACR
resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Azure Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                = var.aca_env_name
  location            = var.location
  resource_group_name = var.resource_group_name
  # For Consumption Plan, log analytics workspace is managed implicitly
  # If using a Standard plan, you'd need:
  # log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id
  tags = var.tags
}

# Azure Container App
resource "azurerm_container_app" "main" {
  name                         = var.aca_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  # Use the User Assigned Identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  # Configure secrets referencing Key Vault using the assigned identity
  secret {
    name                = "redis-url" # Internal ACA secret name
    key_vault_secret_id = "${var.kv_uri}secrets/${var.redis_url_secret_name}"
    identity            = azurerm_user_assigned_identity.aca_identity.id
  }
  secret {
    name                = "redis-key" # Internal ACA secret name
    key_vault_secret_id = "${var.kv_uri}secrets/${var.redis_password_secret_name}"
    identity            = azurerm_user_assigned_identity.aca_identity.id
  }

  # Configure ACR access using the assigned identity
  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  # Allow external ingress
  ingress {
    external_enabled           = true
    target_port                = 8080 # Port the container listens on
    transport                  = "http"
    allow_insecure_connections = true # For http access

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "app-container" # Name for the container within the app
      image  = "${var.acr_login_server}/${var.docker_image_name}:${var.docker_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      # Define environment variables, referencing the ACA secrets
      env {
        name  = "CREATOR"
        value = "ACA"
      }
      env {
        name  = "REDIS_PORT"
        value = "6379"
      }
      env {
        name        = "REDIS_URL"
        secret_name = "redis-url" # Reference the internal ACA secret name
      }
      env {
        name        = "REDIS_PWD"
        secret_name = "redis-key" # Reference the internal ACA secret name
      }
    }
    # Define scaling rules for Consumption plan (optional, defaults are usually fine)
    # min_replicas = 0
    # max_replicas = 1
  }

  depends_on = [
    azurerm_role_assignment.aca_acr_pull,
    azurerm_key_vault_access_policy.aca_kv_access,
    azurerm_container_app_environment.main
    # Implicit dependency on ACR image existing via depends_on in root module
  ]
}