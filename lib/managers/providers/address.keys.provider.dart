import 'dart:async';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';

class AddressKeyProvider extends DataProvider {
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();
  final ProtonEmailAddressClient protonEmailAddressClient;
  final String userID = ""; // need to add userid.

  AddressKeyProvider(
    this.protonEmailAddressClient,
  );

  List<AddressKey> addressKeys = [];

  Future<void> _fetchFromServer() async {
    addressKeys.clear();
    List<ProtonAddress> addresses =
        await protonEmailAddressClient.getProtonAddress();
    addresses = addresses.where((element) => element.status == 1).toList();

    // TODO(improve): dont use static managers
    final userKeys = await WalletManager.userManager.getUserKeys();
    for (ProtonAddress address in addresses) {
      for (ProtonAddressKey addressKey in address.keys ?? []) {
        final String addressKeyPrivateKey = addressKey.privateKey ?? "";
        final String addressKeyToken = addressKey.token ?? "";
        for (final uKey in userKeys) {
          try {
            final String addressKeyPassphrase = proton_crypto.decrypt(
              uKey.privateKey,
              uKey.passphrase,
              addressKeyToken,
            );
            addressKeys.add(AddressKey(
              id: address.id,
              privateKey: addressKeyPrivateKey,
              passphrase: addressKeyPassphrase,
            ));
            break;
          } catch (e) {
            logger.e(e.toString());
          }
        }
      }
    }
  }

  Future<List<AddressKey>> getAddressKeys() async {
    if (addressKeys.isEmpty) {
      await _fetchFromServer();
    }
    return addressKeys;
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }

  @override
  Future<void> reload() async {
    addressKeys = [];
    await _fetchFromServer();
    dataUpdateController.add(DataUpdated(DateTime.now()));
  }
}
