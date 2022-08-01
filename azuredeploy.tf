#Hub Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = var.azure-rg-1
  location = var.loc1
  tags = {
    Environment = var.environment_tag
    Function    = "region1-eastus2-hub"
  }
}
#Spoke Resrouce Group
resource "azurerm_resource_group" "rg2" {
  name     = var.azure-rg-2
  location = var.loc1
  tags = {
    Environment = var.environment_tag
    Function    = "region1-eastus2-spoke"
  }
}

#VNETs and Subnets
#Hub VNET and Subnets
resource "azurerm_virtual_network" "region1-vnet1-hub1" {
  name                = var.region1-vnet1-name
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = [var.region1-vnet1-address-space]
  dns_servers         = ["10.10.1.4", "8.8.8.8"]
  tags = {
    Environment = var.environment_tag
    Function    = "region1-vnet1-hub"
  }
}
resource "azurerm_subnet" "region1-vnet1-snet1" {
  name                 = var.region1-vnet1-snet1-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snet1-range]
}
resource "azurerm_subnet" "region1-vnet1-snetfw" {
  name                 = var.region1-vnet1-snetfw-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snetfw-range]
}

#Spoke VNET and Subnets 
resource "azurerm_virtual_network" "region1-vnet2-spoke1" {
  name                = var.region1-vnet2-name
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = [var.region1-vnet2-address-space]
  dns_servers         = ["10.10.1.4", "8.8.8.8"]
  tags = {
    Environment = var.environment_tag
    Function    = "region1-vnet1-spoke"
  }
}
resource "azurerm_subnet" "region1-vnet2-snet1" {
  name                 = var.region1-vnet2-snet1-name
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.region1-vnet2-spoke1.name
  address_prefixes     = [var.region1-vnet2-snet1-range]
}
resource "azurerm_subnet" "region1-vnet2-snet2" {
  name                 = var.region1-vnet2-snet2-name
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.region1-vnet2-spoke1.name
  address_prefixes     = [var.region1-vnet2-snet2-range]
}
resource "azurerm_subnet" "region1-vnet2-snet3" {
  name                 = var.region1-vnet2-snet3-name
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.region1-vnet2-spoke1.name
  address_prefixes     = [var.region1-vnet2-snet3-range]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
#VNET Peering
resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "region1-vnet1-to-region1-vnet2"
  resource_group_name          = azurerm_resource_group.rg1.name
  virtual_network_name         = azurerm_virtual_network.region1-vnet1-hub1.name
  remote_virtual_network_id    = azurerm_virtual_network.region1-vnet2-spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "region1-vnet2-to-region1-vnet1"
  resource_group_name          = azurerm_resource_group.rg2.name
  virtual_network_name         = azurerm_virtual_network.region1-vnet2-spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.region1-vnet1-hub1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

#Lab NSG
resource "azurerm_network_security_group" "region1-nsg" {
  name                = "region1-nsg"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg2.name

  security_rule {
    name                       = "RDP-In"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.254.0/24"#change to firewall subnet
    destination_address_prefix = "*"
  }
  tags = {
    Environment = var.environment_tag
    Function    = "region1-spoke-nsg"
  }
}

#Create KeyVault ID
resource "random_id" "kvname" {
  byte_length = 5
  prefix      = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv1" {
  depends_on                  = [azurerm_resource_group.rg2]
  name                        = random_id.kvname.hex
  location                    = var.loc1
  resource_group_name         = var.azure-rg-2
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false #change to false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]
  }
  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-keyvault-1"
  }
  
  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    ip_rules = ["100.36.177.117"]
  }
}

#Create KeyVault VM password
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}
#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.kv1.id
  content_type = "password"
  expiration_date = "2022-12-30T20:00:00Z"
  depends_on   = [azurerm_key_vault.kv1]
}

#Create NIC and associate the private IP
resource "azurerm_network_interface" "region1-dc01-nic" {
  name                = "region1-dc01-nic"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg2.name


  ip_configuration {
    name                          = "region1-dc01-ipconfig"
    subnet_id                     = azurerm_subnet.region1-vnet2-snet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.4"
  }

  tags = {
    Environment = var.environment_tag
    Function    = "region1-dc01-nic"
  }
}
/*
#Create data disk for NTDS storage
resource "azurerm_managed_disk" "region1-dc01-data" {
	# checkov:skip=CKV_AZURE_93: AzureDiskEncryption.ps1 will generate a key vault and will encrypt VM once provisioned.
  name                 = "region1-dc01-data"
  location             = var.loc1
  resource_group_name  = azurerm_resource_group.rg2.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"
  max_shares           = "2"

  tags = {
    Environment = var.environment_tag
    Function    = "region1-dc01-data"
  }
}
*/
#Create Domain Controller VM
resource "azurerm_windows_virtual_machine" "region1-dc01-vm" {
	# checkov:skip=CKV_AZURE_50: The extension will be used to import scripts to enable feature for Active Directory Domain Services and setup AD infrastructure.
  name                = "region1-dc01-vm"
  depends_on          = [azurerm_key_vault.kv1]
  resource_group_name = azurerm_resource_group.rg2.name
  location            = var.loc1
  size                = var.vmsize-domaincontroller
  admin_username      = var.adminusername
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.region1-dc01-nic.id,
  ]

  tags = {
    Environment = var.environment_tag
    Function    = "region1-dc01-vm"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"

  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
/*
#Attach Data Disk to Virtual Machine
resource "azurerm_virtual_machine_data_disk_attachment" "region1-dc01-data" {
  managed_disk_id    = azurerm_managed_disk.region1-dc01-data.id
  depends_on         = [azurerm_windows_virtual_machine.region1-dc01-vm]
  virtual_machine_id = azurerm_windows_virtual_machine.region1-dc01-vm.id
  lun                = "10"
  caching            = "None"
}
*/
#Run setup script on dc01-vm - Domain Controller scripts
resource "azurerm_virtual_machine_extension" "region1-dc01-setup" {
  name                 = "AZVM-dc01-setup"
  virtual_machine_id   = azurerm_windows_virtual_machine.region1-dc01-vm.id
  #depends_on           = [azurerm_virtual_machine_data_disk_attachment.region1-dc01-data]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./DCSetup.ps1; exit 0;\""
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
        "fileUris": [
          "https://raw.githubusercontent.com/realnamesareboring/Azure-VM-POC/main/PowerShell/DCSetup.ps1"
        ]
    }
  SETTINGS
}

#Azure Disk Encryption script
resource "null_resource" "AzureDiskEncrypt" {
    depends_on = [azurerm_resource_group.rg2]
    triggers = {
        trigger = "${uuid()}"
    }

    provisioner "local-exec" {
        command = ".'${path.module}\\PowerShell\\AzureDiskEncryption.ps1'"
        interpreter = ["PowerShell", "-Command"]
    }
}

#Public IP for Azure Firewall
resource "azurerm_public_ip" "region1-fw01-pip" {
  name                = "region1-fw01-pip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment_tag
    Function    = "region1-fw01-pip"
  }
}
#Firewall Instance
resource "azurerm_firewall" "region1-fw01" {
  name                = "region1-fw01"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  #depends_on          = [azurerm_firewall_policy.region1-fw-pol01]
  
  
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.region1-vnet1-snetfw.id
    public_ip_address_id = azurerm_public_ip.region1-fw01-pip.id
  }
}

#Classic Rules
resource "azurerm_firewall_nat_rule_collection" "specific-range-rules" {
  name                = "RDP"
  azure_firewall_name = azurerm_firewall.region1-fw01.name
  resource_group_name = azurerm_resource_group.rg1.name
  priority            = 100
  action              = "Dnat"
  rule {
    name                  = "RDP"
    source_addresses      = ["*"]
    destination_addresses = [azurerm_public_ip.region1-fw01-pip.ip_address]
    destination_ports     = ["3389"]
    translated_port       = "3389"
    translated_address    = "10.1.1.4"
    protocols             = ["TCP"]
  }
}
/*
#Firewall Policy
resource "azurerm_firewall_policy" "region1-fw-pol01" {
  name                = "region1-firewall-policy01"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
}
*/