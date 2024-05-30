SHELL:=/bin/bash
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_ROOT := $(dir $(MAKEFILE_PATH))

# Define variables
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux)
    NDK_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
else ifeq ($(UNAME_S), Darwin)
    NDK_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/darwin-x86_64/bin
else ifeq ($(UNAME_S), Windows)
    NDK_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/windows-x86_64/bin
else
    $(error Unsupported platform: $(UNAME_S))
endif

ANDROID_OUT=../android/src/main/jniLibs
LIB_NAME=libproton_crypto
BUILD_DIR := $(PROJECT_ROOT)build
GOARCH_ADM64 := amd64
GOARCH_ARM64 := arm64
SIMULATOR := iphonesimulator
IPHONEOS := iphoneos

.PHONY: default
default: help

##### --- Building commands android --- #####

.PHONY: android-armv7a
android-armv7a: ## Build android armv7a
	@echo "Building android armv7a..."
	@CGO_ENABLED=1 \
		GOOS=android \
		GOARCH=arm \
		GOARM=7 \
		CC=$(NDK_BIN)/armv7a-linux-androideabi30-clang \
		go build -C ./src -buildmode=c-shared -o $(ANDROID_OUT)/armeabi-v7a/${LIB_NAME}.so .
	@echo "Build android-armv7a completed successfully."

.PHONY: android-arm64
android-arm64: ## Build android arm64
	@echo "Building android arm64..."
	@CGO_ENABLED=1 \
		GOOS=android \
		GOARCH=arm64 \
		CC=$(NDK_BIN)/aarch64-linux-android30-clang \
		go build -C src -buildmode=c-shared -o $(ANDROID_OUT)/arm64-v8a/${LIB_NAME}.so .
	@echo "Build android-arm64 completed successfully."

.PHONY: android-x86
android-x86: ## Build android x86
	@echo "Building android x86..."
	@CGO_ENABLED=1 \
		GOOS=android \
		GOARCH=386 \
		CC=$(NDK_BIN)/i686-linux-android30-clang \
		go build -C src -buildmode=c-shared -o $(ANDROID_OUT)/x86/${LIB_NAME}.so .
	@echo "Build android-x86 completed successfully."

.PHONY: android-x86_64
android-x86_64: ## Build android x86_64
	@echo "Building android x86_64..."
	@CGO_ENABLED=1 \
		GOOS=android \
		GOARCH=amd64 \
		CC=$(NDK_BIN)/x86_64-linux-android30-clang \
		go build -C src -buildmode=c-shared -o $(ANDROID_OUT)/x86_64/${LIB_NAME}.so .
	@echo "Build android-x86_64 completed successfully."

.PHONY: android
android: android-armv7a android-arm64 android-x86 android-x86_64 ## Build android release
	@echo "Building android... Done"

##### --- Building commands ios --- #####

.PHONY: ios-x86_64-sim
ios-x86_64-sim: ## Build iOS x86_64 simulator
	@echo "Building iOS x86_64 simulator..."
	@GOARCH=$(GOARCH_ADM64) \
		SDK=$(SIMULATOR) \
		LIB_NAME=$(LIB_NAME) \
		BUILD_DIR=$(BUILD_DIR) \
		src/build_ios.sh || { echo "Build failed"; exit 1; }
	@echo "Build ios-x86_64-sim completed successfully."

.PHONY: ios-arm64-sim
ios-arm64-sim: ## Build iOS arm64 simulator
	@echo "Building iOS arm64 simulator..."
	@GOARCH=$(GOARCH_ARM64) \
		SDK=$(SIMULATOR) \
		LIB_NAME=$(LIB_NAME) \
		src/build_ios.sh || { echo "Build failed"; exit 1; }
	@echo "Build ios-arm64-sim completed successfully."

.PHONY: ios-arm64
ios-arm64: ## Build iOS arm64
	@echo "Building iOS arm64..."
	@GOARCH=arm64 \
		SDK=iphoneos \
		LIB_NAME=${LIB_NAME} \
		src/build_ios.sh || { echo "Build failed"; exit 1; }
	@echo "Build ios-arm64 completed successfully."

.PHONY: ios 
ios: ios-x86_64-sim ios-arm64-sim ios-arm64 ## build ios all arches 
	@echo "Building iOS ${LIB_NAME}.xcframework..."
	@lipo -create \
    	${BUILD_DIR}/${LIB_NAME}_arm64_iphonesimulator.a \
    	${BUILD_DIR}/${LIB_NAME}_amd64_iphonesimulator.a \
    	-output ${BUILD_DIR}/${LIB_NAME}_iphonesimulator.a
		
	@rm ${BUILD_DIR}/${LIB_NAME}_arm64_iphonesimulator.* \
	    ${BUILD_DIR}/${LIB_NAME}_amd64_iphonesimulator.*

	@mkdir -p ${BUILD_DIR}/ios-arm64 ${BUILD_DIR}/ios-simulator

	@mv -f ${BUILD_DIR}/${LIB_NAME}_arm64_iphoneos.a ${BUILD_DIR}/ios-arm64/${LIB_NAME}.a
	@cp -f ${BUILD_DIR}/${LIB_NAME}_arm64_iphoneos.h ${BUILD_DIR}/ios-arm64/${LIB_NAME}.h
	
	@mv -f ${BUILD_DIR}/${LIB_NAME}_iphonesimulator.a ${BUILD_DIR}/ios-simulator/${LIB_NAME}.a
	@mv -f ${BUILD_DIR}/${LIB_NAME}_arm64_iphoneos.h ${BUILD_DIR}/ios-simulator/${LIB_NAME}.h

	@rm -rf ${BUILD_DIR}/${LIB_NAME}.xcframework

	@xcodebuild -create-xcframework \
		-output ${BUILD_DIR}/${LIB_NAME}.xcframework \
		-library ${BUILD_DIR}/ios-arm64/${LIB_NAME}.a \
		-headers ${BUILD_DIR}/ios-arm64/${LIB_NAME}.h \
		-library ${BUILD_DIR}/ios-simulator/${LIB_NAME}.a \
		-headers ${BUILD_DIR}/ios-simulator/${LIB_NAME}.h > /dev/null
		
	@rm -rf ${BUILD_DIR}/ios-arm64 
	@rm -rf ${BUILD_DIR}/ios-simulator
	@rm -rf ios/${LIB_NAME}.xcframework
	@mv -f ${BUILD_DIR}/${LIB_NAME}.xcframework ios/
	@echo "Building iOS ${LIB_NAME}.xcframework... Done"

##### --- Building commands desktops --- #####

.PHONY: macos
macos: ## Build macos release
	@echo "Building macos arm64..."
	@CGO_ENABLED=1 \
		GOOS=ios \
		GOARCH=arm64 \
		SDK=macos \
		go build -C ./src -trimpath -buildmode=c-archive -o ${BUILD_DIR}/${LIB_NAME}_arm64.a .

	@echo "Building macos amd64..."
	@CGO_ENABLED=1 \
		GOOS=darwin \
		GOARCH=amd64 \
		SDK=macos \
		go build -C ./src -trimpath -buildmode=c-archive -o ${BUILD_DIR}/${LIB_NAME}_amd64.a .

	@mv -f ${BUILD_DIR}/${LIB_NAME}_arm64.h ${BUILD_DIR}/${LIB_NAME}.h
	@rm ${BUILD_DIR}/${LIB_NAME}_amd64.h
	@rm -rf ${BUILD_DIR}/${LIB_NAME}.a

	@echo "Building macos universal..."
	@lipo -create \
		${BUILD_DIR}/${LIB_NAME}_arm64.a \
		${BUILD_DIR}/${LIB_NAME}_amd64.a \
		-output ${BUILD_DIR}/${LIB_NAME}.a

	@rm ${BUILD_DIR}/${LIB_NAME}_amd64.a
	@rm ${BUILD_DIR}/${LIB_NAME}_arm64.a
	@rm -rf ${BUILD_DIR}/${LIB_NAME}.xcframework

	@xcodebuild -create-xcframework \
		-output ${BUILD_DIR}/${LIB_NAME}.xcframework \
		-library ${BUILD_DIR}/${LIB_NAME}.a \
		-headers ${BUILD_DIR}/${LIB_NAME}.h > /dev/null

# @echo "Install macos lib name"
# @install_name_tool -id "@rpath/libproton_crypto.dylib" ${BUILD_DIR}/${LIB_NAME}.dylib
	@rm -rf macos/${LIB_NAME}.xcframework
	@mv -f ${BUILD_DIR}/${LIB_NAME}.xcframework ./macos/${LIB_NAME}.xcframework
	@rm ${BUILD_DIR}/${LIB_NAME}.a
	@rm ${BUILD_DIR}/${LIB_NAME}.h
	@echo "Building macos ${BUILD_DIR}/${LIB_NAME}.xcframework ... Done"
	
.PHONY: windows
windows: ## Build windows release
	@echo "Building windows..."
	@CGO_ENABLED=1 \
		GOOS=windows \
		GOARCH=amd64 \
		go build -trimpath -buildmode=c-shared -o ${LIB_NAME}.dll .
	@mv ${LIB_NAME}.dll ../windows/${LIB_NAME}.dll
	@rm ${LIB_NAME}_*.h
# windows:
# 	go build -o ../windows/shared/${LIB_NAME}.dll -buildmode=c-shared proton_crypto.go

.PHONY: linux
linux: ## Build linux release
	@echo "Building linux..."
	@CGO_ENABLED=1 \
		GOOS=linux \
		GOARCH=amd64 \
		go build -trimpath -buildmode=c-shared -o ${LIB_NAME}.so .
	@mv ${LIB_NAME}.so ../linux/${LIB_NAME}.so
	@rm ${LIB_NAME}_*.h
# linux:
# 	go build -o ../linux/shared/${LIB_NAME}.so -buildmode=c-shared proton_crypto.go

.PHONY: help
help: ## Display this help screen
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
