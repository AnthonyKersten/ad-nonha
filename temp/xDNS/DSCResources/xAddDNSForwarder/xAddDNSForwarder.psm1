function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$IPAddress		
	)

	$returnValue = @{
		IPAddress = $IPAddress
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
		$IPAddress
	)
	
	Write-Verbose "Adding alternate $($IPAddress) as DNS server forwarder..."
	Add-DnsServerForwarder -IPAddress $IPAddress
    Write-Verbose "Done adding the new DNS server forwarder"
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$IPAddress
	)
	
	$fwd = $null
	$fwd = Get-DnsServerForwarder | where {$_.IPAddress -eq $IPAddress}
	return $fwd -ne $null
}


Export-ModuleMember -Function *-TargetResource

