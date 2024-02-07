# resource "azurerm_public_ip" "ag-pip" {
#   name                = "ag-pip"
#   resource_group_name = azurerm_resource_group.k8s-rg.name
#   location            = azurerm_resource_group.k8s-rg.location
#   allocation_method   = "Static"
#   sku = "Standard"
# }

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.k8s-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.k8s-vnet.name}-feport"
  frontend_public_ip_configuration_name = "public-ip-configuration"
  frontend_private_ip_configuration_name = "private-ip-configuration"
  http_setting_name              = "${azurerm_virtual_network.k8s-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.k8s-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.k8s-vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.k8s-vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.appgw-rg.name
  location            = azurerm_resource_group.k8s-rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.ingress-appgateway-subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # identity {
  #   type = "UserAssigned"
  #   identity_ids  = [azurerm_user_assigned_identity.agic_identity.id]
  # }

  # frontend_ip_configuration {
  #   name                 = local.frontend_public_ip_configuration_name
  #   public_ip_address_id = azurerm_public_ip.ag-pip.id
  # }

  frontend_ip_configuration {
    name                 = local.frontend_private_ip_configuration_name
    private_ip_address   = "172.0.34.9"
    subnet_id            = azurerm_subnet.ingress-appgateway-subnet.id
    private_ip_address_allocation = "Static"
  }

  backend_address_pool {
    name = local.backend_address_pool_name

  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    # path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    # request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_private_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

# output "agic_identity_id" {
#   value = azurerm_user_assigned_identity.agic_identity.id
# }