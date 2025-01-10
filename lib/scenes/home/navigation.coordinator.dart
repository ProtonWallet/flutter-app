import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/scenes/home/navigation.view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';

/// This is a unused approche to manager views in page view.
/// keep it for future reference when UX changes
class HomeNavigationCoordinator extends Coordinator {
  late ViewBase widget;
  ApiEnv apiEnv;
  @protected
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
  }
}
