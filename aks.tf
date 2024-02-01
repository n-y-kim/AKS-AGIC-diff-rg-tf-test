resource "azurerm_kubernetes_cluster" "k8s" {
  name = var.cluster_name
  location = azurerm_resource_group.k8s-rg.location
  resource_group_name = azurerm_resource_group.k8s-rg.name
  dns_prefix = var.dns_prefix
  kubernetes_version = "1.27.7"
  
  default_node_pool {
    name = "default"
    node_count = var.agent_count
    vm_size = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.node-subnet.id
    pod_subnet_id = azurerm_subnet.pod-subnet.id
  }
  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.network.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin = "azure"
  }
  tags = {
    Environment = "Development"
  }
}
