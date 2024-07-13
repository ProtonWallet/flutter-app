import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/scenes/home/navigation.view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';

class HomeNavigationCoordinator extends Coordinator {
  late ViewBase widget;
  ApiEnv apiEnv;

  List<ViewBase<ViewModel>> pageViews = [];
  HomeNavigationCoordinator(this.apiEnv);

  @override
  void end() {
    pageViews.clear();
  }

  @override
  ViewBase<ViewModel> start() {
    final nativeViewChannel = serviceManager.get<PlatformChannelManager>();
    pageViews.add(HomeCoordinator(apiEnv, nativeViewChannel).start());
    final viewModel = HomeNavigationViewModelImpl(
      this,
      apiEnv,
    );
    widget = HomeNavigationView(
      viewModel,
    );
    return widget;
  }

  @override
  List<ViewBase<ViewModel>> starts() {
    return pageViews;

    // HistoryCoordinator().start(),
    // BuyBitcoinCoordinator().start(),
    // TransferCoordinator().start(),
    // SettingsCoordinator().start()
  }
}
