import 'package:wallet/helper/proton_api/exceptions.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/rust/proton_api/errors.dart' as bridge;
import 'package:wallet/rust/proton_api/types.dart';

class ProtonApiServiceHelper {
  final String _apiID;
  ProtonApiServiceHelper._(this._apiID);

  static Future<ProtonApiServiceHelper> create() async {
    try {
      final res = await RustLib.instance.api.protonApiCreateProtonApi();
      return ProtonApiServiceHelper._(res);
    } on bridge.ApiError catch (e) {
      throw handleApiException(e);
    }
  }

  Future<AuthInfo> getAuthInfo(String userName) async {
    try {
      return RustLib.instance.api
          .protonApiFetchAuthInfo(apiId: _apiID, userName: userName);
    } on bridge.ApiError catch (e) {
      throw handleApiException(e);
    }
  }
}
