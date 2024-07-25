import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/send/send.view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';

class SendCoordinator extends Coordinator {
  late ViewBase widget;
  final NativeViewChannel nativeViewChannel;
  final String walletID;
  final String accountID;

  SendCoordinator(this.nativeViewChannel, this.walletID, this.accountID);

  void showNativeReportBugs() {
    final userManager = serviceManager.get<UserManager>();
    final userName = userManager.userInfo.userName;
    final userEmail = userManager.userInfo.userMail;
    nativeViewChannel.nativeReportBugs(userName, userEmail);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final eventLoop = serviceManager.get<EventLoop>();
    final walletManager = serviceManager.get<ProtonWalletManager>();
    final dataProvider = serviceManager.get<DataProviderManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();

    final viewModel = SendViewModelImpl(
      this,
      walletID,
      accountID,
      eventLoop,
      walletManager,
      userManager,
      dataProvider.contactsDataProvider,
      dataProvider.walletKeysProvider,
      dataProvider.protonEmailAddressProvider,
      dataProvider.exclusiveInviteDataProvider,
      dataProvider.userSettingsDataProvider,
      dataProvider.localTransactionDataProvider,
      dataProvider.walletDataProvider,
      apiServiceManager.getApiService().getInviteClient(),
    );
    widget = SendView(
      viewModel,
    );
    return widget;
  }
}
