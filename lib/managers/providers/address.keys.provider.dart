import 'dart:async';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';

class AddressKeyProvider extends DataProvider {
  final dataUpdateController = StreamController<DataUpdated>.broadcast();

  ///
  final ProtonEmailAddressClient protonEmailAddressClient;
  final UserManager userManager;

  AddressKeyProvider(
    this.userManager,
    this.protonEmailAddressClient,
  );

  List<ProtonAddress> addresses = [];

  Future<List<AddressKey>> getAddressKeys() async {
    final List<AddressKey> addressKeysOut = [];
    final addresses = await _getAddressKeys();
    final userKeys = await userManager.getUserKeys();
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
            addressKeysOut.add(AddressKey(
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
    return addressKeysOut;
  }

  Future<void> _fetchFromServer() async {
    addresses.clear();
    addresses = await protonEmailAddressClient.getProtonAddress();
    addresses = addresses.where((element) => element.status == 1).toList();
  }

  Future<List<ProtonAddress>> _getAddressKeys() async {
    if (addresses.isEmpty) {
      await _fetchFromServer();
    }
    return addresses;
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }

  @override
  Future<void> reload() async {
    addresses = [];
    await _fetchFromServer();
    dataUpdateController.add(DataUpdated(DateTime.now()));
  }
}
