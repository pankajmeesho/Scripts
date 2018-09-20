#!/bin/bash
# removing unused images and dangling images

#set -x

dockerclean(){
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
    docker image prune -a --force
    docker container prune --force
    docker volume prune --force
    docker network prune --force
}
dockerclean

truncate -s 10M /var/lib/docker/containers/*/*-json.log