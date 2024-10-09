[![Build&Deploy redis images](https://github.com/MOV-AI/containers-redis2/actions/workflows/docker-ci.yml/badge.svg?branch=main)](https://github.com/MOV-AI/containers-redis2/actions/workflows/docker-ci.yml)

# containers-redis2
Base image for MOV.AI Redis

This image uses [RedisJSON](https://github.com/RedisJSON/RedisJSON) v2.11 as a base image

# quickstart

    docker run -p 6379:6379 --name redis2 pubregistry.aws.cloud.mov.ai/ce/redis2

# run with specific port

    docker run -e REDIS_PORT=6380 -p 6380:6380 --name redis2 pubregistry.aws.cloud.mov.ai/ce/redis2

# run with specific log level

    docker run -e REDIS_LOG_LEVEL=notice -p 6379:6379 --name redis2 pubregistry.aws.cloud.mov.ai/ce/redis2


## Build

    docker build -t redis2 .
