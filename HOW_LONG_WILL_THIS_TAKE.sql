declare @spid [int] = 78

SELECT session_id as SPID, command, a.text AS Query, start_time, DATEDIFF(MINUTE, start_time, GETDATE()) elapsed_time_minutes, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time
FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a
WHERE 
session_id = @spid
or
r.command in ('BACKUP DATABASE','RESTORE DATABASE','RESTORE LOG','BACKUP LOG')
or
r.command like '%DATABASE%'
OPTION(RECOMPILE);
