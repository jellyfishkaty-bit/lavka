#!/usr/bin/env bash
# Always prepare Flutter's Android plugin metadata before compiling.
set -euo pipefail
cd "$(dirname "$0")/.."
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true
flutter --disable-analytics
dart --disable-analytics
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
python3 tools/verify_debug_apk.py build/app/outputs/flutter-apk/app-debug.apk

# Requires fonttools: validates registered weights and Cyrillic in the packaged APK.
python3 tools/verify_typography.py build/app/outputs/flutter-apk/app-debug.apk
