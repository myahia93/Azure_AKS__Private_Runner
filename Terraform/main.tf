#TODO
# enable private endpoint pour l'ACR


# RESOURCE GROUPS
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location

  tags = local.tags
}
resource "azurerm_resource_group" "rg_ops" {
  name     = var.rg_ops_name
  location = var.location

  tags = local.tags
}
resource "azurerm_resource_group" "rg_net" {
  name     = var.rg_net_name
  location = var.location

  tags = local.tags
}

# VIRTUAL NETWORK
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg_net.name
  location            = azurerm_resource_group.rg_net.location
  address_space       = var.address_space

  tags = local.tags
}
resource "azurerm_subnet" "subnet" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.rg_net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}


# CONTAINER REGISTRY
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"

  tags = local.tags
}
resource "azurerm_private_endpoint" "pe-acr" {
  name                = "endpoint-${var.acr_name}"
  location            = azurerm_resource_group.rg_net.location
  resource_group_name = azurerm_resource_group.rg_net.name
  subnet_id           = azurerm_subnet.subnet.1.id

  private_service_connection {
    name                           = "acr-privateserviceconnection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

# KUBERNETES CLUSTER
resource "azurerm_kubernetes_cluster" "aks" {
  name                       = var.aks_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  private_cluster_enabled    = true
  dns_prefix_private_cluster = var.aks_name
  node_resource_group        = var.rg_node_name

  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name                = "agentpool"
    node_count          = 1
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
    enable_auto_scaling = false
    vnet_subnet_id      = azurerm_subnet.subnet.0.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}
resource "azurerm_role_assignment" "role_acrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}
resource "azurerm_network_security_group" "nodepool_nsg" {
  name                = "nsg-${var.aks_name}"
  resource_group_name = azurerm_resource_group.rg_net.name
  location            = azurerm_resource_group.rg_net.location

  tags = local.tags

  lifecycle {
    ignore_changes = all
  }
}
resource "azurerm_subnet_network_security_group_association" "nodepool_nsg_association" {
  depends_on                = [azurerm_network_security_group.nodepool_nsg]
  subnet_id                 = azurerm_subnet.subnet.0.id
  network_security_group_id = azurerm_network_security_group.nodepool_nsg.id
}


# KEY VAULT
resource "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = local.tags

  lifecycle {
    ignore_changes = all
  }
}
resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Set",
    "List",
    "Get",
    "Delete",
    "Purge",
    "Recover"
  ]
}
resource "azurerm_key_vault_access_policy" "kv_policy_aks" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.identity.0.principal_id

  secret_permissions = [
    "List",
    "Get",
  ]
}


# VM OPS
resource "azurerm_network_interface" "vm_ops_nic" {
  name                = "nic-${var.vm_name}"
  resource_group_name = azurerm_resource_group.rg_ops.name
  location            = azurerm_resource_group.rg_ops.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.2.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}
resource "azurerm_network_security_group" "vm_ops_nsg" {
  name                = "nsg-${var.vm_name}"
  resource_group_name = azurerm_resource_group.rg_ops.name
  location            = azurerm_resource_group.rg_ops.location

  tags = local.tags

  lifecycle {
    ignore_changes = all
  }
}
resource "azurerm_subnet_network_security_group_association" "vm_ops_nsg_association" {
  depends_on                = [azurerm_network_security_group.vm_ops_nsg]
  subnet_id                 = azurerm_subnet.subnet.2.id
  network_security_group_id = azurerm_network_security_group.vm_ops_nsg.id
}
resource "random_password" "vm_ops_admin" {
  length           = 30
  special          = true
  override_special = "_%?!#()-[]<>,;*@="
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}
resource "azurerm_key_vault_secret" "vm_ops_admin_password" {
  name         = "vm-ops-admin-password"
  value        = random_password.vm_ops_admin.result
  key_vault_id = azurerm_key_vault.kv.id
}
resource "azurerm_key_vault_secret" "vm_ops_admin_username" {
  name         = "vm-ops-admin-username"
  value        = var.vm_username
  key_vault_id = azurerm_key_vault.kv.id
}
resource "azurerm_linux_virtual_machine" "vm_ops" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg_ops.name
  location                        = azurerm_resource_group.rg_ops.location
  size                            = var.vm_size
  admin_username                  = azurerm_key_vault_secret.vm_ops_admin_username.value
  admin_password                  = azurerm_key_vault_secret.vm_ops_admin_password.value
  network_interface_ids           = [azurerm_network_interface.vm_ops_nic.id]
  disable_password_authentication = false

  os_disk {
    name                 = "disk-${var.vm_name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}


# BASTION
resource "azurerm_public_ip" "bastion_ip" {
  name                = var.bastion_ip_name
  resource_group_name = azurerm_resource_group.rg_net.name
  location            = azurerm_resource_group.rg_net.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                   = var.bastion_name
  resource_group_name    = azurerm_resource_group.rg_net.name
  location               = azurerm_resource_group.rg_net.location
  sku                    = "Standard"
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = true

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.subnet.3.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }

  tags = local.tags

  depends_on = [azurerm_public_ip.bastion_ip]
}
