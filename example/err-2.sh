#!/bin/bash

set -eu -o pipefail

cd "$(dirname "$0")"
source ./functions/*

ibsf_begin_trap

ibsf_message 'デモを実行します。'
ibsf_exec_action './actions/no_executable.sh' '実行不可ファイル'
