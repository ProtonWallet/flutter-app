import 'dart:async';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';

abstract class HomeNavigationViewModel
    extends ViewModel<HomeNavigationCoordinator> {
  HomeNavigationViewModel(super.coordinator, this.apiEnv);

  int selectedPage = 0;
  void updateSelected(int index);

  late PageController pageController =
      PageController(initialPage: selectedPage);
  SideMenuController sideMenu = SideMenuController();

  List<SideMenuItem> items = [];

  ApiEnv apiEnv;
}

class HomeNavigationViewModelImpl extends HomeNavigationViewModel {
  HomeNavigationViewModelImpl(super.coordinator, super.apiEnv);

  final datasourceChangedStreamController =
      StreamController<HomeNavigationViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    pageController.dispose();
  }

  @override
  Future<void> loadData() async {
    items = [
      SideMenuItem(
        title: 'Dashboard',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: const Icon(Icons.home),
        badgeContent: const Text(
          '3',
          style: TextStyle(color: Colors.white),
        ),
      ),
      SideMenuItem(
        title: 'Settings',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: const Icon(Icons.settings),
      ),
      const SideMenuItem(
        title: 'Exit',
        icon: Icon(Icons.exit_to_app),
      ),
    ];
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    pageController.jumpToPage(index);
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void move(NavID to) {}
}
