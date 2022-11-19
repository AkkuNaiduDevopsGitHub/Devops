terraform {
   backend "azurerm" {
    resource_group_name     = "rg-tf-storage-prod-uaen-001" 
      storage_account_name  = "saeosapprodtfstate001"
      container_name        = "tfstate-nonprod"
      key                   = "eononprod.tfstate"
     #access_key             = ""

   }
 }