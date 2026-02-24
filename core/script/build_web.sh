#!/bin/bash
set -e # exit on error

# Kiểm tra số lượng tham số
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <debug|release>"
  exit 1
fi

MODE=$1

# Thêm export các biến môi trường (Có thể thay đổi tuỳ ý)
export RUFFLE_VERSION=${RUFFLE_VERSION:-"2.1.1-CD"}
export RUFFLE_VERSION_NAME=${RUFFLE_VERSION_NAME:-"568E CD"}
export CFG_RELEASE_CHANNEL=${CFG_RELEASE_CHANNEL:-"CD"}

cd ../web

echo "Building web in $MODE mode"

# NPM_CLI=$(which npm)
NPM_CLI=/home/duongtc/.nvm/versions/node/v24.8.0/bin/npm

rustup target add wasm32-unknown-unknown

if [ "$MODE" == "debug" ]; then
  # cargo build -p ruffle_web
  cargo build -p ruffle_web --target wasm32-unknown-unknown
  $NPM_CLI run build:debug
else
  cargo build -p ruffle_web --target wasm32-unknown-unknown --release
  $NPM_CLI run build
fi