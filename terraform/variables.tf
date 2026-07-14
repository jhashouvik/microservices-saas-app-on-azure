variable "key_vault_id" {
  description = "Id of the Key Vault secrets should be written to (see the 'secrets' resource below if present)"
  type        = string
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name to create for this deployment"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant id"
  type        = string
}

# >>> archly:group:vnet1 >>>
variable "vnet1_address_space" {
  description = "Address space for VNet 'VNet'"
  type        = string
  default     = "10.0.0.0/16"
}
# <<< archly:group:vnet1 <<<

# >>> archly:group:subnet1 >>>
variable "subnet1_address_prefix" {
  description = "Address prefix for subnet 'App Subnet' (must fall within the VNet's address space)"
  type        = string
  default     = "10.0.1.0/24"
}
# <<< archly:group:subnet1 <<<

# >>> archly:group:subnet2 >>>
variable "subnet2_address_prefix" {
  description = "Address prefix for subnet 'Data Subnet' (must fall within the VNet's address space)"
  type        = string
  default     = "10.0.2.0/24"
}
# <<< archly:group:subnet2 <<<

# >>> archly:group:subnet3 >>>
variable "subnet3_address_prefix" {
  description = "Address prefix for subnet 'Private Endpoint Subnet' (must fall within the VNet's address space)"
  type        = string
  default     = "10.0.3.0/24"
}
# <<< archly:group:subnet3 <<<

# >>> archly:group:azurefirewallsubnet >>>
variable "azurefirewallsubnet_address_prefix" {
  description = "Address prefix for subnet 'AzureFirewallSubnet' (must fall within the VNet's address space)"
  type        = string
  default     = "10.0.4.0/24"
}
# <<< archly:group:azurefirewallsubnet <<<

# >>> archly:node:agw1 >>>
variable "agw1_name" {
  description = "Name for azurerm_application_gateway"
  type        = string
}
# <<< archly:node:agw1 <<<

# >>> archly:node:containerapps1 >>>
variable "containerapps1_container_image" {
  description = "Container image to deploy, e.g. myrepo/app:latest"
  type        = string
}
# <<< archly:node:containerapps1 <<<

# >>> archly:node:sql1 >>>
variable "sql1_administrator_login" {
  description = "Administrator login"
  type        = string
  default     = "sqladminuser"
}

variable "sql1_administrator_password" {
  description = "Administrator password -- supply via TF_VAR_sql1_administrator_password, never commit"
  type        = string
  sensitive   = true
}
# <<< archly:node:sql1 <<<

# >>> archly:node:keyvault1 >>>
variable "keyvault1_name" {
  description = "Name for azurerm_manager"
  type        = string
}
# <<< archly:node:keyvault1 <<<

# >>> archly:node:dns1 >>>
variable "dns1_name" {
  description = "Name for azurerm_private"
  type        = string
}
# <<< archly:node:dns1 <<<

# >>> archly:node:identity1 >>>
variable "identity1_name" {
  description = "Name for azurerm_identity_center"
  type        = string
}
# <<< archly:node:identity1 <<<

# >>> archly:node:firewall1 >>>
variable "firewall1_name" {
  description = "Name for azurerm_network_security_group"
  type        = string
}
# <<< archly:node:firewall1 <<<

# >>> archly:node:policy1 >>>
variable "policy1_name" {
  description = "Name for azurerm_policy"
  type        = string
}
# <<< archly:node:policy1 <<<

# >>> archly:node:defender1 >>>
variable "defender1_name" {
  description = "Name for azurerm_security_hub"
  type        = string
}
# <<< archly:node:defender1 <<<

# >>> archly:node:sql1_pe >>>
variable "sql1_pe_name" {
  description = "Name for azurerm_private_endpoint"
  type        = string
}
# <<< archly:node:sql1_pe <<<

# >>> archly:node:redis1_pe >>>
variable "redis1_pe_name" {
  description = "Name for azurerm_private_endpoint"
  type        = string
}
# <<< archly:node:redis1_pe <<<

# >>> archly:node:servicebus1_pe >>>
variable "servicebus1_pe_name" {
  description = "Name for azurerm_private_endpoint"
  type        = string
}
# <<< archly:node:servicebus1_pe <<<

# >>> archly:node:blob1_pe >>>
variable "blob1_pe_name" {
  description = "Name for azurerm_private_endpoint"
  type        = string
}
# <<< archly:node:blob1_pe <<<

# >>> archly:node:keyvault1_pe >>>
variable "keyvault1_pe_name" {
  description = "Name for azurerm_private_endpoint"
  type        = string
}
# <<< archly:node:keyvault1_pe <<<