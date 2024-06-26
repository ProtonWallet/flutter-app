import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/address.dao.impl.dart';
import 'package:wallet/models/address.model.dart';

class ProtonAddressProvider extends DataProvider {
  final AddressDao addressDao;
  final String userID = ""; // need to add userid.

  ProtonAddressProvider(
    this.addressDao,
  );

  Future<AddressModel?> getAddressModel(String serverID) async {
    AddressModel? addressModel = await addressDao.findByServerID(serverID);
    return addressModel;
  }

  @override
  Future<void> clear() async {}
}
