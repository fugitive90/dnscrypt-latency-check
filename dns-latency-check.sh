#!/bin/bash

# @author fugitive90
# Requirements: csvtool, fping
# Description: Outputs n number of dnscrypt servers with lowest latency

tmp_orig_csv=$(mktemp)
tmp_new_csv=$(mktemp)
tmp_latency=$(mktemp)
number_of_servers="5" #Change this to the number of servers you want to get

url="https://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-resolvers.csv"




wget -q -O "$tmp_orig_csv" "$url" 

csvtool col 1,8-9,11 "$tmp_orig_csv" | grep -v "v6" | grep -v ",no," | sed -r 's/:[0-9]+//g' > "$tmp_new_csv"

IFS=","
while read name dnssec log ip ; do
	fping -a -e $ip |sed -r 's/( is alive )|[\(\)ms]/ /g'  >> "$tmp_latency"
done < "$tmp_new_csv"

sort -k2 -n "$tmp_latency" | head -n $number_of_servers | cut -d " " -f 1 | grep  -f - "$tmp_new_csv" | cut -d"," -f 1

# Cleanup
rm -f $tmp_latency $tmp_new_csv $tmp_orig_csv

exit 0
