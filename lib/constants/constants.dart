import 'package:flutter/material.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;
const double defaultButtonPadding = 26.0;
const int eventLoopRefreshThreshold = 30;
const int defaultBitcoinAddressCountForOneEmail = 10;
const int defaultTransactionPerPage = 5;
const int defaultDisplayDigits = 2;
const int freeUserWalletAccountLimit = 2;
const int maxMemoTextCharSize = 256;
const int maxWalletNameSize = 32;
const int maxAccountNameSize = 32;
const int reSyncTime = 600; // trigger sync at least after 600 seconds
const int btc2satoshi = 100000000;
const int bdkDatabaseVersion = 4;
const int driftDatabaseVersion = 4;
const int sqliteDatabaseVersion = 1;
const int defaultTwoFactorAmountThreshold = 1000;
const int maxRecipientCount = 5;

/// used for desktop
const double maxDeskTopSheetWidth = 600.0;
const double drawerMaxWidth = 400;

const String defaultWalletAccountName = "Default Wallet Account";
const String defaultWalletName = "My Wallet";
const String hidedBalanceString = "****";

const BitcoinUnit defaultBitcoinUnit = BitcoinUnit.btc;
const FiatCurrency defaultFiatCurrency = FiatCurrency.usd;

/// gpg context
const String gpgContextWalletBitcoinAddress = "wallet.bitcoin-address";
const String gpgContextWalletKey = "wallet.key";

const List<BitcoinUnit> bitcoinUnits = [
  BitcoinUnit.btc,
  BitcoinUnit.mbtc,
  BitcoinUnit.sats,
];

const List<int> stopgapOptions = [
  10,
  20,
  30,
  40,
  50,
  60,
  70,
  80,
  90,
  100,
  150,
  200
];

const anonymousAddress = ProtonAddress(
  id: "Anonymous sender",
  email: "Anonymous sender",
  status: 1,
  type: 1,
  receive: 1,
  send: 1,
  displayName: "Anonymous sender",
);

const defaultProtonAddress = ProtonAddress(
  id: 'default',
  domainId: '',
  email: 'default',
  status: 1,
  type: 1,
  receive: 1,
  send: 1,
  displayName: '',
);

/// bigint cannot be const
final defaultExchangeRate = ProtonExchangeRate(
  id: 'default',
  bitcoinUnit: BitcoinUnit.btc,
  fiatCurrency: defaultFiatCurrency,
  exchangeRateTime: '',
  exchangeRate: BigInt.one,
  cents: BigInt.one,
);
