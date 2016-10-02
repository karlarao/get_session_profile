
-- run the script
set pages 1000
set lines 120
set heading off
column w_proc format a50 tru
column instance format a20 tru
column inst format a28 tru
column wait_event format a50 tru
column p1 format a16 tru
column p2 format a16 tru
column p3 format a15 tru
column Seconds format a50 tru
column sincelw format a50 tru
column blocker_proc format a50 tru
column fblocker_proc format a50 tru
column waiters format a50 tru
column chain_signature format a100 wra
column blocker_chain format a100 wra

col sdate new_value sysdt
select to_char(sysdate,'MM-DD-YY-HH24-MI-SS') sdate from dual;
spool waitchainsdetail_&sysdt..log append

SELECT TO_CHAR(SYSDATE,'MM/DD/YY HH24:MI:SS') TM, a.*
FROM (SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name INSTANCE,  'INST #: '||instance INST,'Blocking Process: '||decode(blocker_osid,null,'<none>',blocker_osid)||
' from Instance '||blocker_instance BLOCKER_PROC,  'Number of waiters: '||num_waiters waiters,  'Final Blocking Process: '||decode(p.spid,null,'<none>',  p.spid)||' from Instance '||s.final_blocking_instance FBLOCKER_PROC,
'Program: '||p.program image,
'Wait Event: ' ||wait_event_text wait_event, 'P1: '||wc.p1 p1, 'P2: '||wc.p2 p2, 'P3: '||wc.p3 p3,  'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait: '||time_since_last_wait_secs sincelw,  'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking Wait Chain: '||decode(blocker_chain_id,null,
'<none>',blocker_chain_id) blocker_chain FROM v$wait_chains wc,  gv$session s,  gv$session bs,  gv$instance i,  gv$process p WHERE wc.instance = i.instance_number (+)  AND (wc.instance = s.inst_id (+) and wc.sid = s.sid (+)  and wc.sess_serial# = s.serial# (+))  AND (s.final_blocking_instance = bs.inst_id (+) and s.final_blocking_session = bs.sid (+))  AND (bs.inst_id = p.inst_id (+) and bs.paddr = p.addr (+))  AND ( num_waiters > 0  OR ( blocker_osid IS NOT NULL  AND in_wait_secs > 10 ) ) ORDER BY chain_id,  num_waiters DESC) a WHERE ROWNUM < 101;

spool off
