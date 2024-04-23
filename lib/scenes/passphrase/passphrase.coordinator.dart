import 'package:wallet/scenes/passphrase/passphrase.view.dart';
import 'package:wallet/scenes/passphrase/passphrase.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

class SetupPassPhraseCoordinator extends Coordinator {
  late ViewBase widget;
  final String strMnemonic;

  SetupPassPhraseCoordinator(this.strMnemonic);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupPassPhraseViewModelImpl(this, strMnemonic);
    widget = SetupPassPhraseView(
      viewModel,
    );
    return widget;
  }
}
