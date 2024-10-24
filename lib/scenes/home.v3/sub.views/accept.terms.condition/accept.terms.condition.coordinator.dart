import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/accept.terms.condition/accept.terms.condition.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/accept.terms.condition/accept.terms.condition.viewmodel.dart';

class AcceptTermsConditionCoordinator extends Coordinator {
  late ViewBase widget;
  final String email;

  AcceptTermsConditionCoordinator(this.email);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = AcceptTermsConditionViewModelImpl(
      this,
      dataProviderManager.userSettingsDataProvider,
      email,
    );
    widget = AcceptTermsConditionView(
      viewModel,
    );
    return widget;
  }
}
