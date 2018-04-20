#!/bin/bash


url='http://rancher-metadata/2015-12-19'
uuid=$(curl -s "$url/self/container/uuid/")
name=$(curl -s "$url/self/container/name/")

sleep_time=$(( ( RANDOM % 10 )  + 1 ))

echo "Sleeping ${sleep_time} seconds before starting"

sleep ${sleep_time}

rethinkdb proxy --bind all --join db:29015