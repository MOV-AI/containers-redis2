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
# File: install-packages.sh
# File: dump_database.sh
set -eo pipefail

function dump_all() {
    mkdir -p ${TEMP_DIR}/all
    rdb --command protocol ${RDBFILE} --file ${TEMP_DIR}/all/all.data
    cat ${TEMP_DIR}/all/*.data | gzip > ${OUTPUT_DIR}/all_db_patch.gz
}

function dump_all_core() {
    mkdir -p ${TEMP_DIR}/core
    rdb --command protocol --key "Ports:" ${RDBFILE} --file ${TEMP_DIR}/core/ports.data
    rdb --command protocol --key "System:" ${RDBFILE} --file ${TEMP_DIR}/core/system.data
    rdb --command protocol --key "Callback:server4" ${RDBFILE} --file ${TEMP_DIR}/core/backend_callback.data
    rdb --command protocol --key "Node:server4" ${RDBFILE} --file ${TEMP_DIR}/core/backend_node.data
    cat ${TEMP_DIR}/core/*.data | gzip > ${OUTPUT_DIR}/core_db_patch.gz
}

function dump_all_runtime () {
    mkdir -p ${TEMP_DIR}/runtime
    rdb --command protocol --key "Flow:" ${RDBFILE} --file ${TEMP_DIR}/runtime/flow.data
    rdb --command protocol --key "Layout:" ${RDBFILE} --file ${TEMP_DIR}/runtime/layout.data
    rdb --command protocol --key "GraphicScene:" ${RDBFILE} --file ${TEMP_DIR}/runtime/graph_scene.data
    rdb --command protocol --key "GraphicAsset:" ${RDBFILE} --file ${TEMP_DIR}/runtime/graph_asset.data
    rdb --command protocol --key "Form:" ${RDBFILE} --file ${TEMP_DIR}/runtime/form.data
    rdb --command protocol --key "Annotation:" ${RDBFILE} --file ${TEMP_DIR}/runtime/annotation.data
    rdb --command protocol --key "StateMachine:" ${RDBFILE} --file ${TEMP_DIR}/runtime/state_machine.data
    cat ${TEMP_DIR}/runtime/*.data | gzip > ${OUTPUT_DIR}/runtime_db_patch.gz
}

function dump_all_libraries () {
    mkdir -p ${TEMP_DIR}/libraries
    rdb --command protocol --key "Callback:" -o "Callback:server4" ${RDBFILE} --file ${TEMP_DIR}/libraries/callback.data
    rdb --command protocol --key "Node:" -o "Node:server4" ${RDBFILE} --file ${TEMP_DIR}/libraries/node.data
    rdb --command protocol --key "Message:" ${RDBFILE} --file ${TEMP_DIR}/libraries/message.data
    cat ${TEMP_DIR}/libraries/*.data | gzip > ${OUTPUT_DIR}/libraries_db_patch.gz
}

RDBFILE=/data/dump.rdb
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
OUTPUT_DIR=/data/exports/dump-${TIMESTAMP}

for ARG in "${@:1}"
do
    case ${ARG} in
        all*)
            TEMP_DIR=$(mktemp -d)
            # make sure we have the latest data on disk
            redis-cli SAVE > /dev/null
            mkdir -p ${OUTPUT_DIR}
            dump_all
            cd ${OUTPUT_DIR}
            tar czf update.tar.gz all_db_patch.gz
            rm -rf ${TEMP_DIR}
            echo ${OUTPUT_DIR}
            exit 0
            ;;
        core*)
            TEMP_DIR=$(mktemp -d)
            # make sure we have the latest data on disk
            redis-cli SAVE > /dev/null
            mkdir -p ${OUTPUT_DIR}
            dump_all_core
            cd ${OUTPUT_DIR}
            tar czf update.tar.gz core_db_patch.gz
            rm -rf ${TEMP_DIR}
            echo ${OUTPUT_DIR}
            exit 0
            ;;
        runtime)
            TEMP_DIR=$(mktemp -d)
            # make sure we have the latest data on disk
            redis-cli SAVE > /dev/null
            mkdir -p ${OUTPUT_DIR}
            dump_all_runtime
            cd ${OUTPUT_DIR}
            tar czf update.tar.gz runtime_db_patch.gz
            rm -rf ${TEMP_DIR}
            exit 0
            ;;
        libraries*)
            TEMP_DIR=$(mktemp -d)
            # make sure we have the latest data on disk
            redis-cli SAVE > /dev/null
            mkdir -p ${OUTPUT_DIR}
            dump_all_libraries
            cd ${OUTPUT_DIR}
            tar czf update.tar.gz libraries_db_patch.gz
            rm -rf ${TEMP_DIR}
            echo ${OUTPUT_DIR}
            exit 0
            ;;
    esac
done

exit 1
