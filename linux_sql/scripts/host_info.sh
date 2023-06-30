#!/bin/bash


psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5


if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi


vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

cpu_number=$(lscpu | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(lscpu | egrep "^Architecture\:" | awk '{print $2}' | xargs)
cpu_model=$(lscpu | egrep "^Model\:" | awk '{print $2}' | xargs)
cpu_mhz=$(lscpu | egrep "^CPU MHz\:" | awk '{print $3}' | xargs)
l2_cache=$(lscpu | egrep "^L2 cache:" | awk '{print $3}' | xargs | sed 's/[^0-9]*//g')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(vmstat -t | awk '{print $18} {print $19}' | xargs | cut -c 5-)

insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
VALUES('$hostname','$cpu_number','$cpu_architecture','$cpu_model','$cpu_mhz','$l2_cache','$timestamp','$total_mem');"


export PGPASSWORD=$psql_password

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?