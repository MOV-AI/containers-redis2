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
# File: update_database.sh
set -eo pipefail

REDIS_CLI="/usr/local/bin/redis-cli"

function update_all () {
	if [ -f all_db_patch.gz ]; then
		printf "    Applying All.....\n"
		gunzip -c all_db_patch.gz | ${REDIS_CLI} -n 0 --pipe
	fi
}

function update_core () {
	if [ -f core_db_patch.gz ]; then
		printf "    Applying Core.....\n"
		gunzip -c core_db_patch.gz | ${REDIS_CLI} -n 0 --pipe
	fi
}

function update_runtime () {
	if [ -f runtime_db_patch.gz ]; then
		printf "    Applying Runtime.....\n"
		gunzip -c runtime_db_patch.gz | ${REDIS_CLI} -n 0 --pipe
	fi
}

function update_libraries () {
	if [ -f libraries_db_patch.gz ]; then
		printf "    Applying Libraries.....\n"
		gunzip -c libraries_db_patch.gz | ${REDIS_CLI} -n 0 --pipe
	fi
}

UPDATEFILE='/tmp/database.zip'
PATCH_KEY='System:Patch,Value:'
PATCH_KEY_FILE='patch-key'

if [ ! -f ${UPDATEFILE} ]; then
	printf "Please specify artifact...\n"
	exit 0
fi

CMD=

for ARG in "${@:1}"
do
    case ${ARG} in
        all*)
			CMD="update_all"
			break
			;;
        core*)
			CMD+=" update_core"
			;;
        runtime*)
			CMD+=" update_runtime"
			;;
        libraries*)
			CMD+=" update_libraries"
			;;
    esac
done

# on no command
[ -z "${CMD}" ] && exit 1

TEMP_DIR=$(mktemp -d)
pushd ${TEMP_DIR} >/dev/null
unzip ${UPDATEFILE}

# get patch key override value
[ -f ${PATCH_KEY_FILE} ] && PATCH_KEY="System:$(cat ${PATCH_KEY_FILE}),Value:"

# get latest version
_LATEST=$(${REDIS_CLI} GET ${PATCH_KEY})
if [ -z "${_LATEST}" ]; then
	# apply all
	_TO_APPLY="$(cat manifest)"
else
	_TO_APPLY="$(sed '0,/'${_LATEST}'/d' manifest)"
fi

for PATCH in ${_TO_APPLY}; do
	# unpack that patch
	tar -xzvf "update-${PATCH}.tar.gz"
	# call commands
	echo "Applying ${PATCH}..."
	for FUNCTION in ${CMD}; do
		${FUNCTION}
	done
	# cleanup
	rm *_db_patch.gz
	_LATEST=${PATCH}
done

# tag database
${REDIS_CLI} SET ${PATCH_KEY} ${_LATEST}

# and more cleanup
popd >/dev/null
rm -r ${TEMP_DIR}
rm ${UPDATEFILE}
