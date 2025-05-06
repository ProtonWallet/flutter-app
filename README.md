# ProtonWallet for mobile
Copyright (c) 2025 Proton Financial AG

## Download
<p align="center">
    <img src="metadata/en/store-listing-1.jpg" height="300" alt="A safer way to hold your Bitcoin">
    <img src="metadata/en/store-listing-2.jpg" height="300" alt="Effortlessly send and receive Bitcoin">
    <img src="metadata/en/store-listing-3.jpg" height="300" alt="Protect your privacy">
    <img src="metadata/en/store-listing-4.jpg" height="300" alt="Achieve financial 
freedom">
</p>

<p align="center">
    <a href="https://play.google.com/store/apps/details?id=me.proton.wallet.android" target="_blank">
        <img src="https://pmecdn.protonweb.com/image-transformation/?s=c&image=image%2Fupload%2Fstatic%2Fstore-badges%2Fgoogle-play-store_en.svg" alt="Get it on Google Play" height="60">
    </a>
    <a href="https://apps.apple.com/app/apple-store/id6479609548" target="_blank">
        <img src="https://pmecdn.protonweb.com/image-transformation/?s=c&image=image%2Fupload%2Fstatic%2Fstore-badges%2Fapple-app-store_en.svg" alt="Download on the App Store" height="60">
    </a>
</p>

<p align="center">You can also download the app (APK) directly <a href="https://proton.me/download/WalletAndroid/ProtonWallet-Android.apk" target="_blank">here</a>.</p>
<p align="center">You can use the following SHA256 fingerprint of the signing certificate to verify the downloaded APK:
A4:6A:8B:E5:F5:AB:B5:CA:31:4B:A0:16:A6:65:8A:D0:8D:25:23:E8:09:41:9C:C6:09:94:85:F9:1B:9D:D4:A8</p>

## Submodules
ProtonWallet mobile build required following submodule:
- <a href="https://github.com/ProtonWallet/andromeda" target="_blank">andromeda</a>

## Build instructions
- <a href="build_instructions/android/README.md" >Android</a>
- iOS (WIP)

## Signing
All `release` builds done on CI are automatically signed with ProtonWallet's keystore, and depending on the distribution method, they are categorized as follows:
- Google Play Store (App Bundle)
- Official APK available via our download link

## Versioning
Version matches format: `[major][minor][patch]`

## Observability
Crashes and errors that happen in `release` (non debuggable) builds are reported to Sentry in an anonymized form.

## Help us to translate the project
You can learn more about it on [our blog post](https://proton.me/blog/translation-community).

## License
The code and data files in this distribution are licensed under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See <https://www.gnu.org/licenses/> for a copy of this license.

See [LICENSE](LICENSE) file
