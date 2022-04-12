[![Build&Deploy redis images](https://github.com/MOV-AI/containers-redis2/actions/workflows/docker-ci.yml/badge.svg?branch=main)](https://github.com/MOV-AI/containers-redis2/actions/workflows/docker-ci.yml)

# containers-redis2
Base image for MOV.AI Redis 

This image uses [RedisJSON](https://github.com/RedisJSON/RedisJSON) v2.07 as a base image

# quickstart

    docker run -p 6379:6379 --name redis2 pubregistry.aws.cloud.mov.ai/ce/redis2
