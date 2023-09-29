/*
source: https://learn.microsoft.com/en-us/troubleshoot/sql/connect/static-or-dynamic-port-config#option-2-use-powershell
*/

set nocount on;

DECLARE @sql_service_label [char](7) = 'MSSQL15';
DECLARE @ComputerNamePhysicalNetBIOS [sysname] = CONVERT([sysname], serverproperty('ComputerNamePhysicalNetBIOS'));

DECLARE @report_datetime [datetime2](0) = SYSDATETIME();

DECLARE @delimiter_a [char](1) = '!';
DECLARE @delimiter_b [char](1) = '@';
DECLARE @delimiter_c [char](1) = '#';
DECLARE @delimiter_d [char](1) = '$';

declare @sql_a varchar(1000) = 'powershell.exe -c "Get-ItemProperty  -Path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\' + @sql_service_label + '.*\MSSQLServer\SuperSocketNetLib\Tcp'' | Select-Object -Property Enabled, KeepAlive, ListenOnAllIps,@{label=''ServerInstance'';expression={$_.PSPath.Substring(74)}} | foreach{$_.ServerInstance + ' + QUOTENAME(@delimiter_a,CHAR(39)) + ' + $_.Enabled + ' + QUOTENAME(@delimiter_b,CHAR(39)) + ' + $_.KeepAlive + ' + QUOTENAME(@delimiter_c,CHAR(39)) + ' + $_.ListenOnAllIps + ' + QUOTENAME(@delimiter_d,CHAR(39)) + '}"';
declare @sql_b varchar(1000) = 'powershell.exe -c "Get-ItemProperty  -Path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\' + @sql_service_label + '.*\MSSQLServer\SuperSocketNetLib\Tcp\IP*\'' | Select-Object -Property TcpDynamicPorts,TcpPort, DisplayName, @{label=''ServerInstance_and_IP'';expression={$_.PSPath.Substring(74)}} | foreach{$_.ServerInstance_and_IP + ' + QUOTENAME(@delimiter_a,CHAR(39)) + ' + $_.DisplayName + ' + QUOTENAME(@delimiter_b,CHAR(39)) + ' + $_.TcpPort + ' + QUOTENAME(@delimiter_c,CHAR(39)) + ' + $_.TcpDynamicPorts + ' + QUOTENAME(@delimiter_d,CHAR(39)) + '}"';

CREATE TABLE #outputA (line varchar(max));
CREATE TABLE #outputB (line varchar(max));

insert #outputA EXEC xp_cmdshell @sql_a;
insert #outputB EXEC xp_cmdshell @sql_b;

select 
    @ComputerNamePhysicalNetBIOS as ComputerNamePhysicalNetBIOS, 
    @report_datetime as [Report_DateTime], 
    SUBSTRING([line],1,CHARINDEX(@delimiter_a,[line]) -1) as [ServerInstance],
    SUBSTRING([line],CHARINDEX(@delimiter_a,[line])+1,(CHARINDEX(@delimiter_b,[line]) -1)-CHARINDEX(@delimiter_a,[line])) as [Enabled],
    SUBSTRING([line],CHARINDEX(@delimiter_b,[line])+1,(CHARINDEX(@delimiter_c,[line]) -1)-CHARINDEX(@delimiter_b,[line])) as [KeepAlive],
    SUBSTRING([line],CHARINDEX(@delimiter_c,[line])+1,(CHARINDEX(@delimiter_d,[line]) -1)-CHARINDEX(@delimiter_c,[line])) as [ListenOnAllIps]
from #outputA
where line IS NOT NULL
order by [ServerInstance]
;

select 
    @ComputerNamePhysicalNetBIOS as ComputerNamePhysicalNetBIOS, 
    @report_datetime as [Report_DateTime], 
    SUBSTRING([line],1,CHARINDEX(@delimiter_a,[line]) -1) as [ServerInstance_and_IP],
    SUBSTRING([line],CHARINDEX(@delimiter_a,[line])+1,(CHARINDEX(@delimiter_b,[line]) -1)-CHARINDEX(@delimiter_a,[line])) as [DisplayName],
    SUBSTRING([line],CHARINDEX(@delimiter_b,[line])+1,(CHARINDEX(@delimiter_c,[line]) -1)-CHARINDEX(@delimiter_b,[line])) as [TcpPort],
    SUBSTRING([line],CHARINDEX(@delimiter_c,[line])+1,(CHARINDEX(@delimiter_d,[line]) -1)-CHARINDEX(@delimiter_c,[line])) as [TcpDynamicPorts]
from #outputB
where line IS NOT NULL
order by [ServerInstance_and_IP]
;

--script to drop the temporary table
DROP TABLE #outputA;
DROP TABLE #outputB;

