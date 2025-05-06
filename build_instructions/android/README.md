# ProtonWallet for Android
Copyright (c) 2025 Proton Financial AG

## Build instructions
1. Clone the Proton Wallet Flutter app repository from GitHub.
    ```bash
    git clone https://github.com/ProtonWallet/flutter-app.git
    ```
2. Clone the required submodule from GitHub.
    ```bash
    # change dir to flutter-app
    cd flutter-app
    # replace submodule with public repository
    cd vendor && rm -r andromeda && git clone https://github.com/ProtonWallet/andromeda.git
    ```
3. Build the Docker image:
    ```bash
    # change dir to flutter-app
    cd ../
    # build docker image
    docker build --no-cache --platform linux/amd64 -t proton-wallet-image build_instructions/android/
    ```
4. Run the build script using the built Docker image (Docker maximum memory should set to 16 GB or larger):
    ```bash
    # Mount flutter-app to /app in Docker and run the build script
    docker run --rm -it -v $(pwd):/app -w /app proton-wallet-image bash -c "sh build_instructions/android/build.sh"
    ```
5. The build log will be located at `flutter-app/apk.log.txt`, and `flutter-app/apk.err.txt` if any error occurs.