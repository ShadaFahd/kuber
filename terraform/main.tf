# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_A2_v2"
    vnet_subnet_id  = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16" # ملاحظة: هذه الخاصية ستُزال مستقبلًا، لكن يمكن تجاهل التحذير الآن
  }

  node_resource_group = "DevOps1-week10-shada-aks-nodes"

  tags = {
    Environment = "Dev"
  }

  depends_on = [
    azurerm_subnet.subnet
  ]
}

# SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "YourStrongP@ssw0rd"
  minimum_tls_version          = "1.2"
}

# SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"
  max_size_gb    = 2

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

# SQL Firewall Rule
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzure"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

