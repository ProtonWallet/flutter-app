import 'dart:async';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/accept.terms.condition/accept.terms.condition.coordinator.dart';

abstract class AcceptTermsConditionViewModel extends ViewModel<AcceptTermsConditionCoordinator> {
  final UserSettingsDataProvider userSettingsDataProvider;
  final String email;
  AcceptTermsConditionViewModel(super.coordinator, this.userSettingsDataProvider, this.email);
}

class AcceptTermsConditionViewModelImpl extends AcceptTermsConditionViewModel {
  AcceptTermsConditionViewModelImpl(super.coordinator, super.userSettingsDataProvider, super.email);

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
