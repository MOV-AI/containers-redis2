#!/bin/bash
#
# Copyright 2021 MOV.AI
#
#    Licensed under the Mov.AI License version 1.0;
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        https://www.mov.ai/flow-license/
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# File: docker-entrypoint.sh
set -m

sed -i -e "/^port:/s/:.*/ $REDIS_PORT/" /etc/redis.conf

# Run command in background
exec docker-entrypoint.sh ${@} &

HOST=localhost
PORT=$REDIS_PORT

printf "Waiting redis on %s:.\n" "$HOST:$PORT"
while ! redis-cli -h $HOST -p $PORT ping | grep -q PONG; do
    sleep 1
    printf "."
done
printf "\nRedis is UP\n"

# Run any needed APT install
if [ -n "${APT_AUTOINSTALL}" ]; then
    if [ -f "${MOVAI_HOME}/.first_run_autoinstall" ] && [ "${APT_AUTOINSTALL}" = "once"  ]; then
        printf "APT autoinstall: skipped\n"
    else
        printf "APT autoinstall:\n"
        # If we have apt keys to add
        if [ -n "${APT_KEYS_URL_LIST}" ]; then
            for key_url in ${APT_KEYS_URL_LIST//,/ }; do
                printf "APT Key add: %s\n" "${key_url}"
                curl -fsSL "${key_url}" | apt-key add -
            done
        fi

        # Switching separator to comma
        SAVEIFS=$IFS
        IFS=,

        # If we have apt repos to add
        if [ -n "${APT_REPOS_LIST}" ]; then
            for ppa in ${APT_REPOS_LIST}; do
                printf "APT Repo add: %s\n" "${ppa}"
                if add-apt-repository -y "${ppa}" > /dev/null 2>&1; then
                    printf "OK\n"
                else
                    printf "FAILED\n"
                fi
            done
        fi

        # If we have packages on our env var we do install
        if [ -n "${APT_INSTALL_LIST}" ]; then
            printf "APT Install list: %s\n" "${APT_INSTALL_LIST}"
            apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get --quiet -y --no-install-recommends install ${APT_INSTALL_LIST}
            apt-get clean -y
        fi

        # Switching back separator to default
        IFS=$SAVEIFS
        touch "${MOVAI_HOME}/.first_run_autoinstall"
        printf "APT autoinstall: done\n"
    fi
fi

# now we bring the primary process back into the foreground
fg %

# remove job control
set +m