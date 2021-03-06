function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$DNSIPsFilePath	
	)

	$returnValue = @{
		DNSIPsFilePath = $DNSIPsFilePath
	}
    $returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$DNSIPsFilePath
	)
	
	$entries = Get-Content -Path $DNSIPsFilePath 
	foreach($sEntry in $entries){
		Write-Verbose "Adding alternate $($sEntry) as DNS server forwarder..."
		Add-DnsServerForwarder -IPAddress $sEntry
		Write-Verbose "Done adding the new DNS server forwarder"
	}
	
}

function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$DNSIPsFilePath
	)
	
	if(!(Test-Path $DNSIPsFilePath))
	{
		throw "DNS IP file on path $DNSIPsFilePath does not exist"
	}
	
	$entries = Get-Content -Path $DNSIPsFilePath 
	$forwarderAdded = $true
	foreach($sEntry in $entries){
		$fwd = $null
		$fwd = Get-DnsServerForwarder | where {$_.IPAddress -eq $sEntry}
		$forwarderAdded = $fwd -ne $null
	}
	return $forwarderAdded
}


Export-ModuleMember -Function *-TargetResource

