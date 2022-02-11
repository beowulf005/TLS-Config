$ArrayPaths = @()
#Paths
$RootPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\'
$Protocals = @('SSL 2.0\','SSL 3.0\','TLS 1.0\','TLS 1.1\','TLS 1.2\')
$ProtocalFolders = @('Client','Server')

#Verify Folder Paths (Servers by default do not have TLS path folders)
ForEach ($Protocal in $Protocals)
    {
        $ProtocalPath = $RootPath+$Protocal
        IF(!(Test-Path $ProtocalPath))
            {New-Item -Path $ProtocalPath -Force | Out-Null}
        #Verify Full Path
        Foreach ($ProtocalFolder in $ProtocalFolders)
            {
                $FullPath = $ProtocalPath+$ProtocalFolder
                $ArrayPaths += $ProtocalPath+$ProtocalFolder
                IF(!(Test-Path $FullPath))
                {New-Item -Path $FullPath -Force | Out-Null}
            }
    }

#Updated .net 3.5 Framework
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -Name 'SystemDefaultTlsVersions' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727' -Name 'SystemDefaultTlsVersions' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -Name 'SchUseStrongCrypto' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727' -Name 'SchUseStrongCrypto' -Value 1 -PropertyType DWORD -Force | Out-Null

#Updated .net Framework
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework' -Name 'OnlyUseLatestCLR' -Value 1 -PropertyType DWORD -Force | Out-Null

#Prompt for Script Choice
$enable = New-Object System.Management.Automation.Host.ChoiceDescription '&Enable'
$disable = New-Object System.Management.Automation.Host.ChoiceDescription '&Disable'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($enable, $disable)
$result = $host.ui.PromptForChoice('-Enable/Disable TLS Config-', 'Do you want to enable/disable server TLS configuration?', $options, 0)

#Enable TLS (Result = 0)
If ($result -eq 0)
    {
        ForEach ($ArrayPath in $ArrayPaths)
            {
                If ($ArrayPath -notlike '*TLS 1.2*')
                    {
                        New-ItemProperty -Path $ArrayPath -Name 'DisabledByDefault' -Value 1 -PropertyType DWORD -Force | Out-Null
                        New-ItemProperty -Path $ArrayPath -Name 'Enabled' -Value 0 -PropertyType DWORD -Force | Out-Null
                    }
                If ($ArrayPath -like '*TLS 1.2*')
                    {
                        New-ItemProperty -Path $ArrayPath -Name 'DisabledByDefault' -Value 0 -PropertyType DWORD -Force | Out-Null
                        New-ItemProperty -Path $ArrayPath -Name 'Enabled' -Value 1 -PropertyType DWORD -Force | Out-Null
                    }
            }
        Write-Host "Successfully enabled TLS Compliance."
    }

#Disable TLS (Result = 1)
If ($result -eq 1)
{
    ForEach ($ArrayPath in $ArrayPaths)
        {
            If ($ArrayPath -like '*TLS 1.0*')
                {
                    New-ItemProperty -Path $ArrayPath -Name 'DisabledByDefault' -Value 0 -PropertyType DWORD -Force | Out-Null
                    New-ItemProperty -Path $ArrayPath -Name 'Enabled' -Value 1 -PropertyType DWORD -Force | Out-Null
                }
        }
        Write-Host "Successfully disabled TLS Compliance, complete any testing/configuration requried and run script again to enable TLS."
}
