name_prefix = "cmtr-13f58f43-mod8b"
location    = "uksouth" # Or your desired Azure region, ensure it's consistent

tags = {
  Creator = "liubomyr_puliak@epam.com"
}

storage_container_name     = "app-content"
redis_password_secret_name = "redis-password"
redis_hostname_secret_name = "redis-hostname"
# aks_default_node_pool_vm_size = "Standard_D2ads_v5" # Already default in variables.tf