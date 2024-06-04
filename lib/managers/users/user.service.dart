import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';

// wallet account api and percistance operations.
class UserService {
  // temperay cache
  List<ProtonAddress>? userAddresses;

  //db

  //api client
  ProtonEmailAddressClient? protonAddrClient;

  // add db here
  Future<List<ProtonAddress>> getProtonAddress() async {
    // get from local properties
    // userAddresses ??= await proton_api.getProtonAddress();
    // // get from cache
    // userAddresses ??= await proton_api.getProtonAddress();
    // // get from api
    // return userAddresses;
    return [];
  }
}
