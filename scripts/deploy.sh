#!/usr/bin/env bash

IMG=mongrelion/blog
TAG=$(git log -1 --pretty=%H)
ssh carlosleon.info <<EOF
docker pull ${IMG}:${TAG}
docker rm -f blog
docker run -d --name blog -p 80:80 -p 443:443 ${IMG}:${TAG}
docker ps
EOF
