import 'package:flutter/material.dart';
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
