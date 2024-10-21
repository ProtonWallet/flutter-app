// import 'dart:async';
//
// import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
// import 'package:wallet/scenes/core/viewmodel.dart';
// import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.coordinator.dart';
//
// abstract class WalletSettingViewModel extends ViewModel<WalletSettingCoordinator> {
//   final bool isPrimaryAccount;
//
//   WalletSettingViewModel(
//       super.coordinator, {
//         required this.isPrimaryAccount,
//       });
// }
//
// class WalletSettingViewModelImpl extends WalletSettingViewModel {
//   WalletSettingViewModelImpl(
//       super.coordinator, {
//         required super.isPrimaryAccount,
//       });
//
//   @override
//   Future<void> loadData() async {
//     sinkAddSafe();
//   }
//
//   @override
//   Future<void> move(NavID to) async {}
// }
