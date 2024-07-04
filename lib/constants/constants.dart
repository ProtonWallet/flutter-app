import 'package:flutter/material.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;
const double defaultButtonPadding = 26.0;
const int eventLoopRefreshThreshold = 10;
const int defaultBitcoinAddressCountForOneEmail = 10;
const int defaultTransactionPerPage = 5;
const int defaultDisplayDigits = 2;
const int freeUserWalletLimit = 2; // TODO:: get from api to avoid abuse
const int freeUserWalletAccountLimit = 5; // TODO:: get from api to avoid abuse
const int maxMemoTextCharSize = 256;
const int maxWalletNameSize = 32;
const int maxAccountNameSize = 32;
const int reSyncTime = 600; // trigger sync after 600 seconds (1 block)

const String latestAddressIndex = "bitcoinAddress.latest";

const BitcoinUnit defaultBitcoinUnit = BitcoinUnit.btc;
const FiatCurrency defaultFiatCurrency = FiatCurrency.usd;
const String gpgContextWalletBitcoinAddress = "wallet.bitcoin-address";
const String gpgContextWalletKey = "wallet.key";

const List<BitcoinUnit> bitcoinUnits = [
  BitcoinUnit.btc,
  BitcoinUnit.mbtc,
  BitcoinUnit.sats,
];

const String srpModulusKey = r"""
-----BEGIN PGP PUBLIC KEY BLOCK-----

xjMEXAHLgxYJKwYBBAHaRw8BAQdAFurWXXwjTemqjD7CXjXVyKf0of7n9Ctm
L8v9enkzggHNEnByb3RvbkBzcnAubW9kdWx1c8J3BBAWCgApBQJcAcuDBgsJ
BwgDAgkQNQWFxOlRjyYEFQgKAgMWAgECGQECGwMCHgEAAPGRAP9sauJsW12U
MnTQUZpsbJb53d0Wv55mZIIiJL2XulpWPQD/V6NglBd96lZKBmInSXX/kXat
Sv+y0io+LR8i2+jV+AbOOARcAcuDEgorBgEEAZdVAQUBAQdAeJHUz1c9+KfE
kSIgcBRE3WuXC4oj5a2/U3oASExGDW4DAQgHwmEEGBYIABMFAlwBy4MJEDUF
hcTpUY8mAhsMAAD/XQD8DxNI6E78meodQI+wLsrKLeHn32iLvUqJbVDhfWSU
WO4BAMcm1u02t4VKw++ttECPt+HUgPUq5pqQWe5Q2cW4TMsE
=Y4Mw
-----END PGP PUBLIC KEY BLOCK-----""";
