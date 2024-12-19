import 'dart:async';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/bitcoin_address_client.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

class PoolAddressDataProvider extends DataProvider {
  /// api clients
  final BitcoinAddressClient bitcoinAddressClient;

  PoolAddressDataProvider(
    this.bitcoinAddressClient,
  );

  /// stream
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<List<ApiWalletBitcoinAddress>> getWalletBitcoinAddresses(
    String walletID,
    String accountID,
    int onlyRequest,
  ) async {
    return bitcoinAddressClient.getWalletBitcoinAddress(
        walletId: walletID,
        walletAccountId: accountID,
        onlyRequest: onlyRequest);
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }

  @override
  Future<void> reload() async {}
}
