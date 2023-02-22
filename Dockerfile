# This Dockerfile is the base image for Mov.ai Redis
FROM redis/redis-stack-server:6.2.6-v4
# Labels
LABEL description="MOV.AI Redis Image"
LABEL maintainer="maintainer@mov.ai"
LABEL movai="redis"

# Configure and install
COPY files/etc/ /etc/
COPY files/bin/ /usr/local/bin/

ENV REDIS_PORT 6379

# hadolint ignore=DL3008
RUN apt-get update &&\
    apt-get -y install --no-install-recommends redis-tools \
    build-essential apt-transport-https curl python3 python3-dev python3-pip python3-setuptools software-properties-common unzip wget gnupg &&\
    apt-get clean -y > /dev/null &&\
    /usr/bin/pip3 install wheel rdbtools python-lzf &&\
    rm -rf /var/cache/apt/* &&\
    rm -rf /var/lib/apt/lists/*  &&\
    rm -rf /tmp/*

ENTRYPOINT ["movai-entrypoint.sh","/etc/redis.conf"]
