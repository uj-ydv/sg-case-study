output "id" {
  value = azurerm_cognitive_account.this.id
}

output "name" {
  value = azurerm_cognitive_account.this.name
}

output "endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}

output "project_id" {
  value = azurerm_cognitive_account_project.this.id
}

output "project_principal_id" {
  value = azurerm_cognitive_account_project.this.identity[0].principal_id
}
