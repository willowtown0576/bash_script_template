#!/bin/bash
#-*- coding: utf-8 -*-

# 共通の定数を定義
# common.shで定義される定数は、アンダーバーで囲むことによって判別できるようにする。
readonly _BASE_DIR_="$(cd $(dirname $0)/.. && pwd)"
readonly _SCRIPT_NAME_="$(basename $0)"
readonly _SUCCESS_=0
readonly _ERROR_=1
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
  local _msg="$1"

  # ログメッセージに日付と実行されたスクリプト名を付与
  _msg="$(date '+%Y/%m/%d %H:%M:%S') - $(basename $0) - ${_msg}"

  # システム側のログファイルにも出力
  logger "${_msg}"

  # 標準出力を標準エラー出力にリダイレクト
  echo "${_msg}" 1>&2
}

# Name:
#   common::jq_wrapper - jqコマンドのラッパー関数。
# Usage:
#   common::jq_wrapper filter json_file_path
# Options:
#   None
# Dependency:
#   jq
# Returns:
#   0 on success
#   non zero on error
function common::jq_wrapper() {
  local _filter="$1"
  local _json="$2"

  # jqコマンドがインストールされているかを確認
  if ! type jq > /dev/null 2>&1; then
    common::logging "jqコマンドがインストールされていません"
    return ${_ERROR_}
  fi

  # JSONファイルの存在確認
  if [[ ! -f "${_json}" ]]; then
    common::logging "${_json}が存在しません"
    return ${_ERROR_}
  fi

  # JSONのフォーマットチェック
  if ! jq empty "${_json}" > /dev/null 2>&1; then
    common::logging "${_json}のフォーマットが不正です"
    return ${_ERROR_}
  fi

  # フィルタが文法的に正しいかチェック
  if ! jq -e "${_filter}" "${_json}" > /dev/null 2>&1; then
    common::logging "${_filter}のフィルタ式が不正、または結果がnullです"
    return ${_ERROR_}
  fi

  # jqコマンドの実行
  if ! jq -r "${_filter}" "${_json}"; then
    common::logging "jqコマンドに失敗しました。実行コマンド: jq -r ${_filter} ${_json}"
    return ${_ERROR_}
  fi

  return ${_SUCCESS_}
}
