provider "azurerm" {
  subscription_id = "param_sub"
  client_id       = "param_clid"
  client_secret   = "param_clst"
  tenant_id       = "param_tenant"
}

# Create a resource group
resource "azurerm_resource_group" "test" {
    name     = "test"
    location = "West Europe"
   
    tags {
    environment = "test"
  }
}

# Create a storage account resource group
resource "azurerm_resource_group" "azure_test_storage" {
    name = "resourceGroupName"
    location = "North Europe"
}

resource "azurerm_storage_account" "azure_storage_account" {
    name = "azurestorageaccount"
    resource_group_name = "${azurerm_resource_group.azure_test_storage.name}"

    location = "North Europe"
    account_type = "Standard_LRS"

    tags {
        environment = "production"
    }
}
#Create a container
resource "azurerm_storage_container" "azure_container_storage" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.azure_test_storage.name}"
    storage_account_name = "${azurerm_storage_account.azure_storage_account.name}"
    container_access_type = "private"
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "azure_test" {
  name = "azure_test"
    address_space = ["10.128.0.0/16"]
    location = "North Europe"

    subnet {
        name = "private"
        address_prefix = "10.128.1.0/24"
    }
    subnet {
        name = "public"
        address_prefix = "10.128.2.0/24"
  }
  resource_group_name = "${azurerm_resource_group.test.name}"
}
# Create a public ssh security group to access
resource "azurerm_network_security_group" "public_ssh" {
    name = "public_ssh"
    location = "North Europe"
    resource_group_name = "${azurerm_resource_group.test.name}"
}

# Create a private ssh security group to access
resource "azurerm_network_security_group" "private_ssh" {
    name = "private_ssh"
    location = "North Europe"
    resource_group_name = "${azurerm_resource_group.test.name}"
}

# Create a public security rule to allow access 
resource "azurerm_network_security_rule" "public_ssh_access" {
    name = "public_ssh_acces_rule"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "10.128.2.0/24"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_security_group_name = "${azurerm_network_security_group.public_ssh.name}"
}
# Create a private security rule to allow access 
resource "azurerm_network_security_rule" "private_ssh_access" {
    name = "private_ssh_acces_rule"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "10.128.2.0/24"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "10.128.2.0/24"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_security_group_name = "${azurerm_network_security_group.private_ssh.name}"
}