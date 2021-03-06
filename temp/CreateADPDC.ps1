configuration CreateADPDC 
{ 
   param 
   ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,
		
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    ) 
    
    Import-DscResource -ModuleName xActiveDirectory,xDisk, xNetworking, cDisk, xDNS
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    $Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
    $InteraceAlias=$($Interface.Name)
	$dnsFilePath = Join-Path $env:systemdrive "xdnsout\dnsIPs.txt"
	# Get the disk number of the data disk
	$dataDisk = Get-Disk | where{$_.PartitionStyle -eq "RAW"}
	$dataDiskNumber = $dataDisk[0].Number

    Node localhost
    {
		xExportClientDNSAddressesToFile ExportDNSServers
		{
			OutputFilePath = $dnsFilePath
		}
        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
			DependsOn = '[xExportClientDNSAddressesToFile]ExportDNSServers'
        }
        xDnsServerAddress DnsServerAddress 
        { 
            Address        = '127.0.0.1' 
            InterfaceAlias = $InteraceAlias
            AddressFamily  = 'IPv4'
			DependsOn = '[WindowsFeature]DNS'
        }
        xWaitforDisk Disk2
        {
             DiskNumber = $dataDiskNumber
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
			 DependsOn = '[xDnsServerAddress]DnsServerAddress'
        }
        cDiskNoRestart ADDataDisk
        {
            DiskNumber = $dataDiskNumber
            DriveLetter = "F"
			DependsOn = '[xWaitforDisk]Disk2'
        }
        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
			DependsOn = '[cDiskNoRestart]ADDataDisk'
        }  
        xADDomain FirstDS 
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
			DependsOn = '[WindowsFeature]ADDSInstall'
        }
		xAddDNSForwardersFromFile AddDNSForwarders
		{
			DNSIPsFilePath = $dnsFilePath
			DependsOn = '[xADDomain]FirstDS'
		}
        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $True
        }
   }
} 