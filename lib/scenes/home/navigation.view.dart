import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';

class HomeNavigationView extends ViewBase<HomeNavigationViewModel> {
  const HomeNavigationView(HomeNavigationViewModel viewModel)
      : super(viewModel, const Key("HomeNavigationView"));

  @override
  Widget build(BuildContext context) {
    return buildBottomBar(context);
  }

  Widget buildSidemenu(BuildContext context, HomeNavigationViewModel viewModel,
      ViewSize viewSize) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            // Page controller to manage a PageView
            controller: viewModel.sideMenu,
            // Will shows on top of all items, it can be a logo or a Title text
            title: Assets.images.wallet.image(),
            // Will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
            footer: const Text('demo'),
            // Notify when display mode changed
            onDisplayModeChanged: (mode) {
              logger.d(mode);
            },
            // List of SideMenuItem to show them on SideMenu
            items: viewModel.items,
          ),
          Expanded(
            child: PageView(
              controller: viewModel.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: viewModel.coordinator.starts(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewModel.coordinator.starts(),
      ),
    );
  }
}
