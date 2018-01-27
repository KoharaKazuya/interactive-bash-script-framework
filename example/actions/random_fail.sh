#!/bin/bash

set -eu -o pipefail

# 事前確認コマンド
ls -la /private

# カウントアップ
countup_success=true
for i in {0..100}; do
  printf '%s' "$i"
  if [ $(( $RANDOM % 100 )) -lt 10 ]; then
    printf '%s' ' Fail!' >&2
    countup_success=false
  fi
  printf '\n'
done

# カウントアップ成否の評価
$countup_success
