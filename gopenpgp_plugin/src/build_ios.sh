#!/bin/sh
export GOOS=ios
export CGO_ENABLED=1
# export CGO_CFLAGS="-fembed-bitcode"
# export MIN_VERSION=15

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

go build -trimpath -buildmode=c-archive -o ${LIB_NAME}_${GOARCH}_${SDK}.a