resource "azurerm_resource_group" "k8s-rg" {
  count    = var.resource_count
  name     = "aks-rg-${count.index}"
  location = var.rg-location
}

resource "azurerm_resource_group" "appgw-rg" {
  count    = var.resource_count
  name     = "appgw-rg-${count.index}"
  location = var.rg-location
}

resource "azurerm_virtual_network" "k8s-vnet" {
  count = var.resource_count
  name                = "k8s-vnet"
  resource_group_name = azurerm_resource_group.k8s-rg[count.index].name
  location            = azurerm_resource_group.k8s-rg[count.index].location
  address_space       = ["172.0.0.0/16"]
}

resource "azurerm_subnet" "node-subnet" {
  count = var.resource_count
  name                 = "node-subnet"
  resource_group_name  = azurerm_resource_group.k8s-rg[count.index].name
  virtual_network_name = azurerm_virtual_network.k8s-vnet[count.index].name
  address_prefixes     = ["172.0.32.0/24"]
}

resource "azurerm_subnet" "pod-subnet" {
  count = var.resource_count
  name                 = "pod-subnet"
  resource_group_name  = azurerm_resource_group.k8s-rg[count.index].name
  virtual_network_name = azurerm_virtual_network.k8s-vnet[count.index].name
  address_prefixes     = ["172.0.48.0/20"]

  delegation {
    name = "aks-delegation"

    service_delegation {
        actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        name    = "Microsoft.ContainerService/managedClusters"
      }
  }
}

resource "azurerm_subnet" "ingress-appgateway-subnet" {
    count = var.resource_count
    name = "ingress-appgateway-subnet"
    resource_group_name = azurerm_resource_group.k8s-rg[count.index].name
    virtual_network_name = azurerm_virtual_network.k8s-vnet[count.index].name
    address_prefixes = ["172.0.34.0/24"]
}