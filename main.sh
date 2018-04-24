#!/bin/bash

TAG_PREFIX=${TAG_PREFIX:-"tag_"}

url='http://rancher-metadata/2015-12-19'
uuid=$(curl -s "$url/self/container/uuid/")
name=$(curl -s "$url/self/container/name/" | sed 's/-/_/g')
ip=$(curl -s "$url/self/container/ips/0")

labels=$(curl -s "$url/self/host/labels")

echo "Starting instance ${name} with IP ${ip}"

cmd="rethinkdb -n \"${name}\" --canonical-address ${ip} --cluster-reconnect-timeout 60 --bind all"

for label in $labels
do
  echo $label | grep ${TAG_PREFIX} > /dev/null
  if [ $? -eq 0 ]
  then
    tag=$(curl -s "$url/self/host/labels/$label")
    echo "Adding tag ${tag} labeled as ${label} to server tags"
    cmd="${cmd} --server-tag ${tag}"
  fi
done

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
