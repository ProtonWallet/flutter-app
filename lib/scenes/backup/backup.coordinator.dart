import 'package:wallet/components/page_route.dart';
import 'package:wallet/scenes/backup/backup.view.dart';
import 'package:wallet/scenes/backup/backup.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/passphrase/passphrase.coordinator.dart';

class SetupBackupCoordinator extends Coordinator {
  late ViewBase widget;
  final String strMnemonic;

  SetupBackupCoordinator(this.strMnemonic);

  @override
  void end() {}

  void goPassphrase(String strMnemonic) {
    var view = SetupPassPhraseCoordinator(strMnemonic).start();
    Coordinator.navigatorKey.currentState
        ?.push(CustomPageRoute(page: view, fullscreenDialog: false));
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupBackupViewModelImpl(this, strMnemonic);
    widget = SetupBackupView(
      viewModel,
    );
    return widget;
  }
}
