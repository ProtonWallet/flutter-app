import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';

abstract class HomeNavigationViewModel
    extends ViewModel<HomeNavigationCoordinator> {
  HomeNavigationViewModel(
    super.coordinator,
    this.apiEnv,
  );

  int selectedPage = 0;
  void updateSelected(int index);

  late PageController pageController =
      PageController(initialPage: selectedPage);

  ApiEnv apiEnv;

  List<ViewBase<ViewModel>> pageViewStarts();
}

class HomeNavigationViewModelImpl extends HomeNavigationViewModel {
  HomeNavigationViewModelImpl(super.coordinator, super.apiEnv);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Future<void> loadData() async {}

  @override
  void updateSelected(int index) {
    selectedPage = index;
    pageController.jumpToPage(index);
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  List<ViewBase<ViewModel<Coordinator>>> pageViewStarts() {
    return coordinator.starts();
  }
}
