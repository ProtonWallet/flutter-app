# Makefile
NDK_PATH := /home/will/Android/Sdk/ndk/
all: build_windows build_android

build_windows:
	CC=x86_64-w64-mingw32-gcc CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o ../lib/dynamic_libs/proton_crypto.dll -buildmode=c-shared proton_crypto.go
	#CC=x86_64-w64-mingw32-gcc CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o ../rust/lib/proton_crypto.lib -buildmode=c-archive proton_crypto.go
	#CC=x86_64-w64-mingw32-gcc CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o ../rust/lib/proton_crypto.dll -buildmode=c-shared proton_crypto.go

build_android:
	CC="${NDK_PATH}23.1.7779620/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang" CGO_ENABLED=1 GOOS=android GOARCH=arm64 go build -o ../android/app/libs/proton_crypto.so -buildmode=c-shared proton_crypto.go
	# rm -f ../android/app/libs/proton_crypto.h

build_ios:
	go build -o ../lib/dynamic_libs/proton_crypto.so -buildmode=c-shared proton_crypto.go

# build_macos:

build_linux:
	go build -o ../lib/dynamic_libs/proton_crypto.so -buildmode=c-shared proton_crypto.go
	#go build -o ../rust/lib/libproton_crypto.a -buildmode=c-archive proton_crypto.go
clean:
	rm -f ../lib/dynamic_libs/proton_crypto.dll ../lib/dynamic_libs/proton_crypto.so ../lib/dynamic_libs/proton_crypto.h ../android/app/libs/proton_crypto.so ../android/app/libs/proton_crypto.h

.PHONY: all build_windows build_android build_linux clean