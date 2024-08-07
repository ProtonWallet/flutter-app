import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wallet/helper/extension/datetime.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';

class ConnectivityUpdated extends DataState {
  final int timestemp;
  final List<ConnectivityResult> connectivityResult;
  ConnectivityUpdated(this.timestemp, this.connectivityResult);

  @override
  List<Object?> get props => [connectivityResult];
}

class ConnectivityProvider extends DataProvider {
  ///
  final Connectivity connectivity = Connectivity();
  List<ConnectivityResult> connectivityResult = [ConnectivityResult.none];

  ConnectivityProvider() {
    initConnectivity();
  }

  ///
  Future<void> initConnectivity() async {
    final result = await connectivity.checkConnectivity();
    _updateConnectivityStatus(result);
    connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  Future<void> _updateConnectivityStatus(
    List<ConnectivityResult> result,
  ) async {
    final state = ConnectivityUpdated(
      DateTime.now().secondsSinceEpoch(),
      result,
    );
    emitState(state);
  }

  Future<bool> hasConnectivity() async {
    final result = await connectivity.checkConnectivity();
    return result.hasConnectivity;
  }

  @override
  Future<void> clear() async {}
}

extension ConnectivityResultExtension on List<ConnectivityResult> {
  bool get hasConnectivity =>
      contains(ConnectivityResult.mobile) ||
      contains(ConnectivityResult.wifi) ||
      contains(ConnectivityResult.ethernet);
}
