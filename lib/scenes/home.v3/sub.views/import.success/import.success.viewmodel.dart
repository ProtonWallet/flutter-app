import 'dart:async';

import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/import.success/import.success.coordinator.dart';

abstract class ImportSuccessViewModel
    extends ViewModel<ImportSuccessCoordinator> {
  final UserSettingsDataProvider userSettingsDataProvider;

  ImportSuccessViewModel(
    super.coordinator,
    this.userSettingsDataProvider,
  );
}

class ImportSuccessViewModelImpl extends ImportSuccessViewModel {
  ImportSuccessViewModelImpl(
    super.coordinator,
    super.userSettingsDataProvider,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
