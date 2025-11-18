#!/bin/bash
set -e # exit on error

# Kiểm tra số lượng tham số
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <debug|release>"
  exit 1
fi

MODE=$1

cd web

echo "Building web in $MODE mode"

# NPM_CLI=$(which npm)
NPM_CLI=/home/duongtc/.nvm/versions/node/v24.8.0/bin/npm

if [ "$MODE" == "debug" ]; then
  $NPM_CLI run build:debug
else
  $NPM_CLI run build
fi