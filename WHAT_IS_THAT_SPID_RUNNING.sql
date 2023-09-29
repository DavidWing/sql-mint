declare
    @spid int
,   @stmt_start int
,   @stmt_end int
,   @sql_handle binary(20)

set @spid = 52 -- Fill this in

--52: (@P0 nvarchar(4000),@P1 nvarchar(4000))SELECT TOP 100 * FROM (SELECT TOP 100 * FROM (SELECT TOP 99 MAIL_ID,FROMADDR,TOADDR,CCADDR,FILENAME,SUBJECT,SMTPSERVER,MESSAGE,STATUS,ASATTACHMENT,ASMULTIPART,ATTACHMENT,PUBLISHERTYPE,LIMIT,JOBRUN_ID,BCCADDR,REPLYTOADDR,CUSTOMFIELDS,RETURNPATH,MSG_FOR_LOG FROM T_MAILINFO WHERE STATUS=@P0 AND SERVERNAME=@P1 ORDER BY MAIL_ID ) tempTable1 ORDER BY MAIL_ID DESC  ) tempTable2 ORDER BY MAIL_ID ASC                 

/*
52
104
107
129
131
146
157
*/

select  top 1
    @sql_handle = sql_handle
,   @stmt_start = case stmt_start when 0 then 0 else stmt_start / 2 end
,   @stmt_end = case stmt_end when -1 then -1 else stmt_end / 2 end
from    sys.sysprocesses
where   spid = @spid
order by ecid

select * FROM ::fn_get_sql(@sql_handle)

SELECT format(getdate(),'yyyy-MM-dd HH:mm:ss') as CheckDateTime,
    SUBSTRING(  text,
            COALESCE(NULLIF(@stmt_start, 0), 1),
            CASE @stmt_end
                WHEN -1
                    THEN DATALENGTH(text)
                ELSE
                    (@stmt_end - @stmt_start)
                END
        ) as SPID_Text
FROM ::fn_get_sql(@sql_handle)

SELECT format(getdate(),'yyyy-MM-dd HH:mm:ss') as CheckDateTime,text
FROM ::fn_get_sql(@sql_handle)

/*

DECLARE @Table TABLE(SPID INT,Status VARCHAR(MAX),LOGIN VARCHAR(MAX),HostName VARCHAR(MAX),BlkBy VARCHAR(MAX),DBName VARCHAR(MAX),Command VARCHAR(MAX),CPUTime BIGINT,DiskIO BIGINT,LastBatch VARCHAR(MAX),ProgramName VARCHAR(MAX),SPID_1 INT,REQUESTID INT)
INSERT INTO @Table EXEC sp_who2
SELECT  @@servername as SqlServer
--,'KILL ' + convert(varchar(10),LTRIM(RTRIM([BlkBy]))) as Kill_BLOCKER
--,'KILL ' + convert(varchar(10),SPID) as Kill_blocked
,*
FROM    @Table
WHERE 
SPID = @spid
order by LastBatch DESC
*/