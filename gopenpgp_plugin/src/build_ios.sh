#!/bin/sh
BASEDIR=$(dirname "$0")
BASEDIR=$(cd "$BASEDIR" ; pwd -P) #current script folder

export GOOS=ios
export CGO_ENABLED=1
# export CGO_CFLAGS="-fembed-bitcode"
# export MIN_VERSION=15

BUILD_DIR=${BASEDIR}/../build

SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path)

if [ "$GOARCH" = "amd64" ]; then
    CARCH="x86_64"
elif [ "$GOARCH" = "arm64" ]; then
    CARCH="arm64"
fi

if [ "$SDK" = "iphoneos" ]; then
  export TARGET="$CARCH-apple-ios$MIN_VERSION"
elif [ "$SDK" = "iphonesimulator" ]; then
  export TARGET="$CARCH-apple-ios$MIN_VERSION-simulator"
fi

CLANG=$(xcrun --sdk "$SDK" --find clang)
CC="$CLANG -target $TARGET -isysroot $SDK_PATH $@"
export CC

mkdir -p ${BUILD_DIR}
go build -C ${BASEDIR} -trimpath -buildmode=c-archive -o ${BUILD_DIR}/${LIB_NAME}_${GOARCH}_${SDK}.a