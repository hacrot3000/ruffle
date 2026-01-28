#!/usr/bin/env bash
set -euo pipefail

echo "==> Ruffle full web build script"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
TARGET="wasm32-unknown-unknown"
WASM_BINDGEN_VERSION="0.2.108"

cd "$ROOT_DIR"

echo "==> Checking Rust target..."
rustup target add $TARGET >/dev/null 2>&1 || true

echo "==> Checking wasm-bindgen-cli version..."
if ! command -v wasm-bindgen >/dev/null; then
  echo "Installing wasm-bindgen-cli $WASM_BINDGEN_VERSION"
  cargo install wasm-bindgen-cli --version $WASM_BINDGEN_VERSION
else
  INSTALLED_VER=$(wasm-bindgen --version | awk '{print $2}')
  if [[ "$INSTALLED_VER" != "$WASM_BINDGEN_VERSION" ]]; then
    echo "Updating wasm-bindgen-cli to $WASM_BINDGEN_VERSION"
    cargo install wasm-bindgen-cli --version $WASM_BINDGEN_VERSION --force
  fi
fi

echo "==> Cleaning old build artifacts..."
rm -rf target
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo "==> Building ruffle_core (wasm)..."
RUSTFLAGS="--cfg wasm_js --cfg web_sys_unstable_apis" cargo build \
  -p ruffle_core \
  --target wasm32-unknown-unknown \
  --release

echo "==> Building ruffle_web (wasm)..."
RUSTFLAGS="--cfg wasm_js --cfg web_sys_unstable_apis" cargo build \
  -p ruffle_web \
  --target wasm32-unknown-unknown \
  --release


WASM_FILE="target/$TARGET/release/ruffle_web.wasm"

if [[ ! -f "$WASM_FILE" ]]; then
  echo "ERROR: wasm output not found!"
  exit 1
fi

echo "==> Running wasm-bindgen..."
wasm-bindgen \
  --target web \
  --no-typescript \
  --weak-refs \
  --reference-types \
  --out-dir "$DIST_DIR" \
  "$WASM_FILE"

echo "==> Building JavaScript wrappers with npm..."
NPM_CLI=/home/duongtc/.nvm/versions/node/v24.8.0/bin/npm
cd web
$NPM_CLI run build --workspace=ruffle-core
cd ..

echo "==> Fixing ES module imports (adding .js extensions)..."
# Script cẩn thận hơn: chỉ thay thế import/export statements
find "$DIST_DIR" -name "*.js" -type f | while read -r file; do
  # Fix: from "./path" -> from "./path.js"
  # Fix: from "../../path" -> from "../../path.js"
  # Chỉ áp dụng cho import và export, không ảnh hưởng các string khác
  sed -i \
    -e 's|from "\(\./[^"]*\)";|from "\1.js";|g' \
    -e 's|from "\(\.\./[^"]*\)";|from "\1.js";|g' \
    -e 's|export \* from "\(\./[^"]*\)";|export * from "\1.js";|g' \
    -e 's|export \* from "\(\.\./[^"]*\)";|export * from "\1.js";|g' \
    -e 's|\.\js\.js"|.js"|g' \
    "$file"
done
echo "==> Fixed $(find "$DIST_DIR" -name "*.js" | wc -l) JavaScript files"

echo "==> Copying web static files..."
# Copy các file JavaScript wrapper từ npm build
cp -r web/packages/core/dist/* "$DIST_DIR/" 2>/dev/null || true

echo "==> Build completed successfully!"
echo "Output directory: $DIST_DIR"
