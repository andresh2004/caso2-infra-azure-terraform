provider "azurerm" {
  features {}

  subscription_id = "019f3e29-306e-472e-b974-2557514ad775"
  tenant_id       = "899789dc-202f-44b4-8472-a6d40f9eb440"
}

# --------------------------------------
# Resource Group
# --------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-caso2-andres"
  location = "eastus"
}

# --------------------------------------
# Azure Container Registry (ACR)
# --------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "acrpracticoandres"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

# --------------------------------------
# Networking
# --------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-andres"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-andres"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip-andres"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-andres"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-andres"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

# 🔥 Nueva regla ─ HTTPS custom (8444)
  security_rule {
    name                       = "Allow-HTTPS-Custom"
    priority                   = 1002       # >1001 para no colisionar
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8444"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

# 🔥 Regla AKS ─ HTTPS custom (8080)
  security_rule {
    name                       = "Allow-HTTP-8080"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#---------------------------------------
# Virtual Machine Linux (Ubuntu 20.04)
# --------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-podman-andres"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "andresdev"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "andresdev"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmTkDic478mXDdOwY+einQ+WhvfKlro6BQp7JJaTnplf9dq1m1zTIL4fTPTG6dzAQbSULveS/oX8J3wsMkmIB+c7yk21fKXi9JDa01JREaYqxxFfv8t/AZwYsGKYbi21hVktMs4MMdwjeBwWpUB/J66qus1IKQsatGc8Z3q4EVstnLK5p9VpzDzmN48BT/PafHLQqLX2Fg3dVvaPREBfK5KjN3MlR+hATzn+KoKvhixy1axWqQOTUV+QqoWJxgoU/G1UJ1LfrUguO/ZHR488eKeq8BTit7kvP4taVzqxqjKXKdED+66mfpnrSkcskQWZ9D4RDIS/odRZj9jnbstlwKt7bScTkNW/onCfvK6oczbfHJFaUbJsEvHwaU/c2YQ9lvf8Y+ImYayYE8KSGtWIvQsYdk6jrV/cuAuEA9lgpe3YxLzUPhrW1bE5t17F8tdj4RRdHwhXtSO74Z7+ZFFCOtMfL/Dsupwr7GverrYwJlosBzQ9Pyf8jn/8mZLPVzGazMZBYqoawC6UJ+3qZXgfRPYQTtRmgnlAn1s2zTl2HP4bw9mePXu0xLJ42r/Zi/UcGcfrOg4QBmL6XMXy81XAlFJzfrQDGLhs+0W1FjQZtCi3wHGCY1bHmZydTwhozQyxaSCF+xC8TLaYfdhpLFi/+OgoNqMP0XS9cXq2gyG7b6Pw== andresdev@unir.net"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  disable_password_authentication = true
}


# Creacion del AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-caso2-andres"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksandres"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "dev"
  }
}

# Permitir que el AKS acceda al ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
