import 'dart:async';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/proton_api/proton_api_service.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class TransferViewModel extends ViewModel {
  TransferViewModel(super.coordinator);

  int testCode = 0;
}

class TransferViewModelImpl extends TransferViewModel {
  TransferViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<TransferViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    var api = await ProtonApiServiceHelper.create();
    var authInfo = await api.getAuthInfo("feng100");
    logger.i("authInfo: ${authInfo.code}, ${authInfo.srpSession}");
    testCode = authInfo.code;

    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
