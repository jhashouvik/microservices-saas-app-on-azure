# >>> archly:node:agw1 >>>
output "agw1_id" {
  description = "azurerm_application_gateway id"
  value       = azurerm_application_gateway.agw1.id
  sensitive   = false
}
# <<< archly:node:agw1 <<<

# >>> archly:node:keyvault1 >>>
output "keyvault1_id" {
  description = "azurerm_manager id"
  value       = azurerm_manager.keyvault1.id
  sensitive   = false
}
# <<< archly:node:keyvault1 <<<

# >>> archly:node:dns1 >>>
output "dns1_id" {
  description = "azurerm_private id"
  value       = azurerm_private.dns1.id
  sensitive   = false
}
# <<< archly:node:dns1 <<<

# >>> archly:node:identity1 >>>
output "identity1_id" {
  description = "azurerm_identity_center id"
  value       = azurerm_identity_center.identity1.id
  sensitive   = false
}
# <<< archly:node:identity1 <<<

# >>> archly:node:firewall1 >>>
output "firewall1_id" {
  description = "azurerm_network_security_group id"
  value       = azurerm_network_security_group.firewall1.id
  sensitive   = false
}
# <<< archly:node:firewall1 <<<

# >>> archly:node:policy1 >>>
output "policy1_id" {
  description = "azurerm_policy id"
  value       = azurerm_policy.policy1.id
  sensitive   = false
}
# <<< archly:node:policy1 <<<

# >>> archly:node:defender1 >>>
output "defender1_id" {
  description = "azurerm_security_hub id"
  value       = azurerm_security_hub.defender1.id
  sensitive   = false
}
# <<< archly:node:defender1 <<<

# >>> archly:node:sql1_pe >>>
output "sql1_pe_id" {
  description = "azurerm_private_endpoint id"
  value       = azurerm_private_endpoint.sql1_pe.id
  sensitive   = false
}
# <<< archly:node:sql1_pe <<<

# >>> archly:node:redis1_pe >>>
output "redis1_pe_id" {
  description = "azurerm_private_endpoint id"
  value       = azurerm_private_endpoint.redis1_pe.id
  sensitive   = false
}
# <<< archly:node:redis1_pe <<<

# >>> archly:node:servicebus1_pe >>>
output "servicebus1_pe_id" {
  description = "azurerm_private_endpoint id"
  value       = azurerm_private_endpoint.servicebus1_pe.id
  sensitive   = false
}
# <<< archly:node:servicebus1_pe <<<

# >>> archly:node:blob1_pe >>>
output "blob1_pe_id" {
  description = "azurerm_private_endpoint id"
  value       = azurerm_private_endpoint.blob1_pe.id
  sensitive   = false
}
# <<< archly:node:blob1_pe <<<

# >>> archly:node:keyvault1_pe >>>
output "keyvault1_pe_id" {
  description = "azurerm_private_endpoint id"
  value       = azurerm_private_endpoint.keyvault1_pe.id
  sensitive   = false
}
# <<< archly:node:keyvault1_pe <<<