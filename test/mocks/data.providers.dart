import 'package:mockito/annotations.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/blockinfo.data.provider.dart';
import 'package:wallet/managers/providers/connectivity.provider.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/exchange.data.provider.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/gateway.data.provider.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/pool.address.data.provider.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/managers/providers/proton.address.provider.dart';
import 'package:wallet/managers/providers/receive.address.data.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.mnemonic.provider.dart';
import 'package:wallet/managers/providers/wallet.name.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';

@GenerateMocks([
  PriceGraphDataProvider,
  ExchangeDataProvider,
  AddressKeyProvider,
  BDKTransactionDataProvider,
  BlockInfoDataProvider,
  ConnectivityProvider,
  ContactsDataProvider,
  ExclusiveInviteDataProvider,
  GatewayDataProvider,
  LocalBitcoinAddressDataProvider,
  PoolAddressDataProvider,
  ProtonAddressProvider,
  ReceiveAddressDataProvider,
  ServerTransactionDataProvider,
  UnleashDataProvider,
  UserDataProvider,
  UserSettingsDataProvider,
  WalletsDataProvider,
  WalletKeysProvider,
  WalletMnemonicProvider,
  WalletNameProvider,
  WalletPassphraseProvider,
])
void main() {}
