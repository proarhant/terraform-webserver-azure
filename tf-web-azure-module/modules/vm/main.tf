# The Terraform module to create a "Hello World!" page on CentOS based Nginx webserver

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}_rg"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "terraweb_vnet" {
  name                = "${var.prefix}_vnet"
  address_space       = [var.cidr_vnet]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "terraweb_subnet" {
  name                 = "${var.prefix}_subnet"
  virtual_network_name = azurerm_virtual_network.terraweb_vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.cidr_subnet]
}

# Create network security group and rules   
resource "azurerm_network_security_group" "terraweb_nsg" {
  name                = "${var.prefix}_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "Egress Traffic"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Outgoing traffic"
  }
  
    security_rule {
    name                       = "Ingress"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "SSH-HTTP-HTTPS Ingress traffic"
  }
  tags = {
    Name = "Rules for SSH, HTTP, and HTTPS"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  network_security_group_id = azurerm_network_security_group.terraweb_nsg.id
  subnet_id                 = azurerm_subnet.terraweb_subnet.id
}

# Create public IPs
resource "azurerm_public_ip" "terrawebpublicip" {
  name                = "${var.prefix}_publicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    webip = "Public IP for the WebSite"
  }
}

# Create network interface
resource "azurerm_network_interface" "terrawebnic" {
  name                = "${var.prefix}_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_nicconfiguration"
    subnet_id                     = azurerm_subnet.terraweb_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terrawebpublicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.terrawebnic.id
  network_security_group_id = azurerm_network_security_group.terraweb_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "terrawebvm" {
  name                            = "${var.prefix}-${var.vm_name}"
  computer_name                   = "${var.prefix}-${var.host_name}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.terrawebnic.id]
  size                            = var.vm_size
  admin_username                  = var.image_publisher[var.image].admin
  disable_password_authentication = true
  provision_vm_agent              = true
  custom_data                     = base64encode("${file(var.user_data)}")

  source_image_reference {
    publisher = var.image_publisher[var.image].publisher
    offer     = var.image_publisher[var.image].offer
    sku       = var.image_publisher[var.image].sku
    version   = "latest"
  }
  
      os_disk {
    name                 = "${var.prefix}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size
  }

  admin_ssh_key {
    username   = var.image_publisher[var.image].admin
    public_key = file("./id_rsa_tfadmin.pub")
  }

   tags = {
    environment = "SANDPIT"
  }
}
