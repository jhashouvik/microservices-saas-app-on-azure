terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Recommended for production: store state remotely with locking, e.g.
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "mytfstateaccount"
  #   container_name        = "tfstate"
  #   key                   = "diagram-agent.tfstate"
  # }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "random_string" "archly_suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azurerm_resource_group" "archly" {
  name = var.resource_group_name
}

locals {
  resource_group_name = data.azurerm_resource_group.archly.name
  location            = data.azurerm_resource_group.archly.location
  name_suffix         = random_string.archly_suffix.result
}

# >>> archly:group:vnet1 >>>
# VNet (network boundary)

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = [var.vnet1_address_space]
}
# <<< archly:group:vnet1 <<<

# >>> archly:group:subnet1 >>>
# App Subnet (subnet within 'VNet')

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = [var.subnet1_address_prefix]
}
# <<< archly:group:subnet1 <<<

# >>> archly:group:subnet2 >>>
# Data Subnet (subnet within 'VNet')

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = [var.subnet2_address_prefix]
}
# <<< archly:group:subnet2 <<<

# >>> archly:group:subnet3 >>>
# Private Endpoint Subnet (subnet within 'VNet')

resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = [var.subnet3_address_prefix]
}
# <<< archly:group:subnet3 <<<

# >>> archly:group:azurefirewallsubnet >>>
# AzureFirewallSubnet (subnet within 'VNet')

resource "azurerm_subnet" "azurefirewallsubnet" {
  name                 = "azurefirewallsubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = [var.azurefirewallsubnet_address_prefix]
}
# <<< archly:group:azurefirewallsubnet <<<

# >>> archly:node:afd1 >>>
# Azure Front Door (cdn)
resource "azurerm_cdn_frontdoor_profile" "afd1_profile" {
  name                = "afd1-profile-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "afd1" {
  name                     = "afd1-${local.name_suffix}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd1_profile.id
}
# <<< archly:node:afd1 <<<

# >>> archly:node:agw1 >>>
# App Gateway WAF (network.application_gateway) -- belongs to subnet 'App Subnet' (see resource id 'subnet1' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_application_gateway" "agw1" {
  name = var.agw1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_application_gateway
  # and add every required argument before applying.
}
# <<< archly:node:agw1 <<<

# >>> archly:node:containerapps1 >>>
# Container Apps (compute.container) -- belongs to subnet 'App Subnet' (see resource id 'subnet1' above; wire this resource's subnet/network args to it manually)
resource "azurerm_log_analytics_workspace" "containerapps1_logs" {
  name                = "containerapps1-logs"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "containerapps1_env" {
  name                       = "containerapps1-env"
  location                   = local.location
  resource_group_name        = local.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.containerapps1_logs.id
}

resource "azurerm_container_app" "containerapps1" {
  name                         = "containerapps1"
  resource_group_name          = local.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.containerapps1_env.id
  revision_mode                = "Single"
  template {
    container {
      name   = "containerapps1"
      image  = var.containerapps1_container_image
      cpu    = 0.5
      memory = "1Gi"
    }
  }
}
# <<< archly:node:containerapps1 <<<

# >>> archly:node:sql1 >>>
# Azure SQL (database.relational) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
resource "azurerm_postgresql_flexible_server" "sql1" {
  name                   = "sql1-${local.name_suffix}"
  resource_group_name    = local.resource_group_name
  location               = local.location
  administrator_login    = var.sql1_administrator_login
  administrator_password = var.sql1_administrator_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  version                = "15"
}
# <<< archly:node:sql1 <<<

# >>> archly:node:redis1 >>>
# Cache for Redis (database.cache) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
resource "azurerm_redis_cache" "redis1" {
  name                = "redis1-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  # Access keys are generated by Azure and available as sensitive outputs
  # (azurerm_redis_cache.redis1.primary_access_key) -- never set them as input.
}
# <<< archly:node:redis1 <<<

# >>> archly:node:servicebus1 >>>
# Service Bus (queue) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
resource "azurerm_servicebus_namespace" "servicebus1_ns" {
  name                = "servicebus1-ns-${local.name_suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "servicebus1" {
  name         = "servicebus1"
  namespace_id = azurerm_servicebus_namespace.servicebus1_ns.id
}
# <<< archly:node:servicebus1 <<<

# >>> archly:node:blob1 >>>
# Blob Storage (storage.object) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
resource "azurerm_storage_account" "blob1" {
  name                     = substr("stblob1${local.name_suffix}", 0, 24)
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}
# <<< archly:node:blob1 <<<

# >>> archly:node:keyvault1 >>>
# Key Vault (secrets.manager)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_manager" "keyvault1" {
  name = var.keyvault1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_manager
  # and add every required argument before applying.
}
# <<< archly:node:keyvault1 <<<

# >>> archly:node:dns1 >>>
# Private DNS Zone (dns.private)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_private" "dns1" {
  name = var.dns1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_private
  # and add every required argument before applying.
}
# <<< archly:node:dns1 <<<

# >>> archly:node:identity1 >>>
# Microsoft Entra ID (auth.identity_center)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_identity_center" "identity1" {
  name = var.identity1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_identity_center
  # and add every required argument before applying.
}
# <<< archly:node:identity1 <<<

# >>> archly:node:monitor1 >>>
# Azure Monitor (monitoring)
resource "azurerm_log_analytics_workspace" "monitor1" {
  name                = "monitor1"
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
# <<< archly:node:monitor1 <<<

# >>> archly:node:loganalytics1 >>>
# Log Analytics (monitoring)
resource "azurerm_log_analytics_workspace" "loganalytics1" {
  name                = "loganalytics1"
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
# <<< archly:node:loganalytics1 <<<

# >>> archly:node:appinsights1 >>>
# Cosmos Db (database.nosql)
resource "azurerm_cosmosdb_account" "appinsights1" {
  name                = "appinsights1-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  offer_type          = "Standard"
  consistency_policy { consistency_level = "Session" }
  geo_location {
    location          = local.location
    failover_priority = 0
  }
}
# <<< archly:node:appinsights1 <<<

# >>> archly:node:firewall1 >>>
# Azure Firewall (network.security_group) -- belongs to subnet 'AzureFirewallSubnet' (see resource id 'azurefirewallsubnet' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_network_security_group" "firewall1" {
  name = var.firewall1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_network_security_group
  # and add every required argument before applying.
}
# <<< archly:node:firewall1 <<<

# >>> archly:node:policy1 >>>
# Azure Policy (governance.policy)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_policy" "policy1" {
  name = var.policy1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_policy
  # and add every required argument before applying.
}
# <<< archly:node:policy1 <<<

# >>> archly:node:defender1 >>>
# Defender for Cloud (security.security_hub)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_security_hub" "defender1" {
  name = var.defender1_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_security_hub
  # and add every required argument before applying.
}
# <<< archly:node:defender1 <<<

# >>> archly:node:sql1_pe >>>
# Azure SQL PE (network.private_endpoint) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_private_endpoint" "sql1_pe" {
  name = var.sql1_pe_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_private_endpoint
  # and add every required argument before applying.
}
# <<< archly:node:sql1_pe <<<

# >>> archly:node:redis1_pe >>>
# Cache for Redis PE (network.private_endpoint) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_private_endpoint" "redis1_pe" {
  name = var.redis1_pe_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_private_endpoint
  # and add every required argument before applying.
}
# <<< archly:node:redis1_pe <<<

# >>> archly:node:servicebus1_pe >>>
# Service Bus PE (network.private_endpoint) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_private_endpoint" "servicebus1_pe" {
  name = var.servicebus1_pe_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_private_endpoint
  # and add every required argument before applying.
}
# <<< archly:node:servicebus1_pe <<<

# >>> archly:node:blob1_pe >>>
# Blob Storage PE (network.private_endpoint) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_private_endpoint" "blob1_pe" {
  name = var.blob1_pe_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_private_endpoint
  # and add every required argument before applying.
}
# <<< archly:node:blob1_pe <<<

# >>> archly:node:keyvault1_pe >>>
# Key Vault PE (network.private_endpoint) -- belongs to subnet 'Private Endpoint Subnet' (see resource id 'subnet3' above; wire this resource's subnet/network args to it manually)
# Fallback scaffold: provider-specific mapping is not curated yet. Review and complete required arguments before applying.
resource "azurerm_private_endpoint" "keyvault1_pe" {
  name = var.keyvault1_pe_name
  resource_group_name = local.resource_group_name
  location            = local.location

  # TODO: Review the Terraform provider docs for azurerm_private_endpoint
  # and add every required argument before applying.
}
# <<< archly:node:keyvault1_pe <<<