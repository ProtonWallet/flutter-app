import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'buybitcoin.banxa.webview.dart';
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
    final info = serviceManager.get<UserManager>().userInfo;

    final BuyBitcoinBloc buyBloc = BuyBitcoinBloc(
      serviceManager.get<DataProviderManager>().gatewayDataProvider,
    );

    final viewModel = BuyBitcoinViewModelImpl(
      this,
      buyBloc,
      info.userMail,
      info.userId,
      walletID,
      accountID,
      serviceManager.get<DataProviderManager>().localBitcoinAddressDataProvider,
    );
    widget = BuyBitcoinView(
      viewModel,
    );
    return widget;
  }

  void pushWebview(String url) {
    push(WebViewExample(
      checkoutUrl: url,
    ));
  }
}
