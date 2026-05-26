terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.74"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "core" {}