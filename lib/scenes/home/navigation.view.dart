import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';

class HomeNavigationView extends ViewBase<HomeNavigationViewModel> {
  HomeNavigationView(HomeNavigationViewModel viewModel)
      : super(viewModel, const Key("HomeNavigationView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      HomeNavigationViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewModel.coordinator.starts(),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.change_history),
              label: 'history',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.account_balance_wallet),
            //   label: 'send',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.account_balance),
            //   label: 'secruty',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'settings',
            ),
          ],
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onBackground,
          backgroundColor: Theme.of(context).colorScheme.background,
          currentIndex: viewModel.selectedPage,
          onTap: (index) {
            viewModel.updateSelected(index);
          }),
    );
  }
}
