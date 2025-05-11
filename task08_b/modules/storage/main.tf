data "archive_file" "app_content" {
  type        = "tar.gz"
  source_dir  = var.app_content_path
  output_path = "${path.root}/app_content.tar.gz" # Ensures path is in root of execution
}

resource "time_static" "sas_start_time" {
  triggers = {
    # Re-evaluate start time if the archive content changes,
    # this will help in generating a new SAS token for ACR task.
    app_archive_hash = data.archive_file.app_content.output_base64sha256
  }
}

resource "time_offset" "sas_expiry_time" {
  offset_days  = 1 # SAS token valid for 1 day
  base_rfc3339 = time_static.sas_start_time.rfc3339
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  tags                     = var.tags
}

resource "azurerm_storage_container" "main" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private" # As per task requirements
}

resource "azurerm_storage_blob" "app_archive" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  type                   = "Block"
  source                 = data.archive_file.app_content.output_path # Use the output_path from archive_file

  # Ensure this depends on the archive file being created
  depends_on = [data.archive_file.app_content]
}

# Data source to obtain a Shared Access Signature (SAS Token) for the specific Blob
data "azurerm_storage_account_sas" "app_archive_blob_sas" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true # SAS for the blob object
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  permissions {
    read    = true
    # Other permissions false as not needed for ACR task to read
    write   = false
    delete  = false
    list    = false # Not needed for a specific blob SAS
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }

  depends_on = [
    azurerm_storage_blob.app_archive, # SAS can only be generated after blob exists
    time_static.sas_start_time,       # And times are determined
    time_offset.sas_expiry_time
  ]
}

# SAS for container (not directly used by ACR task for specific blob context, but was in original code)
data "azurerm_storage_account_blob_container_sas" "container_sas_for_acr_task_or_other_needs" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  container_name    = azurerm_storage_container.main.name
  https_only        = true

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  permissions {
    read   = true
    list   = true # Often useful for container SAS if listing is needed
    add    = false
    create = false
    write  = false
    delete = false
  }
  depends_on = [
    azurerm_storage_container.main,
    time_static.sas_start_time,
    time_offset.sas_expiry_time
  ]
}