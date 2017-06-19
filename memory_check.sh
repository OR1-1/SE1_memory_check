#!/bin/bash

usage="USAGE:\n    ./memory_check -c [critical threshold (percentage)] -w [warning threshold (percentage)] -e [email address to send the report]"

while getopts "c:w:e:" o; do
    case "${o}" in
        c)
            crit=${OPTARG}
            ;;
        w)
            warn=${OPTARG}
            ;;
        e)
            email=${OPTARG}
            ;;
        \?)
            echo -e $usage
            exit
            ;;

    esac
done

if [ -z $crit ] || [ -z $warn ] || [ -z $email ]; then
    echo -e $usage
    exit
fi

if [ "$warn" -ge "$crit" ]; then
    echo "Critical threshold should be greater than the warning threshold."
    echo -e $usage
    exit
fi

total_mem=$(free | grep Mem: | awk ' { print $2 } ' )
current_mem=$(free | grep Mem: | awk ' { print $3 } ' )

used_mem_percentage=$(bc -l <<< $current_mem/$total_mem)
used_mem_percentage=$(bc -l <<< $used_mem_percentage*100)
used_mem_percentage=${used_mem_percentage%.*}

echo 'Total Memory: '$total_mem
echo 'Current Memory: '$current_mem
echo 'Usage: ' $used_mem_percentage '%'
echo 'Warning Threshold: '$warn
echo 'Critical Threshold: '$crit

if [ "$used_mem_percentage" -ge "$crit" ]; then
    echo 'CRITICAL!!'
    top_proc=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -11)
    echo "$top_proc" | mail -s "$(date +"%Y%m%d %R") memory check - critical" $email 
    exit 2 
elif [ "$used_mem_percentage" -ge "$warn" ] && [ "$used_mem_percentage" -lt "$crit" ]; then
    echo 'WARNING!!'
    exit 1
else     
    echo 'OK!!'
    exit 0
fi
