/*
	AUTHOR:  DAVID WING
	DATE:    2022-01-13
	PURPOSE: Top-level assessment of the SQL Server configuration when you encounter performance issues.
*/

/* PURPOSE: Reports Product Build and Memory Configuration for the SQL Server. */
/* RESULTS: Data and Transaction Log files configured for database tempdb */
/* NOTE:    You can replace 'tempdb' with any database on the SQL Server. */
/* SUPPORT: https://docs.microsoft.com/en-us/sql/t-sql/functions/serverproperty-transact-sql */

use [master];
SELECT 
SERVERPROPERTY('MachineName') as [MachineName],
SERVERPROPERTY('InstanceName') as [SqlServerInstanceName],
--SERVERPROPERTY('ServerName') as [ServerName],
--SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as [ComputerNamePhysicalNetBIOS],
SERVERPROPERTY('Edition') as [Edition],
SERVERPROPERTY('ProductVersion') as [ProductVersion], 
--SERVERPROPERTY('ProductMajorVersion') as [ProductMajorVersion],
--SERVERPROPERTY('ProductMinorVersion') as [ProductMinorVersion],
--SERVERPROPERTY('ProductBuild') as [ProductBuild],
SERVERPROPERTY('ProductLevel') as [ProductLevel], 
SERVERPROPERTY('ProductUpdateLevel') as [ProductUpdateLevel],
SERVERPROPERTY('ProductUpdateReference') as [ProductUpdateReference],
RIGHT(@@version, LEN(@@version) - 3 - charindex(' ON ', @@version)) as [OperatingSystemVersion]
,[value_in_use] as [MaximumRAMAllocatedToSqlServer_MB]
FROM sys.configurations
WHERE [name] = 'max server memory (MB)'
OPTION (RECOMPILE);
GO


/* PURPOSE: Determine if tempdb is large enough for your workloads. */
/* RESULTS: Data and Transaction Log files configured for database tempdb */
/* NOTE:    You can replace 'tempdb' with any database on the SQL Server. */
/* SUPPORT: https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-helpdb-transact-sql */
use [master];
declare @DatabaseName [sysname] = 'tempdb';
EXEC sp_helpdb @DatabaseName;
GO


/* PURPOSE: Reports information about a database object (any object listed in the sys.sysobjects compatibility view), a user-defined data type, or a data type. */
/* RESULTS: Refer to https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-help-transact-sql?view=sql-server-2016#result-sets */
/* NOTE:    You must use the actual names for <database-name>, <schema_name> and <object_name> (and remove angle brackets). */
/* SUPPORT: https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-help-transact-sql */
use [<database-name>];
declare @schemaQualifiedTableName [sysname] = '<schema_name>.<object_name>';
EXEC sp_help @schemaQualifiedTableName;
GO


/* PURPOSE: Reports total size for each table in KB including all of the indexes on that table.  */
/* RESULTS: table name, row count, total space, and total space used by the table and its indexes. */
/* NOTE:    You must use the actual name for <database-name> (and remove angle brackets). */
/* TIP:     You can add a predicate (filter) in the WHERE clause to one or more specific tables. */
use [<database-name>];
SELECT
    @@servername as SqlServer,
	DB_NAME() as [Database],
	OBJECT_SCHEMA_NAME(t.[schema_id]) AS TableSchema,
	t.[Name] AS [TableName],
    p.[rows] AS [RowCount],
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 
    AND i.OBJECT_ID > 255
GROUP BY t.[schema_id], t.[Name], p.[Rows]
ORDER BY [TableSchema], [TableName]
