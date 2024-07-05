#!/bin/sh
BASEDIR=$(dirname "$0")
BASEDIR=$(cd "$BASEDIR" ; pwd -P) #current script folder


export CGO_ENABLED=1

BUILD_DIR=${BASEDIR}/../build

SDK=macosx
SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path)

if [ "$GOARCH" = "amd64" ]; then
    CARCH="x86_64"
    export GOOS=ios
elif [ "$GOARCH" = "arm64" ]; then
    CARCH="arm64"
    export GOOS=darwin
else
    echo "Unsupported architecture: $GOARCH"
    exit 1
fi

export TARGET="$CARCH-apple-macos"

# Unset any iOS specific environment variables to avoid conflicts
unset IPHONEOS_DEPLOYMENT_TARGET

# Set macOS deployment target
export MACOSX_DEPLOYMENT_TARGET=10.15

CLANG=$(xcrun --sdk "$SDK" --find clang)
CC="$CLANG -target $TARGET -isysroot $SDK_PATH"
export CC

mkdir -p ${BUILD_DIR}
go build -C ${BASEDIR} -trimpath -buildmode=c-archive -o ${BUILD_DIR}/${LIB_NAME}_${GOARCH}.a