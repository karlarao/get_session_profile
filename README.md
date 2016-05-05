# get_session_profile
- Karl Arao, OakTable, Oracle ACE, OCP-DBA, RHCE
- http://karlarao.wordpress.com


### The general workflow:

* Get the session id of the process

  ```
  $ sh get_active_sessions.sh
  TM                 INST   SID PROG       USERNAME      SQL_ID         CHILD PLAN_HASH_VALUE        EXECS       AVG_ETIME   AVG_LIOS SQL_TEXT                                  OSUSER                         MACHINE
  ----------------- ----- ----- ---------- ------------- ------------- ------ --------------- ------------ --------------- ---------- ----------------------------------------- ------------------------------ -------------------------
  05/05/16 15:29:17     1  1061 sqlplus@en SYS           9fx889bgz15h3      0      3691747574            8         .817694  318108.71 SELECT /*+ cputoolkit ordered             oracle                         enkx3db01.enkitec.com
  ```

* Execute the get_session_profile.sh with two parameters
  * SID
  * identifier of the file (e.g. bad, good, slow, fast)

  ```  
  $ sh get_session_profile.sh 1061 bad
  ```
  or
  ```  
  $ sh get_session_profile.sh 966 good
  ```

  The script would do this the following:
    * 10046 start
    * snapper (sample for 1 min - 5 secs each)
    * short_stack (sample for 1 min - 5 secs each)
    * ash (get last 10 mins)
    * wait chains (get last 10 mins)
    * 10046 end

  Explanation of each instrumentation:
    * 10046 on start and end of instrumentation
      * that would catch the slow recursive SQLs
    * snapper
      * the sesstat, wait, ash, latch, enqueue, buffer get reasons
    * short_stack
      * would give me the stack info (Oracle low layer functions)
    * ash
      * basically a RAW dump for time series graphing
    * wait chains
      * a stack like info but on the ASH layer


* Get a summary of the collected sessions/instrumentations

  ```
  $ sh get_session_summary.sh bad
  ```

  ```
  $ sh get_session_summary.sh good
  ```
  Running the get_session_summary.sh will read all the get_session_profile*log files based on the filter ("bad"/"good") and summarize the contents in a log file get_session_profile_summary_$filter.log. This will give a good overview of what's happening on the session.

  Each execution of the script is a new summary.

* Once done, package all the files with package_files.sh

  ```
  $ sh package_files.sh
  ```
  This will put all the collected files (including the 10046 trace files) in the get_session_profile directory.

  Tar the directory and then email/ftp


#### NOTE:
The data collected by this tool should be correlated with the high level numbers of the run_awr and ESP. And also any time series performance data from the app side.


#### Example output of get_session_summary.sh
The full output is here https://github.com/karlarao/get_session_profile/blob/master/get_session_profile_summary_bad.log

```
/u01/app/oracle/diag/rdbms/oltp/oltp1/trace/oltp1_ora_126349.trc
/u01/app/oracle/diag/rdbms/oltp/oltp1/trace/oltp1_ora_126349.trc
     60 opiodr()+916
     40 qertbFetch()+2525
     40 kdsttgr()+55099
     20 ttcpip()+2242
     20 _start()+36
     20 ssthrdmain()+252
     20 sspuser()+112
     20 sou2o()+103
     20 skgmstack()+148
     20 __sighandler()
     20 rpiswu2()+638
     20 rpidrv()+1384
     20 rpidrus()+211
     20 qerjotRowProc()+353
     20 qerjotFetch()+1961
     20 qerjotFetch()+1155
     20 qergsFetch()+505
     20 qercoFetch()+205
     20 psdnal()+457
     20 psddr0()+473
     20 plsql_run()+649
     20 pfrrun_no_tool()+63
     20 pfrrun()+627
     20 pfrinstr_EXECC()+80
     20 pevm_EXECC()+605
     20 peicnt()+301
     20 opitsk()+1673
     20 opipls()+9276
     20 opimai_real()+133
     20 opiino()+966
     20 opifch2()+2995
     20 opiexe()+17667
     20 opiefn0()+500
     20 opidrv()+570
     20 main()+201
     20 __libc_start_main()+253
     20 ksedsts()+461
     20 ksdxfstk()+32
     20 ksdxcb()+1876
     20 kpoal8()+2124
     20 kkxexe()+525
     20 kdstf01001010000km()+346
      9 kdstf01001010000km()+306
      5 kdstf01001010000km()+278
      5 expeal()+64
      2 kdstf01001010000km()+192
      2 expeal()+35
      1 qercoRop()
      1 lmebco()+142
      1 kdst_fetch()+112
      1 kdstf01001010000km()+3608
      1 kdstf01001010000km()+266
      1 kaf4reasrp0km()+627
      1 kaf4reasrp0km()+52
      1 kaf4reasrp0km()+41
      1 kaf4reasrp0km()+253
      1 kaf4reasrp0km()+191
      1 expeal()+71
      1 expeal()+11
      1 expeal()+1
      1 evareo()+70
      1 evareo()+65
      1 evareo()+57
      1 evareo()+233
      1 evareo()+224
  88%          90         .2 -> 1>achains>1061>>sqlplus@enkx3db01.enkitec.com (TNS V1-V3)>>ON CPU >>9fx889bgz15h3>>SELECT>>V8 Bundled Exec>>driver id>>1650815232>>#bytes>>1>>>>0>>
  76%         337         .6 -> 1>achains>1061>>sqlplus@enkx3db01.enkitec.com (TNS V1-V3)>>ON CPU >>9fx889bgz15h3>>SELECT>>V8 Bundled Exec>>driver id>>1650815232>>#bytes>>1>>>>0>>
   4%          16          0 -> 1>achains>387>>sqlplus@enkx3db01.enkitec.com (TNS V1-V3)>>ON CPU >>bm2hm3w1yut4b>>SELECT>>V8 Bundled Exec>>driver id>>1650815232>>#bytes>>1>>>>0>>
   3%          12          0 -> 1>achains>296>>sqlplus@enkx3db01.enkitec.com (TNS V1-V3)>>ON CPU >>bm2hm3w1yut4b>>SELECT>>V8 Bundled Exec>>driver id>>1650815232>>#bytes>>1>>>>0>>

   -1  @1,           , BUFG, kdiwh08: kdiixs                                           ,             1,        .21,         ,             ,          ,           ,
   -1  @1,           , BUFG, kdiwh08: kdiixs                                           ,             1,        .21,         ,             ,          ,           ,
   -1  @1,           , BUFG, qeilwhrp: qeilbk                                          ,             1,        .21,         ,             ,          ,           ,
   -1  @1,           , BUFG, kdiwh08: kdiixs                                           ,             2,        .41,         ,             ,          ,           ,

   -1  @1,           , ENQG, JS - Job Scheduler                                        ,            44,       9.46,         ,             ,          ,           ,
   -1  @1,           , ENQG, JS - Job Scheduler                                        ,           151,      31.04,         ,             ,          ,           ,
   -1  @1,           , ENQG, JS - Job Scheduler                                        ,           151,      31.06,         ,             ,          ,           ,

   -1  @1,           , LATG, cache buffers chains                                      ,       3149297,    648.57k,         ,             ,          ,           ,
   -1  @1,           , LATG, cache buffers chains                                      ,       3167373,    651.19k,         ,             ,          ,           ,
   -1  @1,           , LATG, cache buffers chains                                      ,       3168373,    651.81k,         ,             ,          ,           ,
   -1  @1,           , LATG, cache buffers chains                                      ,       3332104,    645.03k,         ,             ,          ,           ,

   1061  @1, SYS       , STAT, logical read bytes from cache                             ,   12894396416,      2.66G,         ,             ,          ,           ,      2.58G per execution
   1061  @1, SYS       , STAT, logical read bytes from cache                             ,   12965748736,      2.67G,         ,             ,          ,           ,      2.59G per execution
   1061  @1, SYS       , STAT, logical read bytes from cache                             ,   12972490752,      2.67G,         ,             ,          ,           ,      2.59G per execution
   1061  @1, SYS       , STAT, logical read bytes from cache                             ,   13595959296,      2.63G,         ,             ,          ,           ,      2.72G per execution


   1061  @1, SYS       , TIME, sql execute elapsed time                                  ,       4001473,   840.97ms,    84.1%, [######### ],          ,           ,
   1061  @1, SYS       , TIME, sql execute elapsed time                                  ,       4002141,   841.76ms,    84.2%, [######### ],          ,           ,
   1061  @1, SYS       , TIME, sql execute elapsed time                                  ,       4001081,   841.85ms,    84.2%, [######### ],          ,           ,
   1061  @1, SYS       , TIME, sql execute elapsed time                                  ,       4002700,   860.14ms,    86.0%, [######### ],          ,           ,

   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU
   1.00    (100%) |    1 | 9fx889bgz15h3   | 0         | ON CPU                              | ON CPU   

```
