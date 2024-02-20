#!/bin/bash
#-*- coding: utf-8 -*-
set -Ceuo pipefail

# 共通関数の読み込み
source "$(dirname $0)/../lib/common.sh"

function usage() {
  cat <<EOF
Name:
  ${_SCRIPT_NAME_} - シェルスクリプトテンプレート

Usage:
  ${_SCRIPT_NAME_} [--production|--staging|--develop] [options] [-- args]

Options:
  --production or -p
    本番環境モードで実行する
  --staging or -s
    検証環境モードで実行する
  --develop or -d
    開発環境モードで実行する
  --verbose, -v
    トレースログを出力する
  --help, -h
    ヘルプを表示する
  -- arg1 arg2...
    main関数に渡す引数を指定する

Dependency:
  ${_BASE_DIR_}/lib/common.sh

Exit status:
  0 on success
  non zero on error

Version:
  1.0.0

Author:
  willowtown0576
EOF
}

# オプション解析
declare -a ARGS=()
MODE=""
IS_VERBOSE=${_FALSE_}

while (( $# > 0 )); do
  case "$1" in
    --production|-p)
      MODE="production"
      shift
      ;;
    --staging|-s)
      MODE="staging"
      shift
      ;;
    --develop|-d)
      MODE="develop"
      shift
      ;;
    --verbose|-v)
      IS_VERBOSE=${_TRUE_}
      shift
      ;;
    --help|-h)
      usage
      exit ${_SUCCESS_}
      ;;
    --)
      shift
      while (( $# > 0 )); do
        ARGS+=("$1")
        shift
      done
      break
      ;;
    *)
      common::logging "オプションの指定に誤りがあります $@"
      exit ${_ERROR_}
      ;;
  esac
done

# MODEの確認
if [[ -z "${MODE}" ]]; then
  common::logging "必須オプション: [--production|--staging|--develop]"
  exit ${_ERROR_}
fi

# トレースログ出力
if (( IS_VERBOSE == _TRUE_ )); then
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME:+${FUNCNAME}(): }'
  set -x
fi

# 以降の標準出力、標準エラー出力をログファイルにリダイレクトする
exec >> "${_BASE_DIR_}/log/$(date "+%Y%m%d%H%M")_$(basename "${0%.*}").log" 2>&1

# このmain関数に主処理を書く
function main() {
  # 引数ありの場合は以下のように取得する
  # 最初の引数を代入
  # local _arg1="$1"
  # 第二引数を代入
  # local _arg2="$2"
  # 引数すべてを一つに変数に代入
  # local _arg_all="$@"

  # JSONファイルから各環境ごとの設定値を読み取る
  common::jq_wrapper ".${MODE}.greet" "${_BASE_DIR_}/conf/template.json"

  # 何らかの処理

  # 戻り値返却
  return ${_SUCCESS_}
}

# main関数実行
main

# main関数に引数を渡す場合は以下のようにする。
# main ${ARGS[@]}
