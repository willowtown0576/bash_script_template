#!/bin/bash
#-*- coding: utf-8 -*-
set -Ceuo pipefail

# 共通関数の読み込み
source "$(dirname $0)/../lib/common.sh"

function usage() {
  cat <<EOF
Name:
  $(basename $0) - シェルスクリプトテンプレート

Usage:
  $(basename $0) [--production|--staging|--develop] [options] [-- args]

Options:
  --production
    本番環境モードで実行する
  --staging
    検証環境モードで実行する
  --develop
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
    --production)
      MODE="production"
      shift
      ;;
    --staging)
      MODE="staging"
      shift
      ;;
    --develop)
      MODE="develop"
      shift
      ;;
    --verbose|-v)
      IS_VERBOSE=${_TRUE_}
      shift
      ;;
    --help|-h)
      usage
      exit ${_WARNING_}
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
if [[ -z "${MODE}" ]];then
  common::logging "必須オプション: [--production|--staging|--develop]"
  exit ${_ERROR_}
fi

# トレースログ出力
if (( IS_VERBOSE == _TRUE_ )); then
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME:+${FUNCNAME}(): }'
  set -x
fi

function main() {
  common::parse_json ".${MODE}.greet" "${_BASE_DIR_}/conf/template.json"
}

# Run
main
