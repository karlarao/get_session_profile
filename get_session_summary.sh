# usage: sh get_session_summary.sh <filter>
filter=$1
cat get_session_profile_shortstack*$filter*log | grep "trc" | sort | uniq > get_session_profile_summary_$filter.log
cat get_session_profile_shortstack*$filter*log | grep opi | sed -e $'s/<-/\\\n/g' | sort -r | uniq -c | sort -rnk1 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep "achains" | sort -rnk1 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep BUFG | sort -n -k9 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep ENQG | sort -n -k10 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep LATG | sort -n -k9 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep STAT | sort -n -k12 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep WAIT | sort -n -k9 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep TIME | sort -n -k12 >> get_session_profile_summary_$filter.log
cat get_session_profile*$filter*log | grep "%) |" >> get_session_profile_summary_$filter.log
less get_session_profile_summary_$filter.log
