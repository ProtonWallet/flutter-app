import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';

class HomeNavigationView extends ViewBase<HomeNavigationViewModel> {
  HomeNavigationView(HomeNavigationViewModel viewModel)
      : super(viewModel, const Key("HomeNavigationView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      HomeNavigationViewModel viewModel, ViewSize viewSize) {
    return buildBottomBar(context, viewModel, viewSize);
  }

  Widget buildSidemenu(BuildContext context, HomeNavigationViewModel viewModel,
      ViewSize viewSize) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            // Page controller to manage a PageView
            controller: viewModel.sideMenu,
            // Will shows on top of all items, it can be a logo or a Title text
            title: Image.asset('assets/images/wallet.png'),
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

  Widget buildBottomBar(BuildContext context, HomeNavigationViewModel viewModel,
      ViewSize viewSize) {
    return Scaffold(
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewModel.coordinator.starts(),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/icon/ic-wallet.svg',
                width: 24,
                height: 24,
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/icon/ic-wallet.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6D4AFF),
                  BlendMode.srcIn,
                ),
              ),
              label: S.of(context).tab_home,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/icon/ic-list-bullets.svg',
                width: 24,
                height: 24,
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/icon/ic-list-bullets.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6D4AFF),
                  BlendMode.srcIn,
                ),
              ),
              label: S.of(context).tab_history,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/icon/ic-money-bills.svg',
                width: 24,
                height: 24,
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/icon/ic-money-bills.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6D4AFF),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Buy Bitcoin',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/icon/ic-arrow-right-arrow-left.svg',
                width: 24,
                height: 24,
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/icon/ic-arrow-right-arrow-left.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6D4AFF),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Transfer',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: S.of(context).tab_settings,
            ),
          ],
          selectedItemColor: const Color(0xFF6D4AFF),
          unselectedItemColor: const Color(0xFF0C0C14),
          backgroundColor: Theme.of(context).colorScheme.background,
          currentIndex: viewModel.selectedPage,
          onTap: (index) {
            viewModel.updateSelected(index);
          }),
    );
  }
}
