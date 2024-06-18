import 'dart:async';

import 'package:wallet/constants/address.key.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

class AddressKeyProvider implements DataProvider {
  @override
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

    var key = await WalletManager.userManager.getFirstKey();
    String userPrivateKey = key.privateKey;
    String userPassphrase = key.passphrase;

    for (ProtonAddress address in addresses) {
      for (ProtonAddressKey addressKey in address.keys ?? []) {
        String addressKeyPrivateKey = addressKey.privateKey ?? "";
        String addressKeyToken = addressKey.token ?? "";
        try {
          String addressKeyPassphrase = proton_crypto.decrypt(
              userPrivateKey, userPassphrase, addressKeyToken);
          addressKeys.add(AddressKey(
              id: address.id,
              privateKey: addressKeyPrivateKey,
              passphrase: addressKeyPassphrase));
        } catch (e) {
          logger.e(e.toString());
        }
      }
    }

    // TODO:: remove this, use old version decrypt method to get addresskeys' passphrase
    addressKeys.add(AddressKey(
        id: "firstUserKey",
        privateKey: userPrivateKey,
        passphrase: userPassphrase));
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
}
