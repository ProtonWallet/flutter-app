// import 'dart:async';
//
// import 'package:wallet/managers/providers/data.provider.manager.dart';
// import 'package:wallet/models/drift/db/app.database.dart';
//
// class TwoFaUpdated extends DataUpdated<bool> {
//   TwoFaUpdated({required bool updatedData}) : super(updatedData);
// }
//
// class ProtonUserDataProvider extends DataProvider {
//   ProtonUserDataProvider();
//
//   StreamController<DataUpdated> dataUpdateController =
//       StreamController<DataUpdated>();
//
//   void enabled2FA(enable) {
//     emitState(TwoFaUpdated(updatedData: enable));
//   }
//
//   void enabledRecovery(enable) {
//     dataUpdateController.add(DataUpdated("user update enabledRecovery"));
//   }
//
//   Future<ProtonUser> getUser() async {
//     throw UnimplementedError('getUserData is not implemented');
//   }
//
//   @override
//   Future<void> clear() async {
//     dataUpdateController.close();
//   }
// }
