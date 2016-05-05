sqlplus -s /NOLOG <<! &
connect / as sysdba

set pagesize 999
set lines 250
col inst for 9999
col username format a13
col prog format a10 trunc
col sql_text format a41 trunc
col sid format 9999
col child for 99999
col avg_etime for 999,999.999999
col execs for 999,999,999
col machine for a25
break on sql_text
select to_char(sysdate,'MM/DD/YY HH24:MI:SS') tm, a.inst_id inst, sid, substr(program,1,19) prog, a.username, b.sql_id, child_number child, plan_hash_value, executions execs,
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
round((buffer_gets/decode(nvl(elapsed_time/1000000,0),0,1,elapsed_time/1000000)),2) avg_lios,
sql_text, a.osuser, a.machine
from gv\$session a, gv\$sql b
where status = 'ACTIVE'
and username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sql_child_number = b.child_number
and sql_text not like 'select a.inst_id inst, sid, substr(program,1,19) prog, b.sql_id, child_number child,%' -- don't show this query
and sql_text not like 'declare%' -- skip PL/SQL blocks
order by a.inst_id, a.username, sql_id, child
/

exit
!
