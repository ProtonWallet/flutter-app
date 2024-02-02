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

## Dependancies

lefthook: [installation](https://github.com/evilmartians/lefthook/blob/master/docs/install.md)
run once after install: `lefthook install`

## Localizations

## Submodules

- rust/vendor/muon

## Cargo index

Add this lines to ~/.cargo/config.toml
[registries]
protonvpn = { index = "sparse+<https://protonvpn.gitlab-pages.protontech.ch/rust/registry/index/>" }

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
