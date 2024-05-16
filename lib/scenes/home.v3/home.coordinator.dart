import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/backup.v2/backup.coordinator.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:wallet/scenes/deletion/deletion.coordinator.dart';
import 'package:wallet/scenes/discover/discover.coordinator.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/security.setting/security.setting.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth/two.factor.auth.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

class HomeCoordinator extends Coordinator {
  late ViewBase widget;
  final NativeViewChannel nativeViewChannel;
  ApiEnv apiEnv;

  HomeCoordinator(this.apiEnv, this.nativeViewChannel);

  @override
  void end() {}

  void showNativeUpgrade(NativeSession session) {
    nativeViewChannel.switchToUpgrade(session);
  }

  void showSetupOnbaord() {
    var view = SetupOnbaordCoordinator().start();
    push(view, fullscreenDialog: true);
  }

  void showSend(int walletID, int accountID) {
    var view = SendCoordinator(walletID, accountID).start();
    showInBottomSheet(view);
  }

  void showSetupBackup(int walletID) {
    var view = SetupBackupCoordinator(walletID).start();
    push(view, fullscreenDialog: false);
  }

  void showReceive(int walletID, int accountID) {
    var view = ReceiveCoordinator(walletID, accountID).start();
    showInBottomSheet(view);
  }

  void showWebSocket() {
    var view = WebSocketCoordinator().start();
    push(view, fullscreenDialog: true);
  }

  void showDiscover() {
    var view = DiscoverCoordinator().start();
    push(view);
  }

  void showBuy(int walletID, int accountID) {
    var view = BuyBitcoinCoordinator(walletID, accountID).start();
    push(view);
  }

  void showSecuritySetting() {
    var view = SecuritySettingCoordinator().start();
    push(view);
  }

  void showWalletDeletion(int walletID) {
    var view = WalletDeletionCoordinator(walletID).start();
    push(view, fullscreenDialog: true);
  }

  void showHistoryDetails(
      int walletID, int accountID, String txID, FiatCurrency userFiatCurrency) {
    var view =
        HistoryDetailCoordinator(walletID, accountID, txID, userFiatCurrency)
            .start();
    showInBottomSheet(view);
  }

  void showTwoFactorAuthSetup() {
    var view = TwoFactorAuthCoordinator().start();
    push(view);
  }

  void showTwoFactorAuthDisable() {
    var view = TwoFactorAuthDisableCoordinator().start();
    push(view);
  }

  void logout() {
    var view = WelcomeCoordinator(nativeViewChannel: nativeViewChannel).start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = HomeViewModelImpl(
      this,
      apiEnv,
    );
    widget = HomeView(
      viewModel,
    );
    return widget;
  }
}
