// import 'package:wallet/scenes/core/coordinator.dart';
// import 'package:wallet/scenes/core/view.dart';
// import 'package:wallet/scenes/core/viewmodel.dart';
// import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.view.dart';
// import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.viewmodel.dart';
//
// class WalletSettingCoordinator extends Coordinator {
//   late ViewBase widget;
//   final bool isPrimaryAccount;
//
//   WalletSettingCoordinator({
//     required this.isPrimaryAccount,
//   });
//
//   @override
//   void end() {}
//
//   @override
//   ViewBase<ViewModel> start() {
//     final viewModel = WalletSettingViewModelImpl(
//       this,
//       isPrimaryAccount: isPrimaryAccount,
//     );
//     widget = WalletSettingView(
//       viewModel,
//     );
//     return widget;
//   }
// }
