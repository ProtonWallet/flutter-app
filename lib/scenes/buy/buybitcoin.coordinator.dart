import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/scenes/buy/sample.webview.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'buybitcoin.view.dart';
import 'buybitcoin.viewmodel.dart';

class BuyBitcoinCoordinator extends Coordinator {
  late ViewBase widget;

  final String walletID;
  final String accountID;
  BuyBitcoinCoordinator(this.walletID, this.accountID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var info = serviceManager.get<UserManager>().userInfo;

    BuyBitcoinBloc buyBloc = BuyBitcoinBloc(
      serviceManager.get<DataProviderManager>().gatewayDataProvider,
    );
    var viewModel = BuyBitcoinViewModelImpl(
      this,
      info.userMail,
      buyBloc,
      info.userId,
      walletID,
      accountID,
    );
    widget = BuyBitcoinView(
      viewModel,
    );
    return widget;
  }

  void pushWebview() {
    push(const WebViewExample());
  }
}
