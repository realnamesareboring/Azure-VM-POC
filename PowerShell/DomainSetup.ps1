Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "E:\windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "test.lab" `
-DomainNetbiosName "test" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "E:\windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "E:\windows\SYSVOL" `
-Force:$true
