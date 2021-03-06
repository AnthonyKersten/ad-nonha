function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$OutputFilePath	
	)

	$returnValue = @{
		OutputFilePath = $OutputFilePath
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
		$OutputFilePath
	)
	
	$directoryPath = Split-Path $OutputFilePath -Parent
	if(!(Test-Path $directoryPath)){
		New-Item $directoryPath -ItemType directory
	}
	
	if(!(Test-Path $OutputFilePath)){
		New-Item $OutputFilePath -ItemType file
	}
	
	Write-Verbose "Exporting client DNS IPv4 server addresses to file $OutputFilePath ..."
	Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses | Get-Unique | Out-File $OutputFilePath
    Write-Verbose "Done exporting client DNS IPv4 server addresses"
}

function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$OutputFilePath
	)
	
	return (Test-Path $OutputFilePath)
}


Export-ModuleMember -Function *-TargetResource

