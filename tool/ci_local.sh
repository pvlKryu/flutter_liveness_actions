#!/usr/bin/env bash
# Run the same checks as .github/workflows/ci.yml before pushing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Prefer Flutter's bundled Dart so formatting matches CI (not Homebrew dart).
FLUTTER_BIN="$(command -v flutter)"
FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_BIN")/.." && pwd)"
DART_BIN="${FLUTTER_ROOT}/bin/cache/dart-sdk/bin/dart"
if [[ ! -x "$DART_BIN" ]]; then
  DART_BIN="$(command -v dart)"
fi

echo "==> Toolchain"
flutter --version
"$DART_BIN" --version

echo "==> flutter pub get (package)"
flutter pub get

echo "==> dart format --set-exit-if-changed ."
"$DART_BIN" format --set-exit-if-changed .

echo "==> flutter analyze (package)"
flutter analyze lib test

echo "==> flutter test"
flutter test

echo "==> flutter pub get (example)"
flutter pub get --directory=example

echo "==> flutter analyze (example)"
(
  cd example
  flutter analyze
)

echo "==> flutter pub publish --dry-run"
flutter pub publish --dry-run

echo
echo "All CI checks passed."
