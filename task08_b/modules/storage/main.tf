# Data source to archive the application content
data "archive_file" "app_content" {
  type        = "tar.gz"
  source_dir  = var.app_content_path
  output_path = "${path.root}/app_content.tar.gz"
}

# Time resources for SAS token validity
resource "time_static" "sas_start_time" {
}

resource "time_offset" "sas_expiry_time" {
  offset_days  = 1
  base_rfc3339 = time_static.sas_start_time.rfc3339
}

# Azure Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  tags                     = var.tags
}

# Storage Container
resource "azurerm_storage_container" "main" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Blob (upload the archive)
resource "azurerm_storage_blob" "app_archive" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  type                   = "Block"
  source                 = data.archive_file.app_content.output_path

  depends_on = [data.archive_file.app_content]
}

# Data source to generate SAS token for the specific application archive BLOB
data "azurerm_storage_account_sas" "app_archive_blob_sas" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true # SAS is for a blob object
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  # CORRECTED: All required boolean permissions for azurerm_storage_account_sas
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false # Added
    filter  = false # Added
  }

  depends_on = [
    azurerm_storage_blob.app_archive,
    time_static.sas_start_time,
    time_offset.sas_expiry_time
  ]
}

# Data source to generate SAS token for the entire CONTAINER
data "azurerm_storage_account_blob_container_sas" "container_sas_for_acr_task_or_other_needs" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  container_name    = azurerm_storage_container.main.name
  https_only        = true

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }

  depends_on = [
    azurerm_storage_container.main,
    time_static.sas_start_time,
    time_offset.sas_expiry_time
  ]
}