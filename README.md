# Azure-VM-POC
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.12.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.12.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.region1-fw01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_nat_rule_collection.specific-range-rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_nat_rule_collection) | resource |
| [azurerm_key_vault.kv1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.vmpassword](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_network_interface.region1-dc01-nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.region1-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.region1-fw01-pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.rg2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.region1-vnet1-snet1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.region1-vnet1-snetfw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.region1-vnet2-snet1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.region1-vnet2-snet2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.region1-vnet2-snet3](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_machine_extension.region1-dc01-setup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_network.region1-vnet1-hub1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.region1-vnet2-spoke1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peer1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.peer2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_windows_virtual_machine.region1-dc01-vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [null_resource.AzureDiskEncrypt](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.kvname](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.vmpassword](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adminusername"></a> [adminusername](#input\_adminusername) | administrator username for virtual machines | `string` | n/a | yes |
| <a name="input_azure-rg-1"></a> [azure-rg-1](#input\_azure-rg-1) | resource group 1 | `string` | n/a | yes |
| <a name="input_azure-rg-2"></a> [azure-rg-2](#input\_azure-rg-2) | resource group 2 | `string` | n/a | yes |
| <a name="input_environment_tag"></a> [environment\_tag](#input\_environment\_tag) | Environment tag value | `string` | n/a | yes |
| <a name="input_loc1"></a> [loc1](#input\_loc1) | The location for this Lab environment | `string` | n/a | yes |
| <a name="input_region1-vnet1-address-space"></a> [region1-vnet1-address-space](#input\_region1-vnet1-address-space) | VNET address space | `string` | n/a | yes |
| <a name="input_region1-vnet1-name"></a> [region1-vnet1-name](#input\_region1-vnet1-name) | VNET1 Name | `string` | n/a | yes |
| <a name="input_region1-vnet1-snet1-name"></a> [region1-vnet1-snet1-name](#input\_region1-vnet1-snet1-name) | subnet name | `string` | n/a | yes |
| <a name="input_region1-vnet1-snet1-range"></a> [region1-vnet1-snet1-range](#input\_region1-vnet1-snet1-range) | subnet range | `string` | n/a | yes |
| <a name="input_region1-vnet1-snetfw-name"></a> [region1-vnet1-snetfw-name](#input\_region1-vnet1-snetfw-name) | subnet name | `string` | n/a | yes |
| <a name="input_region1-vnet1-snetfw-range"></a> [region1-vnet1-snetfw-range](#input\_region1-vnet1-snetfw-range) | subnet range | `string` | n/a | yes |
| <a name="input_region1-vnet2-address-space"></a> [region1-vnet2-address-space](#input\_region1-vnet2-address-space) | VNET address space | `string` | n/a | yes |
| <a name="input_region1-vnet2-name"></a> [region1-vnet2-name](#input\_region1-vnet2-name) | VNET1 Name | `string` | n/a | yes |
| <a name="input_region1-vnet2-snet1-name"></a> [region1-vnet2-snet1-name](#input\_region1-vnet2-snet1-name) | subnet name | `string` | n/a | yes |
| <a name="input_region1-vnet2-snet1-range"></a> [region1-vnet2-snet1-range](#input\_region1-vnet2-snet1-range) | subnet range | `string` | n/a | yes |
| <a name="input_region1-vnet2-snet2-name"></a> [region1-vnet2-snet2-name](#input\_region1-vnet2-snet2-name) | subnet name | `string` | n/a | yes |
| <a name="input_region1-vnet2-snet2-range"></a> [region1-vnet2-snet2-range](#input\_region1-vnet2-snet2-range) | subnet range | `string` | n/a | yes |
| <a name="input_region1-vnet2-snet3-name"></a> [region1-vnet2-snet3-name](#input\_region1-vnet2-snet3-name) | subnet name | `string` | n/a | yes |
| <a name="input_region1-vnet2-snet3-range"></a> [region1-vnet2-snet3-range](#input\_region1-vnet2-snet3-range) | subnet range | `string` | n/a | yes |
| <a name="input_vmsize-domaincontroller"></a> [vmsize-domaincontroller](#input\_vmsize-domaincontroller) | size of vm for domain controller | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->