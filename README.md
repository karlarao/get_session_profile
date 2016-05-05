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
