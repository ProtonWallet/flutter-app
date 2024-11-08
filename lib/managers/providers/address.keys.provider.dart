import 'dart:async';
import 'dart:convert';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';

extension ProtonAddressKeyJson on ProtonAddressKey {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'publicKey': publicKey,
      'privateKey': privateKey,
      'token': token,
      'signature': signature,
      'primary': primary,
      'active': active,
      'flags': flags,
    };
  }

  static ProtonAddressKey fromJson(Map<String, dynamic> json) {
    return ProtonAddressKey(
      id: json['id'],
      version: json['version'],
      publicKey: json['publicKey'],
      privateKey: json['privateKey'],
      token: json['token'],
      signature: json['signature'],
      primary: json['primary'],
      active: json['active'],
      flags: json['flags'],
    );
  }
}

extension ProtonAddressJson on ProtonAddress {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domainId': domainId,
      'email': email,
      'status': status,
      'type': type,
      'receive': receive,
      'send': send,
      'displayName': displayName,
      'keys': keys?.map((key) => key.toJson()).toList(),
    };
  }

  static ProtonAddress fromJson(Map<String, dynamic> json) {
    return ProtonAddress(
      id: json['id'],
      domainId: json['domainId'],
      email: json['email'],
      status: json['status'],
      type: json['type'],
      receive: json['receive'],
      send: json['send'],
      displayName: json['displayName'],
      keys: (json['keys'] as List<dynamic>?)
          // ignore: unnecessary_lambdas
          ?.map((keyJson) => ProtonAddressKeyJson.fromJson(keyJson))
          .toList(),
    );
  }
}

extension ProtonAddressListJson on List<ProtonAddress> {
  String toJsonString() {
    final List<Map<String, dynamic>> jsonObj =
        map((pAddress) => pAddress.toJson()).toList();
    return jsonEncode(jsonObj);
  }

  static List<ProtonAddress> fromJsonString(jsonString) {
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return decodedJsonList
        .map((jsonItem) =>
            ProtonAddressJson.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }
}

class AddressKeyProvider extends DataProvider {
  final SecureStorageManager storage;
  final String key = "proton_wallet_address_provider_key";
  final dataUpdateController = StreamController<DataUpdated>.broadcast();

  final ProtonEmailAddressClient protonEmailAddressClient;
  final UserManager userManager;

  AddressKeyProvider(
    this.userManager,
    this.protonEmailAddressClient,
    this.storage,
  );

  List<ProtonAddress> addresses = [];

  Future<List<ProtonAddress>> _getFromSecureStorage() async {
    List<ProtonAddress> addresses_ = [];
    final jsonString = await storage.get(key);
    if (jsonString.isNotEmpty) {
      addresses_ = ProtonAddressListJson.fromJsonString(jsonString);
    }
    return addresses_;
  }

  Future<void> _saveAddresses() async {
    await storage.set(key, addresses.toJsonString());
  }

  Future<List<AddressKey>> getAddressKeys() async {
    final List<AddressKey> addressKeysOut = [];
    final addresses = await getAddresses();
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

  Future<List<ProtonAddress>> getAddresses() async {
    if (addresses.isEmpty) {
      /// try to get addresses from secure storage first
      addresses = await _getFromSecureStorage();

      /// fetch from server if no local secure stoage cache, then save in secure storage
      if (addresses.isEmpty) {
        await _fetchFromServer();
        await _saveAddresses();
      }
    }
    return addresses;
  }

  @override
  Future<void> clear() async {
    addresses.clear();
    dataUpdateController.close();
  }

  @override
  Future<void> reload() async {
    addresses.clear();
    await _fetchFromServer();
    dataUpdateController.add(DataUpdated(DateTime.now()));
  }
}
