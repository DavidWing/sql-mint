/* Retrieve Case Manager stored procedure & [some] function executions */
SELECT getdate() as ExecTime,
cp.objtype AS ObjectType,
OBJECT_NAME(st.objectid,st.dbid) AS ObjectName,
cp.usecounts AS ExecutionCount
,
st.TEXT AS QueryText,
qp.query_plan AS QueryPlan
,'DBCC FREEPROCCACHE (' + convert(varchar(1000),cp.plan_handle,1) + ');' as CmdPlanRemove
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
where 
----st.text LIKE '%ss$_ss$_ss$_%' ESCAPE '$'
----and
--st.text LIKE '%ZZZZZ%'
--and
st.text LIKE '%"varName" = @P2%'
--AND
--db_name(qp.dbid) = 'ZZZZZ'
--and
--st.text NOT LIKE '%MERGE%'
--and 
--st.text NOT LIKE '%on the secondary node, throw an error%'
--or
--OBJECT_NAME(st.objectid,st.dbid) like '%some-view-name%'
--or
--OBJECT_NAME(st.objectid,st.dbid) like '%some-proc-name%'
--order by ObjectName
OPTION(RECOMPILE);

--DBCC FREEPROCCACHE (0x050012005F757103A03B43E67E00000001000000000000000000000000000000000000000000000000000000);

