# ACR Task definition
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = var.tags
}

# ACR Task definition
resource "azurerm_container_registry_task" "build_app_image" {
  name                  = "build-${var.docker_image_name}-task"
  container_registry_id = azurerm_container_registry.main.id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path = "Dockerfile"
    image_names     = ["${var.docker_image_name}:${var.docker_image_tag}"]
    context_path    = "${trimsuffix(var.app_archive_blob_url, "/${var.app_archive_blob_name}")}?${var.app_archive_container_sas}"
    # Add context_access_token = null to satisfy schema requirement
    context_access_token = null
  }
  agent_setting {
    cpu = 2
  }
  tags = var.tags

  # Remove the entire 'trigger' block
  # The task will build implicitly on create/update
}
