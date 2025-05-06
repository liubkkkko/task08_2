# modules/acr/main.tf

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false # Use Managed Identities or RBAC for image pull
  tags                = var.tags
}

resource "azurerm_container_registry_task" "build_app_image" {
  name                  = "build-${var.docker_image_name}-task"
  container_registry_id = azurerm_container_registry.main.id
  
  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    image_names          = ["${var.docker_image_name}:${var.docker_image_tag}"]
    context_path         = "${var.app_archive_blob_url}?${var.app_archive_blob_sas_token}"
    context_access_token = null # Required by schema, but null for blob SAS
  }

  # Only the timer_trigger is needed to ensure the task runs on creation/update
  # as the context (blob) changes or the task definition changes.
  timer_trigger {
    name     = "on-create-update-trigger" # A descriptive name
    schedule = "R1/2099-12-31T00:00:00Z"  # Effectively run once far in the future (triggered by creation/update of this resource)
    enabled  = true
  }

  # REMOVED source_trigger block as it's not needed for blob context and requires more args if present
  # REMOVED base_image_trigger block as it's not explicitly required by the task

  agent_setting { # Optional: configure agent if defaults are not suitable
    cpu = 2
  }
  
  tags = var.tags
}