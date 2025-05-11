terraform {
  required_version = ">= 1.5.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5" # Task didn't specify, ~> 3.5 or ~> 3.6 is fine
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4" # Task didn't specify, ~> 2.4 is fine
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9" # Task didn't specify, ~> 0.9 or ~> 0.11 is fine
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14" # Task didn't specify, ~> 1.14 is fine
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23" # Task didn't specify, ~> 2.20 or newer usually fine
    }
  }
}

provider "azurerm" {
  features {}
  # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
  # are expected to be set as environment variables for Service Principal auth.
  # If using Azure CLI auth, ensure `az login` is done.
}

# Provider configurations using outputs from AKS module
# These will be configured once the AKS module provides the necessary outputs
provider "kubernetes" {
  alias                  = "kubernetes" # Explicit alias
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
}

provider "kubectl" {
  alias                  = "kubectl" # Explicit alias
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  load_config_file       = false # Important: prevent loading from default kubeconfig file
}