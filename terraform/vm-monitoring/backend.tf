terraform {
  backend "azurerm" {
    resource_group_name = "rg-deployment-pr-001"
    storage_account_name = "stgtfcpmonpr001"
    container_name = "terraform"
    key = "vmmonitor.state"
    use_oidc = true
    client_id = "7c8d2589-ac03-47b8-ab7f-3de36798b9af"
    subscription_id = "b0fbba52-a0ae-4b41-85f0-11258598956e"
    tenant_id = "9b00ed4f-da1e-4ee4-beec-09a4ee32ad31"
    use_azuread_auth = true
  }
}