#!/bin/bash

# Define Variables
# shellcheck disable=SC2164
# shellcheck disable=SC2046
readonly BASE_DIR=$(cd $(dirname "${0}")/..; pwd)
readonly SHELL_NAME=$(basename "${0}")

# Import Extra Files
source "${BASE_DIR}/lib/common.sh"

# Define Functions
function main() {
  echo "Hello World!"
}

# Run
common::start_logging -d "${BASE_DIR}/log/$(date +%Y%m%d)_${SHELL_NAME%.sh}.log"
main
