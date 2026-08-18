# TODO: fill in with the shared Terraform state storage account details.
# subscription_id is deliberately omitted here — pass it via
# -backend-config or ARM_SUBSCRIPTION_ID so state config isn't tied to one subscription.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-sg-tfstate"
    storage_account_name = "sg-platform-tfstate"
    container_name       = "tfstate"
    key                  = "uat.terraform.tfstate"
  }
}
