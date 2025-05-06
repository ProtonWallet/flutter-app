#!/bin/bash
set -eu pipefail
ANDROID_COMMAND_LINE_TOOLS_HASH="bd1aa17c7ef10066949c88dc6c9c8d536be27f992a1f3b5a584f9bd2ba5646a0"
apt update
apt install -y openjdk-17-jdk openssh-client \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnueabihf \
    gcc-multilib
# Install cargo tools
rustup component add rustfmt
rustup component add clippy
# Install android targets
rustup target add aarch64-linux-android
rustup target add x86_64-linux-android
rustup target add armv7-linux-androideabi
rustup target add i686-linux-android
cargo install cargo-ndk
# Install binaryen
wget https://github.com/WebAssembly/binaryen/releases/download/version_116/binaryen-version_116-x86_64-linux.tar.gz -O /tmp/binaryen.tar.gz
pushd /tmp/ || exit 1
tar xf binaryen.tar.gz
mv /tmp/binaryen-version_116/bin/* /usr/bin
mv /tmp/binaryen-version_116/lib/* /usr/lib
mv /tmp/binaryen-version_116/include/* /usr/include
rm binaryen.tar.gz
rm -rf /tmp/binaryen-version_116
popd || exit 1
# Install Android NDK
mkdir -p /opt/android/sdk/ndk
wget https://dl.google.com/android/repository/${NDK_VERSION_NAME}-linux.zip
#echo "f47ec4c4badd11e9f593a8450180884a927c330d ${NDK_VERSION_NAME}-linux.zip" | sha1sum -c
unzip "${NDK_VERSION_NAME}-linux.zip" -d /opt/android/sdk/ndk/
mv /opt/android/sdk/ndk/${NDK_VERSION_NAME} /opt/android/sdk/ndk/${NDK_VERSION_NUM}
touch /opt/android/sdk/ndk/${NDK_VERSION_NUM}/package.xml
rm -f ${NDK_VERSION_NAME}-linux.zip
export ANDROID_NDK=/opt/android/sdk/ndk/${NDK_VERSION_NUM}
export ANDROID_NDK_ROOT=/opt/android/sdk/ndk/${NDK_VERSION_NUM}
export ANDROID_NDK_HOME=/opt/android/sdk/ndk/${NDK_VERSION_NUM}
# Install Android SDK
export ANDROID_HOME=/opt/android/sdk
## Check update at https://developer.android.com/studio#command-tools
mkdir -p ${ANDROID_HOME} && \
    wget --quiet --output-document=/tmp/sdk https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    echo "$ANDROID_COMMAND_LINE_TOOLS_HASH /tmp/sdk" | sha256sum -c && \
    unzip -q /tmp/sdk -d ${ANDROID_HOME} && \
    rm /tmp/sdk
## Set environmental variables
export ANDROID_SDK_ROOT=${ANDROID_HOME}
export PATH="${PATH}:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/cmdline-tools/latest:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools:${ANDROID_SDK_ROOT}/cmdline-tools/bin:${ANDROID_SDK_ROOT}/platform-tools"
## Accept Android SDK liscences
mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses
## Installing basic Android tools
sdkmanager --sdk_root=$ANDROID_SDK_ROOT --install \
  "build-tools;33.0.1" \
  "platform-tools" \
  "platforms;android-33"
sdkmanager --sdk_root=$ANDROID_SDK_ROOT --install "cmdline-tools;latest"
#f Flutter setup
apt update && apt install -y clang cmake ninja-build libgtk-3-dev
export FLUTTER_ROOT=/opt/flutter
export FLUTTER_VERSION=flutter_linux_3.29.2-stable
git config --global --add safe.directory /opt/flutter/flutter
mkdir -p ${FLUTTER_ROOT} && \
    cd ${FLUTTER_ROOT} && \
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_VERSION}.tar.xz && \
    tar xf ${FLUTTER_VERSION}.tar.xz && \
    rm ${FLUTTER_VERSION}.tar.xz && \
    export PATH="$PATH:`pwd`/flutter/bin" && \
    flutter channel stable && \
    flutter upgrade && \
    flutter doctor --android-licenses && \
    flutter doctor -v
#Install golang
curl -Lso go.tar.gz https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
echo "f6c8a87aa03b92c4b0bf3d558e28ea03006eb29db78917daec5cfb6ec1046265 go.tar.gz" | sha256sum -c -
tar xzf go.tar.gz --strip-components=1 -C /usr/local
rm go.tar.gz