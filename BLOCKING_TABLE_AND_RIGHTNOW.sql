/*
EXECUTE zsqdbadb.[dbo].[proc_blocked_sql]
GO

EXECUTE zsqdbadb.[dbo].[proc_active] 
GO

EXECUTE zsqdbadb.[dbo].[proc_active_tran] 
GO

--For the IP Address
select dec.* 
from sys.dm_exec_connections dec
inner join sys.dm_exec_sessions des
on dec.session_id = des.session_id
where login_name = 'urciwprd'

*/
/*GO
SELECT 
date_time,[type],session_id,blocker,threads,[status],open_tran,Duration,last_start,wait_time_ms,pct_complete,command,[Object],wait_type,[Database],RTRIM(HostName) AS HostName,[User],Program,cpu_time,physical_io,logical_reads,row_count,wait_time,wait_resource,[isolation],transaction_name,transaction_type,transaction_state,dtc_state
, replace(replace(replace([SQL], char(10), ''), char(13), ''), char(9), '') as ExportableSQL
  FROM [zsqdbadb].[dbo].[blocked_log_t]
  where 
    --RTRIM([HostName]) = 'XXXXXXX'
	[date_time] > dateadd(hour, -3, getdate())
    -- [date_time] between '2022-12-20 11:00' and '2022-12-20 15:00'
	--and [Duration] > '00:01:00.000'
	and [type] = '!TOP BLOCKER' and [blocker] = 0
  --order by [date_time] desc, [last_start] asc, [type] asc, blocker asc, session_id asc;
-- -- FOR XML RAW
  order by [date_time] desc, [type] asc, [last_start] asc, blocker asc, session_id asc;
  --and (session_id in (264,155,138,0) OR blocker in (264,155,138,0))
  --and (blocker = 138)
  --and [type] = '!TOP BLOCKER'
--and [type] <> '(blocked)'
  --and ([Program] = 'ZZZZZ' and [User] = 'ZZZZZ')

*/

--EXECUTE zsqdbadb.[dbo].[proc_blocked_sql]
--GO

use [master]
go
DECLARE @Table TABLE(SPID INT,Status VARCHAR(MAX),[LOGIN] VARCHAR(MAX),HostName VARCHAR(MAX),BlkBy VARCHAR(MAX),DBName VARCHAR(MAX),Command VARCHAR(MAX),CPUTime BIGINT,DiskIO BIGINT,LastBatch VARCHAR(MAX),ProgramName VARCHAR(MAX),SPID_1 INT,REQUESTID INT)
INSERT INTO @Table EXEC sp_who2

/*
      select '02: SUSPENDED' as Status, count(*) from @Table where [Status] = 'SUSPENDED'
UNION select '01: RUNNABLE' as Status, count(*) from @Table where [Status] = 'RUNNABLE'
UNION select '04: BACKGROUND' as Status, count(*) from @Table where [Status] = 'BACKGROUND'
UNION select '03: SLEEPING' as Status, count(*) from @Table where [Status] = 'SLEEPING'
UNION select '05: OTHER' as Status, count(*) from @Table where [Status] NOT IN ('SLEEPING','SUSPENDED','RUNNABLE','BACKGROUND')
UNION select '00: ALL' as Status, count(*) from @Table
*/

/* the Year of a SPID's LastBatch could be from the previous year, hence "Assumed" Year of SPID. */
DECLARE @reportRunTime [datetime2](0) = GETDATE();
DECLARE @AssumedYearOfSPID [int] = DATEPART(YEAR,@reportRunTime);

SELECT  
@@servername as SqlServer
--,LTRIM(RTRIM([LastBatch]))
, @reportRunTime as spWho2_runtime
,CONVERT(
    [datetime2](0),
    CONVERT([char](4),@AssumedYearOfSPID) 
    + '-' + SUBSTRING(LTRIM(RTRIM([LastBatch])),1,CHARINDEX('/',LTRIM(RTRIM([LastBatch])),1)-1)
    + '-' + SUBSTRING(LTRIM(RTRIM([LastBatch])),CHARINDEX('/',LTRIM(RTRIM([LastBatch])),1)+1,CHARINDEX(' ',LTRIM(RTRIM([LastBatch])),CHARINDEX('/',LTRIM(RTRIM([LastBatch])),1)+1) - CHARINDEX('/',LTRIM(RTRIM([LastBatch])),1))
    + ' ' + RIGHT(LTRIM(RTRIM([LastBatch])),8)
    ) AS LastBatchDateTime_Derived
--,'KILL ' + convert(varchar(10),LTRIM(RTRIM([BlkBy]))) as Kill_BLOCKER
--,'KILL ' + convert(varchar(10),SPID) as Kill_blocked
,LTRIM(RTRIM([SPID]))          AS [SPID]
,LTRIM(RTRIM([Status]))        AS [Status]
,LTRIM(RTRIM([LOGIN]))         AS [Login]
,LTRIM(RTRIM([HostName]))      AS [HostName]
,LTRIM(RTRIM([BlkBy]))         AS [BlkBy]
,LTRIM(RTRIM([DBName]))        AS [DBName]
,LTRIM(RTRIM([Command]))       AS [Command]
,LTRIM(RTRIM([CPUTime]))       AS [CPUTime]
,LTRIM(RTRIM([DiskIO]))        AS [DiskIO]
,LTRIM(RTRIM([ProgramName]))   AS [ProgramName]
,LTRIM(RTRIM([SPID_1]))        AS [SPID_1]
,LTRIM(RTRIM([REQUESTID]))     AS [REQUESTID]
--,*
FROM    @Table
WHERE 
SPID <> @@SPID
--and
--[Command] like '%ZZZZZ%'
--SPID IN (283,309)
--and [Command] LIKE 'FT %'
and [LOGIN] NOT IN ('ZZZZZ\ZZZZZ','ZZZZZ','ZZZZZ\ZZZZZ','ZZZZZ\ZZZZZ')
--and [LOGIN] NOT LIKE '%ZZZZZ%'
--and [LOGIN] IN ('ZZZZZ','ZZZZZ')
--AND ( DBName like ('ZZZZZ%') OR RTRIM(ZZZZZ) IN ('FT CRAWL','FT CRAWL MON','FT FULL PASS') )
--AND (DBName = ('ZZZZZ'))
--and NOT LTRIM(RTRIM([BlkBy])) like '%.%'
--and [Status] NOT IN ('BACKGROUND','SLEEPING','sleeping')
and [Status] NOT IN ('BACKGROUND'/*,'SLEEPING','sleeping'*/)
--and [Status] IN ('SLEEPING','sleeping')
--and (
and [DBName] IN ('ZZZZZ')
-------- or [HostName] like '%ZZZZZ%'
-- )
--and HostName like 'VVV-VVV-VVV-VVV-%'
--and ( [LOGIN] IN ( 'ZZZZZ' ) or ( HostName like '%ZZZZZ%' ) )
--and ( DBName like 'ZZZZZ%' )
--and (SPID = 517) 
--AND ( HostName like '%ZZZZZ' )
--and [Status] <> 'BACKGROUND'
--and [LOGIN] = 'ZZZZZ' 
/*
and 
(
   HostName like '%ZZZZZ%'
or HostName like '%ZZZZZ%'
)
*/
--and [ProgramName] = 'ZZZZZ'
--and ltrim(rtrim((HostName))) not in ('ZZZZZ','ZZZZZ')
--order by LastBatchDateTime_Derived DESC--, [HostName]
--order by [%ZZZZZ%] DESC, HostName asc, LastBatchDateTime_Derived DESC
--order by HostName asc, LastBatchDateTime_Derived DESC
--order by SPID

/*


      select '02: SUSPENDED' as Status, count(*) from @Table where [Status] = 'SUSPENDED' AND (DBName like ('ZZZZZ%'))
UNION select '01: RUNNABLE' as Status, count(*) from @Table where [Status] = 'RUNNABLE' AND (DBName like ('ZZZZZ%'))
UNION select '04: BACKGROUND' as Status, count(*) from @Table where [Status] = 'BACKGROUND' AND (DBName like ('ZZZZZ%'))
UNION select '03: SLEEPING' as Status, count(*) from @Table where [Status] = 'SLEEPING' AND (DBName like ('ZZZZZ%'))
UNION select '05: OTHER' as Status, count(*) from @Table where [Status] NOT IN ('SLEEPING','SUSPENDED','RUNNABLE','BACKGROUND') AND (DBName like ('ZZZZZ%'))
UNION select '00: ALL' as Status, count(*) from @Table where (DBName like ('ZZZZZ%'))

SELECT  
@@servername as SqlServer
,[HostName],[Login],[ProgramName],[DBName],[Status],count(*) as NumberOfSPIDs
FROM    @Table
WHERE 
SPID <> @@SPID
AND (DBName like ('ZZZZZ%'))
group by [HostName],[Login],[ProgramName],[DBName],[Status]
order by [Status],[HostName],[Login],[ProgramName],[DBName]

*/
