#Resource Groups
resource "azurerm_resource_group" "rg1" {
  name     = var.azure-rg-1
  location = var.loc1
  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-POC-RG-1"
  }
}
#Resource Groups
resource "azurerm_resource_group" "rg2" {
  name     = var.azure-rg-2
  location = var.loc1
  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-POC-RG-2"
  }
}
/* Working
#Test powershell script
resource "null_resource" "PowerShellScriptRunAlways" {
    triggers = {
        trigger = "${uuid()}"
    }

    provisioner "local-exec" {
        command = ".'${path.module}\\PowerShell\\AzureDiskEncryption.ps1'"
        interpreter = ["PowerShell", "-Command"]
    }
}
*/

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
    Function    = "AZFW-vnet"
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
/* may not need
resource "azurerm_subnet" "region1-vnet1-snet2" {
  name                 = var.region1-vnet1-snet2-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snet2-range]
}
resource "azurerm_subnet" "region1-vnet1-snet3" {
  name                 = var.region1-vnet1-snet3-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snet3-range]
}
*/
# TESTING VAULT - DISABLED 7/27
#Spoke VNET and Subnets 
resource "azurerm_virtual_network" "region1-vnet2-spoke1" {
  name                = var.region1-vnet2-name
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = [var.region1-vnet2-address-space]
  dns_servers         = ["10.10.1.4", "8.8.8.8"]
  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-vnet"
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
#modified protocol and source_address_prefix on 7/25
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
    Function    = "AZVM-security"
  }
}
/* DONT UNCOMMENT
#NSG Association to all Lab Subnets

resource "azurerm_subnet_network_security_group_association" "vnet1-snet1" {
  subnet_id                 = azurerm_subnet.region1-vnet1-snet1.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet2" {
  subnet_id                 = azurerm_subnet.region1-vnet1-snet2.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet3" {
  subnet_id                 = azurerm_subnet.region1-vnet1-snet3.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet2-snet1" {
  subnet_id                 = azurerm_subnet.region1-vnet2-snet1.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet2-snet2" {
  subnet_id                 = azurerm_subnet.region1-vnet2-snet2.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
*/

#Create KeyVault ID
resource "random_id" "kvname" {
  byte_length = 5
  prefix      = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv1" {
  depends_on                  = [azurerm_resource_group.rg2] #change to rg2
  name                        = random_id.kvname.hex
  location                    = var.loc1
  resource_group_name         = var.azure-rg-2 #change to rg2
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
    Function    = "AZVM-security"
  }
  #added 7/25
  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    ip_rules = ["100.36.177.117"] #added 7/25
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
  content_type = "password" #added 07/25
  expiration_date = "2022-12-30T20:00:00Z" #added 7/25
  depends_on   = [azurerm_key_vault.kv1]
}
/*
# TESTING VAULT - DISABLED 7/27

#Key Vault for Disk Encryption - Added 7/26
# TESTING VAULT - DISABLED 7/28
#Create KeyVault ID
resource "random_id" "kvname2" {
  byte_length = 5
  prefix      = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current2" {}
resource "azurerm_key_vault" "kv2" {
  depends_on                  = [azurerm_resource_group.rg2] #change to rg2
  name                        = random_id.kvname2.hex
  location                    = var.loc1
  resource_group_name         = var.azure-rg-2 #change to rg2
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current2.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false #change to false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current2.tenant_id
    object_id = data.azurerm_client_config.current2.object_id

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
    Function    = "AZVM-DE"
  }
  #added 7/25
  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    ip_rules = ["100.36.177.117"] #added 7/25
  }
}

# Disk Encryption Key Vault - EOL (Working. Create random name for vault)


#Azure Disk Encryption Set - Added 7/25

resource "azurerm_key_vault_key" "des-key" {
  name         = "des-vm-key"
  key_vault_id = azurerm_key_vault.kv2.id
  key_type     = "RSA-HSM"
  key_size     = 2048
  expiration_date = "2022-12-30T20:00:00Z" #added 7/26

  depends_on = [
    azurerm_key_vault_access_policy.encrypt-disk
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
#change to key_vault_key_id to reflect des vault
resource "azurerm_disk_encryption_set" "des-encryptset" {
  name                = "des"
  resource_group_name = var.azure-rg-2 
  location            = var.loc1
  key_vault_key_id    = azurerm_key_vault.kv2.id

  identity {
    type = "SystemAssigned"
  }
}
#change to key_vault_id to reflect des vault
resource "azurerm_key_vault_access_policy" "encrypt-disk" {
  key_vault_id = azurerm_key_vault.kv2.id

  tenant_id = azurerm_disk_encryption_set.des-encryptset.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.des-encryptset.identity.0.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign"
  ]
}
#change to key_vault_id to reflect des vault
resource "azurerm_key_vault_access_policy" "accesspolicy-user" {
  key_vault_id = azurerm_key_vault.kv2.id

  tenant_id = data.azurerm_client_config.current2.tenant_id
  object_id = data.azurerm_client_config.current2.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign"
  ]
}
# added disk encryption set - 7/25 EOL
*/
/* DONT UNCOMMENT
#Public IP
resource "azurerm_public_ip" "region1-dc01-pip" {
  name                = "region1-dc01-pip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-activedirectory"
  }
}
*/
#TESTING VAULT - DISABLED 7/27
#DONT UNCOMMENT
#Public IP
#Create NIC and associate the Public IP
resource "azurerm_network_interface" "region1-dc01-nic" {
  name                = "region1-dc01-nic"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg2.name


  ip_configuration {
    name                          = "region1-dc01-ipconfig"
    subnet_id                     = azurerm_subnet.region1-vnet2-snet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.4"
    #public_ip_address_id          = azurerm_public_ip.region1-dc01-pip.id
  }

  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-activedirectory"
  }
}

#Create data disk for NTDS storage
resource "azurerm_managed_disk" "region1-dc01-data" {
  name                 = "region1-dc01-data"
  location             = var.loc1
  resource_group_name  = azurerm_resource_group.rg2.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"
  max_shares           = "2"

  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-activedirectory"
  }
}
#Create Domain Controller VM
resource "azurerm_windows_virtual_machine" "region1-dc01-vm" {
  name                = "region1-dc01-vm"
  depends_on          = [azurerm_key_vault.kv1]
  resource_group_name = azurerm_resource_group.rg2.name #change to rg2
  location            = var.loc1
  size                = var.vmsize-domaincontroller
  admin_username      = var.adminusername
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.region1-dc01-nic.id,
  ]

  tags = {
    Environment = var.environment_tag
    Function    = "AZVM-activedirectory"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    #disk_encryption_set_id = azurerm_disk_encryption_set.des-encryptset.id #added 7/25

  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
#Attach Data Disk to Virtual Machine
resource "azurerm_virtual_machine_data_disk_attachment" "region1-dc01-data" {
  managed_disk_id    = azurerm_managed_disk.region1-dc01-data.id
  depends_on         = [azurerm_windows_virtual_machine.region1-dc01-vm]
  virtual_machine_id = azurerm_windows_virtual_machine.region1-dc01-vm.id
  lun                = "10"
  caching            = "None"
}
#Run setup script on dc01-vm - Domain Controller scripts
resource "azurerm_virtual_machine_extension" "region1-dc01-setup" {
  name                 = "AZVM-dc01-setup"
  virtual_machine_id   = azurerm_windows_virtual_machine.region1-dc01-vm.id
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.region1-dc01-data]
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

resource "azurerm_virtual_machine_extension" "region1-dc01-diskencrypt" {
  name                 = "AZVM-dc01-diskencrypt"
  virtual_machine_id   = azurerm_windows_virtual_machine.region1-dc01-vm.id
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.region1-dc01-data]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./AzureDiskEncryption.ps1; exit 0;\""
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
        "fileUris": [
          "https://raw.githubusercontent.com/realnamesareboring/Azure-VM-POC/main/PowerShell/AzureDiskEncryption.ps1"
        ]
    }
  SETTINGS
}
/*
#Test powershell script
resource "null_resource" "PowerShellScriptRunAlways" {
    triggers = {
        trigger = "${uuid()}"
    }

    provisioner "local-exec" {
        command = ".'${path.module}\\PowerShell\\AzureDiskEncryption.ps1'"
        interpreter = ["PowerShell", "-Command"]
    }
}
*/
#Azure Firewall Setup - Added 7/14
#Public IP
resource "azurerm_public_ip" "region1-fw01-pip" {
  name                = "region1-fw01-pip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment_tag
    Function    = "AZFW-PubicIP"
  }
}
#Firewall Instance
resource "azurerm_firewall" "region1-fw01" {
  name                = "region1-fw01"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  depends_on          = [azurerm_firewall_policy.region1-fw-pol01]
  
  
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.region1-vnet1-snetfw.id
    public_ip_address_id = azurerm_public_ip.region1-fw01-pip.id
  }
}

#Classic Rules
resource "azurerm_firewall_nat_rule_collection" "specific-range-rules" {
  name                = "specific-range-firewall-rules"
  azure_firewall_name = azurerm_firewall.region1-fw01.name
  resource_group_name = azurerm_resource_group.rg1.name
  priority            = 100
  action              = "Dnat"
  rule {
    name                  = "specific-range-firewall-rules"
    source_addresses      = ["*"]
    destination_addresses = [azurerm_public_ip.region1-fw01-pip.ip_address]
    destination_ports     = ["3389"]
    translated_port       = "3389"
    translated_address    = "10.1.1.4"
    protocols             = ["TCP"]
  }
}
/*
resource "azurerm_firewall_network_rule_collection" "specific-destination-rules2" {
  name                = "specific-destination-firewall-rules2"
  azure_firewall_name = azurerm_firewall.region1-fw01.name
  resource_group_name = azurerm_resource_group.rg1.name
  priority            = 101
  action              = "Allow"
  rule {
    name                  = "specific-range-firewall-rules"
    source_addresses      = ["10.0.0.0/16"]
    destination_addresses = ["10.10.100.1/32"]
    destination_ports     = ["3389"]
    protocols             = ["TCP"]
  }
}
*/
# TESTING VAULT - DISABLED 7/27
#Firewall Policy
resource "azurerm_firewall_policy" "region1-fw-pol01" {
  name                = "region1-firewall-policy01"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
}
/*
# Firewall Policy Rules
resource "azurerm_firewall_policy_rule_collection_group" "region1-policy1" {
  name               = "region1-policy1"
  firewall_policy_id = azurerm_firewall_policy.region1-fw-pol01.id
  priority           = 100

  application_rule_collection {
    name     = "blocked_websites1"
    priority = 500
    action   = "Deny"
    rule {
      name = "malicious"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["defcon.org"]
    }
  }
*/