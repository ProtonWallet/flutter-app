#!/bin/bash
set -e
# Set environment variables
export WALLET_HOST="proton.me"
export CARGO_REGISTRIES_PROTON_PUBLIC_INDEX="sparse+https://rust-registry.proton.me/index/"
export GRADLE_USER_HOME=`pwd`/.gradle
export RAMP_API_KEY=""
export MOONPAY_API_KEY=""
export SENTRY_API_KEY=""

# 1. Configure Android SDK and NDK paths
echo "Configuring Android SDK and NDK paths..."
echo 'sdk.dir=/opt/android/sdk' >> ./android/local.properties
echo 'ndk.dir=/opt/android/sdk/ndk/25.1.8937393' >> ./android/local.properties

# 2. Environment check
echo "Checking environment..."
rustup show
flutter doctor -v
cargo ndk --version
go version

# 3. Clean caches and build files
echo "Cleaning caches and build files..."
rm -rf ~/.gradle/caches/
rm -rf .gradle/caches/
flutter clean

# 4. Repair and get dependencies
echo "Repairing and getting dependencies..."
flutter pub cache repair
flutter pub get

# 5. Run build_runner
echo "Running build_runner..."
flutter pub run build_runner build

# 6. Generate localization files
echo "Generating localization files..."
flutter gen-l10n

# 7. Build APK
echo "Building APK..."
flutter build apk --flavor prod -vv > apk.log.txt 2> apk.err.txt

# 8. Build App Bundle (optional)
# echo "Building App Bundle..."
# flutter build appbundle --flavor prod -vv > log.txt 2> err.txt

echo "Build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-prod-release.apk"
echo "App Bundle location: build/app/outputs/bundle/prodRelease/app-prod-release.aab"