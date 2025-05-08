provider "azurerm" {
  features {}
  subscription_id = "a7135c8f-934c-4000-b5b1-b09d6b645365"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.3.0"
}
