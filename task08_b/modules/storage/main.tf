# Data source to archive the application content
data "archive_file" "app_content" {
  type        = "tar.gz" # Use tar.gz as requested
  source_dir  = var.app_content_path
  output_path = "${path.root}/app_content.tar.gz" # Temporary path for the archive file
}

# Time resources for SAS token validity
resource "time_static" "sas_start_time" {
  # Keep the start time constant across applies unless destroyed
}

resource "time_offset" "sas_expiry_time" {
  offset_days  = 1 # SAS token valid for 1 day
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
  container_access_type = "private" # As requested
}

# Storage Blob (upload the archive)
resource "azurerm_storage_blob" "app_archive" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  type                   = "Block"
  source                 = data.archive_file.app_content.output_path # Use the path from the archive data source

  # Ensure the archive is created before trying to upload
  depends_on = [data.archive_file.app_content]
}

# Data source to generate SAS token for the container (needed by ACR Task)
data "azurerm_storage_account_sas" "container_sas" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  # Use 'start' and 'expiry' instead of 'start_date'/'expiry_date'
  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  # Define ALL permissions explicitly
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false # Explicitly add required boolean
    filter  = false # Explicitly add required boolean
  }

  depends_on = [
    azurerm_storage_account.main,
    time_static.sas_start_time,
    time_offset.sas_expiry_time
  ]
}

# Data source to construct the full blob URL needed by ACR Task
data "azurerm_storage_account_blob_container_sas" "app_blob_sas_for_acr" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  container_name    = azurerm_storage_container.main.name
  https_only        = true

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  # Define ALL permissions explicitly
  permissions {
    read   = true
    add    = false # Explicitly add required boolean
    create = false # Explicitly add required boolean
    write  = false # Explicitly add required boolean
    delete = false # Explicitly add required boolean
    list   = true
    # Note: 'tag' and 'move' might also be required in newer provider versions or specific scenarios,
    # but based on the error message, these are the missing ones. Add them if validate still complains.
    # tag = false
    # move = false
  }

  depends_on = [
    azurerm_storage_blob.app_archive, # Ensure blob exists
    time_static.sas_start_time,
    time_offset.sas_expiry_time
  ]
}