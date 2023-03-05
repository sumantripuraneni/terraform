terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
   postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.15.0"
    }
  }
}

provider "azurerm" {
  features {}
}
