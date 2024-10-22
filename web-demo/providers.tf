terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.6.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-backend-tfstate-jk"  
    storage_account_name = "sabetfsjkustm87h2u8"                      
    container_name       = "sc-backend-tfstate-jk"                       
    key                  = "rgwebdemo.terraform.tfstate"        # Has to be globally unique
  }
}

provider "azurerm" {
  subscription_id = "3291a0d9-96b5-41ee-9b93-5b28b419919f"
  features {}
}