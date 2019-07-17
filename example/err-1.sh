#!/bin/bash

set -eu -o pipefail

cd "$(dirname "$0")"
source ./functions/*

ibsf_begin_trap

ibsf_message 'デモを実行します。'
ibsf_exec_action './actions/no_file.sh' '存在しないアクション'
