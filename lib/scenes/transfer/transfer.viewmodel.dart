import 'dart:async';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/api/proton_api.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class TransferViewModel extends ViewModel {
  TransferViewModel(super.coordinator);

  int testCode = 0;
  int testCodeTwo = 0;
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
    await initApiService(userName: 'pro', password: 'pro');
    var authInfo = await fetchAuthInfo(userName: 'feng100');
    logger.i("authInfo: ${authInfo.code}, ${authInfo.srpSession}");
    testCode = authInfo.code;

    var walletResponse = await getWallets();
    logger.i(
        "walletResponse: ${walletResponse.code}, ${walletResponse.wallets.length}");
    testCodeTwo = walletResponse.code;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
