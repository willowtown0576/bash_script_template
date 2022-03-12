#!/bin/bash

readonly EXIT_NORMAL=0
readonly EXIT_WARNING=4
readonly EXIT_ERROR=8

function common::start_logging() {
  local _log_file # ログ出力先ファイル(フルパス)

  while getopts d:h OPT; do
    case ${OPT} in
      d)
        _log_file=$OPTARG
        ;;
      h)
        cat << EOF
Usage:
  common::start_logging -d log_file [-h]
EOF
        exit "${EXIT_WARNING}"
        ;;
      *)
        echo "${FUNCNAME[0]}の引数に誤りがあります"
        exit "${EXIT_ERROR}"
        ;;
    esac
  done

  if [[ ! -d $(dirname "${_log_file}") ]]; then
    # shellcheck disable=SC2086
    echo "ログ出力先:$(dirname ${_log_file})/が存在しません"
    exit "${EXIT_ERROR}"
  fi

  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME:+${FUNCNAME}(): }'
  exec 2> "${_log_file}"
  set -ux
}
