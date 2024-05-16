# wallet

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup development env

Follow the docker image scripts.

[Linux](docker/android/install-deps.sh)

[macOS](docker/macos/install-deps.sh)

[Windows](docker/win/install-deps.sh)

### Trouble-shooting

#### Windows

- If you faced issue when cargo build in windows:
    `
    error: failed to run custom build command for `openssl-sys x.x.x`
    `
  - Install Strawberry Perl
  - Rerun cargo build
    Reference from: [this thread](https://github.com/sfackler/rust-openssl/issues/1086#issuecomment-846160769)

- cargo build stuck when building openssl
    Run `cargo build -vv` to check if it really stuck. It may take more than 5+ minutes in windows build.

## Dependancies

lefthook: [installation](https://github.com/evilmartians/lefthook/blob/master/docs/install.md)
run once after install: `lefthook install`, this is the pre commit commands linked with lint and format

## Localizations

## Submodules

[Muon v1](vendor/muon) this is the networking lib. referance this way more for debugging and faster development.

[proton-crypto-rs](vendor/proton-crypto-rs) common rust-go-crypto wrapper and ported some account/inbox functions.

[Andromeda](vendor/andromeda) proton wallet rust common lib.

[Esplora-Client](vendor/esplora-client) esplora client integrate with protn api

## Cargo index

We need to add the private registry to either the environment variables or the Cargo configuration. It is recommended to set this in your shell environment.

```sh
export CARGO_REGISTRIES_PROTON_INTERNAL_INDEX= "sparse+https://protonvpn.gitlab-pages.protontech.ch/rust/registry/index/"
```

or: ~/.cargo/config.toml

```json
[registries]
proton_internal = { index = "sparse+https://protonvpn.gitlab-pages.protontech.ch/rust/registry/index/" }
```

## Assets generation

- make make build-runner
  if you see conflits errors. select `Delete` then everything should be good.

## How to switch env

[Flutter env config file](lib/constants/app.config.dart)

For ios: you can change flutter side. it will sync to ios native automitically

For android: you need to change flutter side and also the android native:

- we use atlas: `pascal` for test.  `wallet-api` for production

Both production and development environments require a developer VPN. Additionally, the production environment needs login accounts to be whitelisted.

## Commands

```CMake
gen                            gen flutter rust bridge code for ios/andorid/desktop
build                          Build android rust bridge for prove pass the build
build-rust                     Run the library tests
fmt                            Format the project
lint                           Lint the project
test                           Run the library tests
extract                        Extract the flutter strings
submodule-update               Update the submodule commits
submodule-init                 Initialize the submodules
gen-app-icons                  Generate the app icons
build-runner                   Build the runner - auto gen
upgrade_frb                    upgrade flutter rust bridge version
rust-clean                     Clean the rust build
release-ios                    Build the ios release
release-android                Build the android release
pod                            Run pod install
build-gopenpgp-ios             Auto build the pgp library for ios
build-gopenpgp-android         Auto build the pgp library for android
help                           Display this help screen
```

## Known issues and workaround

### iOS: mobile_scanner

this dependcy doesnt work on ios simulator. the workaround is to disable this plugin in file [pubspec.yaml](pubspec.yaml#L88) then disable the imports in [file import line](lib/components/protonmail.autocomplete.dart#L4) and code block [code block 173-187](lib/components/protonmail.autocomplete.dart#L173-L187)

Optional: Try pod install or flutter clean if you see strange errors
