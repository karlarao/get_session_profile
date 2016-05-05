mkdir get_session_profile

cat get_session_profile*log | grep trc | sort | uniq | while read file; do
    cp "$file" "get_session_profile"
done

mv get_session_profile*log get_session_profile
mv tmp_*sql get_session_profile
mv myash*csv get_session_profile
