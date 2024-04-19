import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/passphrase/passphrase.coordinator.dart';
import 'package:wallet/scenes/setup/create.view.dart';
import 'package:wallet/scenes/setup/create.viewmodel.dart';

class SetupCreateCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  void showPassphrase(String strMnemonic) {
    var view = SetupPassPhraseCoordinator(strMnemonic).start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupCreateViewModelImpl(this);
    widget = SetupCreateView(
      viewModel,
    );
    return widget;
  }
}
