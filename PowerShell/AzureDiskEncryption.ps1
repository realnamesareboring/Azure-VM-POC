#Deploy VM

#$cred = Get-Credential
#$vm = "region1-dc01-vm"
#$rg = "region1-eastus2-spoke"
#New-AzVM -Name $vm -Credential $cred -ResourceGroupName $rg -Image win2016datacenter -Size Standard_D2S_V3

#Deploy Keyvault
$random = -join ((0..9) | Get-Random -Count 5 | % {$_})
$kvname = "azvmdevault" + $random
New-AzKeyvault -name $kvname -ResourceGroupName $rg -Location EastUS -EnabledForDiskEncryption

#Encrypt the VM

$vm = "region1-dc01-vm"
$rg = "region1-eastus2-spoke"
$KeyVault = Get-AzKeyVault -VaultName $kvname -ResourceGroupName $rg
Set-AzVMDiskEncryptionExtension -ResourceGroupName $rg -VMName $vm -DiskEncryptionKeyVaultUrl $KeyVault.VaultUri -DiskEncryptionKeyVaultId $KeyVault.ResourceId -Force:$true

#Verify Encryption

#Get-AzVmDiskEncryptionStatus -VMName $vm -ResourceGroupName $rg