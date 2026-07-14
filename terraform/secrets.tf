# >>> archly:node:sql1 >>>
# Secrets manager entry for Azure SQL
resource "azurerm_key_vault_secret" "sql1_password" {
  name         = "sql1-db-password"
  value        = var.sql1_administrator_password
  key_vault_id = var.key_vault_id
}
# <<< archly:node:sql1 <<<