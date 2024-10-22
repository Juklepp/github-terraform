terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.6.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-backend-tfstate-jk"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "sabetfsjkustm87h2u8"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "sc-backend-tfstate-jk"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "jkbackend.terraform.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}

provider "azurerm" {
  subscription_id = "3291a0d9-96b5-41ee-9b93-5b28b419919f"
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

resource "random_string" "random_string" {
  length  = 10
  special = false
  upper = false
}

resource "azurerm_resource_group" "rg_backend" {
  name     = var.rg_backend_name
  location = var.rg_backend_location
}

resource "azurerm_storage_account" "sa_backend" {
  name                     = "${lower(var.sa_backend_name)}${random_string.random_string.result}"
  resource_group_name      = var.rg_backend_name
  location                 = var.sa_backend_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "sc_backend" {
  name                  = var.sc_backend_name
  storage_account_name  = azurerm_storage_account.sa_backend.name
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv_backend" {
  name                        = "${var.kv_backend_name}${random_string.random_string.result}"
  location                    = var.kv_backend_location
  resource_group_name         = azurerm_resource_group.rg_backend.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get","List","Create",
    ]

    secret_permissions = [
      "Get","Set","List", "Delete", "Purge", "Recover",
    ]

    storage_permissions = [
      "Get","Set","List",
    ]
  }
}

resource "azurerm_key_vault_secret" "sa_backend_accesskey" {
  name         = var.sa_backend_accesskey_name
  value        = azurerm_storage_account.sa_backend.primary_access_key
  key_vault_id = azurerm_key_vault.kv_backend.id
}
