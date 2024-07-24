import 'package:flutter/material.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;
const double defaultButtonPadding = 26.0;
const int eventLoopRefreshThreshold = 30;
const int defaultBitcoinAddressCountForOneEmail = 10;
const int defaultTransactionPerPage = 5;
const int defaultDisplayDigits = 2;
// const int freeUserWalletLimit = 2;
const int freeUserWalletAccountLimit = 2;
const int maxMemoTextCharSize = 256;
const int maxWalletNameSize = 32;
const int maxAccountNameSize = 32;
const int reSyncTime = 600; // trigger sync at least after 600 seconds

// desktop
const double maxDeskTopSheetWidth = 600.0;

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
