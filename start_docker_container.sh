#!/bin/bash

echo "Starting the docker containers"
docker start $(docker ps -a -q)





