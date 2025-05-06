#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8 

# Default path
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Rust
export CARGO_HOME=/usr/local/cargo
export RUSTUP_HOME=/usr/local/rustup
export PATH="${PATH}:/usr/local/cargo/bin"

# Android
export ANDROID_HOME=/opt/android/sdk
export ANDROID_NDK=/opt/android/sdk/ndk/${NDK_VERSION_NUM}
export ANDROID_NDK_ROOT=/opt/android/sdk/ndk/${NDK_VERSION_NUM}
export ANDROID_NDK_HOME=/opt/android/sdk/ndk/${NDK_VERSION_NUM}
export ANDROID_SDK_ROOT=${ANDROID_HOME}
export PATH="${PATH}:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/cmdline-tools/latest:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools:${ANDROID_SDK_ROOT}/cmdline-tools/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Java
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64/"

# Flutter
export PATH="${PATH}:/opt/flutter/flutter/bin"

# Running shell

if [[ -n "$CI" ]]; then
    # this is how GitLab expects your entrypoint to end, if provided
    # will execute scripts from stdin
    exec /bin/bash
else
    exec "$@"
fi
