#!/usr/bin/env bash
# Vercel build: install Flutter (Linux) and compile web release.
set -euo pipefail

API_BASE="${API_BASE:-https://fitos-backend-55g6.onrender.com/api/v1}"
FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
  export PATH="$FLUTTER_HOME/bin:$PATH"
  flutter config --enable-web --no-analytics
  flutter precache --web
fi

flutter --version
flutter pub get
flutter build web --release \
  --no-wasm-dry-run \
  --dart-define="API_BASE=${API_BASE}"

echo "Web build complete → build/web (API_BASE=${API_BASE})"
