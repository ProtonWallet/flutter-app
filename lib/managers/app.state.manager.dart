//app.state.data.provider.dart

import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/common/errors.dart';

abstract class AppState extends DataState {}

class AppSessionFailed extends AppState {
  final String message;

  AppSessionFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class AppStateManager extends DataProvider implements Manager {
  /// constructor
  AppStateManager();

  Future<void> handleError(BridgeError exception) async {
    final message = parseSessionExpireError(exception);
    if (message != null) {
      emitState(AppSessionFailed(message: message));
      return;
    }
  }

  Future<void> checkout() async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> dispose() {
    // TODO(fix): implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> login(String userID) {
    // TODO(fix): implement login
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  Future<void> logout() async {}
}
