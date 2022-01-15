<#
	AUTHOR:  DAVID WING
	DATE:    2022-01-14
	PURPOSE: Find the SQL Server services running on the host
    STATE:   NOT COMPLETE
    IDEAS:   Can Powershell be used OOTB to query the SQL Server Browser Service?
#>

<#
Sources:
https://brianbentley.net/querying-sql-browser/
https://www.bobpusateri.com/archive/2010/09/a-look-at-the-sql-server-browser-service/
https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/portqry-command-line-port-scanner-v2
https://www.powershellbros.com/use-powershell-to-format-port-query-portqry-output/
#>

<#
/* PURPOSE:  */
/* RESULTS:  */
/* NOTE:     */
/* SUPPORT:  */
#>

#$RemoteServer = Read-Host "Please provide server name"
$RemoteServer = "<local-machine>"
$SCCMServ = "<local-machine>"

$PortArray  = @()

If(!$RemoteServer){
    Write-Warning "Something went wrong"
    Break
}
Else{
    $TestPath = Test-Path "<path-to-PortQry>\PortQryUI\Portqry.exe"
    If($TestPath -match "False" -or $null){
        Write-Warning "Portqry not found"
        Break
    }
    Else{
        Set-Location "<path-to-PortQry>\PortQryUI"
        Foreach ($Server in $SCCMServ){
            Write-Host "Checking $Server" -ForegroundColor Yellow
            $Array = @()
            $PortQuery = $Ports = $Object = $PortObject = $Null
            ##$PortQuery = Invoke-Command $RemoteServer -ScriptBlock{param($Server)cmd.exe /c "Portqry.exe -n $Server -E 1434 -p UDP"} -ArgumentList $Server
            $PortQuery = Invoke-Command -ScriptBlock{param($Server)cmd.exe /c "Portqry.exe -n $Server -E 1434 -p UDP"} -ArgumentList $Server
            #$PortQuery
            $Ports = $PortQuery | Where-Object {$_.StartsWith("ServerName") -or $_.StartsWith("InstanceName") -or $_.StartsWith("IsClustered") -or $_.StartsWith("Version") -or $_.StartsWith("tcp" )}

            Foreach ($Line in $Ports){$Line}

            <#
            Foreach ($Line in $Ports){

                $PortNumber = ($Line -split "ServerName ")[1].Trim()
                $PortNumber = ($PortNumber -split " ")[0].Trim()
                $PortNumber
                $Status = ($Line -split ": ")[1].Trim()
                $Object = New-Object PSObject -Property ([ordered]@{
                    PortNumber           = $PortNumber
                    Status               = $Status
                })
                # Add custom object to our array
                $Array += $Object
            }
            If($Array){
                $PortObject = New-Object PSCustomObject
                $PortObject | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server

                Foreach($item in $Array){
                    $PortNr = $Null
                    $PortNr = $Item.portnumber
                    $PortObject | Add-Member -MemberType NoteProperty -Name $PortNr -Value $item.status
                }

                $PortArray += $PortObject
            }
            #>
        }
    }
}

$PortArray | Format-Table -AutoSize -Wrap