import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class HomeNavigationViewModel extends ViewModel {
  HomeNavigationViewModel(super.coordinator);

  int selectedPage = 0;
  void updateSelected(int index);

  late PageController pageController =
      PageController(initialPage: selectedPage);
}

class HomeNavigationViewModelImpl extends HomeNavigationViewModel {
  HomeNavigationViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<HomeNavigationViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    pageController.dispose();
  }

  @override
  Future<void> loadData() async {
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    pageController.jumpToPage(index);
    datasourceChangedStreamController.sink.add(this);
  }
}
