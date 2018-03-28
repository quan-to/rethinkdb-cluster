#!/bin/bash

url='http://rancher-metadata/2015-12-19'
uuid=$(curl -s "$url/self/container/uuid/")
name=$(curl -s "$url/self/container/name/")
cmd="rethinkdb -n \"${name}\" --bind all"

sleep_time=$(( ( RANDOM % 10 )  + 1 ))

echo "Sleeping ${sleep_time} seconds before starting"

sleep ${sleep_time}

echo "Scanning for other cluster members"

while read -r line; do
    id=$(echo $line | grep -oP '[0-9](?=\=)')
    hostname=$(echo $line | grep -oP '(?<=\=).+')
    ip=$(curl -s "$url/self/service/containers/${id}/primary_ip")
    echo "Found ${hostname} at ${ip}"
    if [ $(curl -s "$url/self/service/containers/$id/uuid/") != "$uuid" ]; then
        cmd="$cmd --join ${ip}:29015"
    fi
done < <(curl -s "$url/self/service/containers/")

echo "$cmd"
echo "----------------------"
$cmd