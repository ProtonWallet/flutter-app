import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/proton_address.dart';

class ProtonEmailAddressProvider extends DataProvider {
  List<ProtonAddress> addresses = [];

  ProtonEmailAddressProvider();

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<List<ProtonAddress>> getProtonEmailAddresses() async {
    if (addresses.isEmpty) {
      await preLoad();
    }
    final List<ProtonAddress> protonAddresses =
        addresses.where((element) => element.status == 1).toList();
    return protonAddresses;
  }

  Future<void> preLoad() async {
    addresses = await proton_api.getProtonAddress();
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
