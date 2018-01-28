#!/bin/bash

set -eu -o pipefail

cd "$(dirname "$0")"
source ./functions/*

ibsf_begin_trap

ibsf_message 'デモを実行します。'
ibsf_message_file './actions/description.txt'
ibsf_exec_action './actions/random_fail.sh' 'ランダム Fail 処理'
ibsf_exec_action './actions/success.sh'
ibsf_exec_action './actions/sleep_100.sh' 'スリープ'

ibsf_message '全ての処理が完了しました！'
