output "azurerm_postgresql_flexible_server_fqdn" {
  value = azurerm_postgresql_flexible_server.default.fqdn
}

output "azurerm_postgresql_flexible_server_admin_user" {
  value = azurerm_postgresql_flexible_server.default.administrator_login
}

output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_flexible_server_database.default.name
}
