resource "random_string" "random_string" {
  length  = 10
  special = false
  upper = false
}

# Resource Group
resource "azurerm_resource_group" "rg_web" {
  name     = var.rg_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "sa_web" {
  name                     = "${var.sa_name}${random_string.random_string.result}"
  resource_group_name      = azurerm_resource_group.rg_web.name
  location                 = azurerm_resource_group.rg_web.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = var.index_document
  }
}

#  index.html
resource "azurerm_storage_blob" "index_html" {
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.sa_web.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = var.source_content
}

output "primary_web_endpoint" {
  value = azurerm_storage_account.sa_web.primary_web_endpoint
}