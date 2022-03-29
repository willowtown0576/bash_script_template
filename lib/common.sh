#!/bin/bash
#-*- coding: utf-8 -*-

readonly _BASE_DIR_="$(cd $(dirname $0)/.. && pwd)"
readonly _SUCCESS_=0
readonly _WARNING_=1
readonly _ERROR_=2
readonly _CRITICAL=4
readonly _TRUE_=0
readonly _FALSE_=1

# Name:
#   common::logging - ログ出力関数
# Usage:
#   common::logging message
# Options:
#   None
# Dependency:
#   None
# Returns:
#   0 on success
#   non zero on error
function common::logging() {
  local _msg
  _msg="$1"
  _msg="$(date '+%Y/%m/%d %H:%M:%S') - $(basename $0) - ${_msg}"
  logger "${_msg}"
  echo "${_msg}" 1>&2
}

# Name:
#   common::parse_json - JSONファイル読み取り関数
# Usage:
#   common::parse_json filter json
# Options:
#   None
# Dependency:
#   jq
# Returns:
#   0 on success
#   non zero on error
function common::parse_json() {
  local _filter
  local _json
  _filter="$1"
  _json="$2"

  # jqコマンドがインストールされているかを確認
  if ! type jq > /dev/null 2>&1; then
    common::logging "jqコマンドがインストールされていません"
    exit ${_CRITICAL_}
  fi

  if [[ ! -f "${_json}" ]]; then
    common::logging "${_json}が存在しません"
    exit ${_ERROR_}
  fi

  if ! jq -r "${_filter}" "${_json}"; then
    common::logging "jqコマンドに失敗しました。実行コマンド: jq -r ${_filter} ${_json}"
    exit ${_ERROR_}
  fi

  return ${_SUCCESS_}
}
