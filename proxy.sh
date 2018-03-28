#!/bin/bash


url='http://rancher-metadata/2015-12-19'
uuid=$(curl -s "$url/self/container/uuid/")
name=$(curl -s "$url/self/container/name/")

rethinkdb proxy -n "${name}" --bind all --join db:29015