#!/usr/bin/env bash
set -e
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter không có trong PATH."
  exit 1
fi
if [ ! -d android ]; then
  rm -rf _platform_seed
  flutter create _platform_seed --project-name expense_tracker --platforms=android,ios
  cp -R _platform_seed/android ./android
  cp -R _platform_seed/ios ./ios
  rm -rf _platform_seed
fi
cp platform_templates/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
if [ -f android/app/build.gradle.kts ]; then
  cp platform_templates/android/build.gradle.kts android/app/build.gradle.kts
elif [ -f android/app/build.gradle ]; then
  cp platform_templates/android/build.gradle android/app/build.gradle
fi
flutter pub get
flutter analyze
