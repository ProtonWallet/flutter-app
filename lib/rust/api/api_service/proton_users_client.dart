// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import '../../proton_api/proton_users.dart';
import '../errors.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'proton_api_service.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<ProtonUsersClient>>
abstract class ProtonUsersClient implements RustOpaqueInterface {
  Future<GetAuthInfoResponseBody> getAuthInfo({required String intent});

  Future<GetAuthModulusResponse> getAuthModule();

  Future<ProtonUser> getUserInfo();

  Future<ProtonUserSettings> getUserSettings();

  Future<int> lockSensitiveSettings();

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<ProtonUsersClient> newInstance(
          {required ProtonApiService client}) =>
      RustLib.instance.api
          .crateApiApiServiceProtonUsersClientProtonUsersClientNew(
              client: client);

  Future<String> unlockPasswordChange({required ProtonSrpClientProofs proofs});

  Future<String> unlockSensitiveSettings(
      {required ProtonSrpClientProofs proofs});
}
