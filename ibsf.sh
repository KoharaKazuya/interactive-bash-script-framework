ibsf_begin_trap() {
  set -E
  trap 'ibsf_onerror' ERR
  trap 'ibsf_oninterapt' INT
}
ibsf_onerror() {
  print_fail '処理に失敗したため、スクリプトの実行を中断します。'
  printf '\n\n%s' "$_ibsf_deco_weak"
  printf '  File: %s\n' "${BASH_SOURCE[1]}"
  printf '  Line: %s\n' "${BASH_LINENO[0]}"
  printf '%s\n' "$_ibsf_deco_reset"
}
ibsf_oninterapt() {
  trap INT
  print_info '中断が要求されました。'
  printf '\n\n'
}

ibsf_message() {
  print_separator
  print_message "$*"
  printf '\n\n'
  print_ask '(Enter で次へ) '
  read
}

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

  print_info "$action_name を実行しようとしています。内容を出力します。"
  printf '\n\n%s' "$_ibsf_deco_weak"
  cat "$action_file" | sed -E 's/^/  /'
  printf '%s\n' "$_ibsf_deco_reset"

  print_ask "$action_name を実行します。よろしいですか？ (y/n/q/?) "
  read answer
  printf '\n'

  case "$answer" in
    'q' ) print_fail '中断が要求されたため、スクリプトの実行を中断します。'
          printf '\n\n'
          return 1
          ;;
    'y' ) print_info "$action_name を実行します。"
          printf '\n\n'
          if ! "$action_file"; then
            printf '\n'
            print_fail "$action_name の実行中にエラーが発生しました。"
            printf '\n\n'
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
    '?' ) printf '  y: 実行する\n'
          printf '  n: スキップする\n'
          printf '  q: 中断する\n'
          printf '\n'
          ;;
  esac

  # 入力が正しくないため、再度問い合わせる
  ibsf_exec_action "$@"
}

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

print_separator() {
  printf '%s%s%s' "$_ibsf_deco_reset" "$_ibsf_deco_underline" "$_ibsf_deco_weak"
  printf "%$( tput cols 2>/dev/null || : )s"
  printf '%s\n\n' "$_ibsf_deco_reset"
}
print_message() {
  printf '%s       %s%s%s' "$_ibsf_deco_reset" "$_ibsf_deco_bold" "$*" "$_ibsf_deco_reset"
}
print_label() {
  printf '%s%s%s %s %s %s%s%s' "$_ibsf_deco_reset" "$1" "$_ibsf_deco_rev" "$2" "$_ibsf_deco_reset" "$1" "$3" "$_ibsf_deco_reset"
}
print_ok() {
  print_label "$_ibsf_deco_green" ' OK ' "$*"
}
print_ask() {
  print_label "$_ibsf_deco_cyan" ' ASK' "$*"
}
print_info() {
  print_label "$_ibsf_deco_white" 'INFO' "$*"
}
print_warn() {
  print_label "$_ibsf_deco_yellow" 'WARN' "$*"
}
print_fail() {
  print_label "$_ibsf_deco_red" 'FAIL' "$*"
}
