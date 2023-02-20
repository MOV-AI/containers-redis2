# This Dockerfile is the base image for Mov.ai Redis
FROM redislabs/rejson:2.0.11
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
    apt-get -y install --no-install-recommends redis-tools redis-redisearch \
    build-essential apt-transport-https curl python3 python3-dev python3-pip python3-setuptools software-properties-common unzip wget gnupg &&\
    apt-get clean -y > /dev/null &&\
    /usr/bin/pip3 install wheel rdbtools python-lzf &&\
    rm -rf /var/cache/apt/* &&\
    rm -rf /var/lib/apt/lists/*  &&\
    rm -rf /tmp/* &&\
    mkdir -p /default &&\
    chown -R redis:redis /usr/lib/redis/modules/redisearch.so &&\
    chmod -R 755 /usr/lib/redis/modules/redisearch.so &&\
    echo 'loadmodule /usr/lib/redis/modules/redisearch.so' >> /etc/redis/redis.conf

ENTRYPOINT ["movai-entrypoint.sh","/etc/redis.conf"]
