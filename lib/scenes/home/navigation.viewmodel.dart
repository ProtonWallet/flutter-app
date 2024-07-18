import 'dart:async';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/env.dart';
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
  SideMenuController sideMenu = SideMenuController();

  List<SideMenuItem> items = [];

  ApiEnv apiEnv;
}

class HomeNavigationViewModelImpl extends HomeNavigationViewModel {
  HomeNavigationViewModelImpl(super.coordinator, super.apiEnv);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
  void updateSelected(int index) {
    selectedPage = index;
    pageController.jumpToPage(index);
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
