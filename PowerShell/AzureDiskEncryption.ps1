#Working!
Import-Module Az.KeyVault
$vm = "region1-dc01-vm"
$rg = "region1-eastus2-spoke"

#Deploy Keyvault
$random = -join ((0..9) | Get-Random -Count 5 | ForEach-Object {$_})
$kvname = "azvmdevault" + $random
New-AzKeyvault -name $kvname -ResourceGroupName $rg -Location eastus2 -EnabledForDiskEncryption -ErrorAction SilentlyContinue

$KeyVault = Get-AzKeyVault -VaultName $kvname -ResourceGroupName $rg
do
{
    $check = TRY
            {
                Set-AzVMDiskEncryptionExtension -ResourceGroupName $rg -VMName $vm -DiskEncryptionKeyVaultUrl $KeyVault.VaultUri -DiskEncryptionKeyVaultId $KeyVault.ResourceId -Force:$true -ErrorAction SilentlyContinue
            }
            CATCH
            {}
}
while($null -eq $check)