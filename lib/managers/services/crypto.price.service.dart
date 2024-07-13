import 'package:wallet/helper/crypto.price.helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';

import 'service.dart';

class CryptoPriceDataService extends Service<CryptoPriceInfo> {
  CryptoPriceDataService({required super.duration});

  @override
  Future<CryptoPriceInfo> onUpdate() async {
    // TODO(fix): change static to property
    return CryptoPriceHelper.getPriceInfo("BTCUSDT");
  }
}
