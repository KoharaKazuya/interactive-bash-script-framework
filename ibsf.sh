#
# Interactive Bash Script Framework
#
# Define ibsf_* functions.

# Trap errors
#
# Operation script must call this as soon as possible.
ibsf_begin_trap() {
  set -E
  trap 'ibsf_onerror' ERR
  trap 'ibsf_oninterapt' INT
}
# @private
ibsf_onerror() {
  trap ERR # トラップを解除する
  printf '\n\n'
  print_fail '処理に失敗したため、スクリプトの実行を中断します。'
  printf '\n\n%s' "$_ibsf_deco_weak"
  printf '  File: %s\n' "${BASH_SOURCE[1]}"
  printf '  Line: %s\n' "${BASH_LINENO[0]}"
  printf '%s\n' "$_ibsf_deco_reset"
}
# @private
ibsf_oninterapt() {
  trap INT # トラップを解除する
  printf '\n\n'
  print_info '中断が要求されました。'
  printf '\n\n'
}

# Show message and confirmation
#
# @param $* messages
ibsf_message() {
  print_separator
  print_message "$*"
  printf '\n\n'
  print_ask '(Enter で次へ) '
  read
}

# Show message (from file) and confirmation
#
# @param $1 message file path
ibsf_message_file() {
  print_separator
  cat "$1" | sed -E 's/^/  /'
  printf '\n'
  print_ask '(Enter で次へ) '
  read
}

# Confirm execution of external script
#
# Show content of external script, and confirm before execution.
#
# @param $1 action file path
# @param $2 action friendly name instead of action file path (optional)
ibsf_exec_action() {
  [ $# -gt 0 ]
  local action_file="$1"
  local action_name
  if [ $# -gt 1 ]; then
    action_name="$2"
  else
    action_name="$action_file"
  fi

  print_separator

  if ! [ -f "$action_file" ]; then
    print_fail "$action_file が見つかりません。"
    printf '\n\n'
    return 1
  fi
  if ! [ -x "$action_file" ]; then
    print_fail "$action_file は実行ファイルではありません。"
    printf '\n\n'
    return 1
  fi

  print_ask "$action_name を実行します。よろしいですか？ (y/n/s/q/?) "
  read answer
  printf '\n'

  case "$answer" in
    'q' ) print_info '中断が要求されました。'
          printf '\n\n'
          return 1
          ;;
    'y' ) print_info "$action_name を実行します。"
          printf '\n\n'
          local exit_code=0
          "$action_file" || exit_code="$?"
          if [ "$exit_code" != 0 ]; then
            printf '\n'
            print_fail "$action_name の実行中にエラーが発生しました。"
            printf '\n\n%s' "$_ibsf_deco_weak"
            printf '  Exit Code: %d\n' "$exit_code"
            printf '%s\n' "$_ibsf_deco_reset"
            return 1
          fi
          printf '\n'
          print_ok "$action_name を実行しました。"
          printf '\n\n'
          return 0
          ;;
    'n' ) print_warn "$action_name の実行をスキップします。"
          printf '\n\n'
          return 0
          ;;
    's' ) print_info "$action_name のファイル内容を表示します。"
          printf '\n\n'
          if file --mime "$action_file" | grep 'charset=binary' >/dev/null 2>&1; then
            cat "$action_file" | xxd | "${PAGER:-less}" || :
          else
            cat "$action_file" | "${PAGER:-less}" || :
          fi
          ;;
    '?' ) printf '  y: 実行する\n'
          printf '  n: スキップする\n'
          printf '  s: ファイル内容を表示する\n'
          printf '  q: 中断する\n'
          printf '\n'
          ;;
  esac

  # 入力が正しくないため、再度問い合わせる
  ibsf_exec_action "$@"
}

# @private standard output decorations
_ibsf_deco_reset="$(     tput sgr0     2>/dev/null || : )"
_ibsf_deco_underline="$( tput smul     2>/dev/null || : )"
_ibsf_deco_bold="$(      tput bold     2>/dev/null || : )"
_ibsf_deco_weak="$(      tput dim      2>/dev/null || : )"
_ibsf_deco_rev="$(       tput rev      2>/dev/null || : )"
_ibsf_deco_red="$(       tput setaf 1  2>/dev/null || : )"
_ibsf_deco_green="$(     tput setaf 2  2>/dev/null || : )"
_ibsf_deco_yellow="$(    tput setaf 3  2>/dev/null || : )"
_ibsf_deco_cyan="$(      tput setaf 6  2>/dev/null || : )"
_ibsf_deco_white="$(     tput setaf 7  2>/dev/null || : )"

# Show line sparator
print_separator() {
  printf '%s%s%s' "$_ibsf_deco_reset" "$_ibsf_deco_underline" "$_ibsf_deco_weak"
  printf "%$( tput cols || : )s"
  printf '%s\n\n' "$_ibsf_deco_reset"
}
# Show message with indent
#
# @param $* message
print_message() {
  printf '%s       %s%s%s' "$_ibsf_deco_reset" "$_ibsf_deco_bold" "$*" "$_ibsf_deco_reset"
}
# Show message with label
#
# @param $1 color of message (one of _ibsf_deco_* colors)
# @param $2 string of label (must be 4 characters)
# @param $3 message
print_label() {
  printf '%s%s%s %s %s %s%s%s' "$_ibsf_deco_reset" "$1" "$_ibsf_deco_rev" "$2" "$_ibsf_deco_reset" "$1" "$3" "$_ibsf_deco_reset"
}
# Show message with 'OK' label
#
# @param $* message
print_ok() {
  print_label "$_ibsf_deco_green" ' OK ' "$*"
}
# Show message with 'ASK' label
#
# @param $* message
print_ask() {
  print_label "$_ibsf_deco_cyan" ' ASK' "$*"
}
# Show message with 'INFO' label
#
# @param $* message
print_info() {
  print_label "$_ibsf_deco_white" 'INFO' "$*"
}
# Show message with 'WARN' label
#
# @param $* message
print_warn() {
  print_label "$_ibsf_deco_yellow" 'WARN' "$*"
}
# Show message with 'FAIL' label
#
# @param $* message
print_fail() {
  print_label "$_ibsf_deco_red" 'FAIL' "$*"
}
