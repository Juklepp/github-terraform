locals {
    workspaces_suffix = terraform.workspace == "default" ? "" : "${terraform.workspace}"

    rg-name = "${var.rg_name}-${local.workspaces_suffix}"
}

resource "azurerm_ressource_group" "rg" {
  name     = locals.rg_name
  location = var.rg_location
}

output "rg_name" {
  value = azurerm_ressource_group.rg.name
}

