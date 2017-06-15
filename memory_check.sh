#!/bin/bash

crit=10
warn=5

total_mem=$(free | grep Mem: | awk ' { print $2 } ' )
current_mem=$(free | grep Mem: | awk ' { print $3 } ' )

used_mem_percentage=$(bc -l <<< $current_mem/$total_mem)
used_mem_percentage=$(bc -l <<< $used_mem_percentage*100)
used_mem_percentage=${used_mem_percentage%.*}

echo 'total: '$total_mem
echo 'current: '$current_mem
echo 'usage: '$used_mem_percentage '%'
echo 'warn: '$warn
echo 'crit: '$crit

if [ "$used_mem_percentage" -ge "$crit" ]; then
    echo 'CRIT!!'
    exit 2 
elif [ "$used_mem_percentage" -ge "$warn" ] && [ "$used_mem_percentage" -lt "$crit" ]; then
    echo 'WARN!!'
    exit 1
else     
    echo 'OK!!'
    exit 0
fi
