locals {
  # Use functions to ensure names are valid Azure resource names (alphanumeric, lowercase for some)
  # Replacing hyphens and potentially truncating if needed for specific resource types
  sanitized_prefix = lower(replace(var.name_prefix, "-", ""))

  rg_name               = "${var.name_prefix}-rg"
  redis_aci_name        = "${var.name_prefix}-redis-ci"
  sa_name               = "${local.sanitized_prefix}sa" # Storage account names need to be globally unique and lowercase alphanumeric
  keyvault_name         = "${var.name_prefix}-kv"
  acr_name              = "${local.sanitized_prefix}cr" # ACR names need to be globally unique and lowercase alphanumeric
  aca_env_name          = "${var.name_prefix}-cae"
  aca_name              = "${var.name_prefix}-ca"
  aks_name              = "${var.name_prefix}-aks"
  docker_image_name     = "${var.name_prefix}-app" # Name of the image in ACR
  app_archive_blob_name = "app.tar.gz"             # Name for the uploaded archive
}