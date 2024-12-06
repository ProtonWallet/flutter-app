import 'dart:async';
import 'package:wallet/rust/api/api_service/discovery_content_client.dart';
import 'package:wallet/scenes/components/discover/proton.feeditem.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/discover/discover.coordinator.dart';

abstract class DiscoverViewModel extends ViewModel<DiscoverCoordinator> {
  DiscoverViewModel(super.coordinator);

  bool initialized = false;
  late List<ProtonFeedItem> protonFeedItems = [];
}

class DiscoverViewModelImpl extends DiscoverViewModel {
  final DiscoveryContentClient discoveryContentClient;

  DiscoverViewModelImpl(this.discoveryContentClient, super.coordinator);

  @override
  Future<void> loadData() async {
    final contents = await discoveryContentClient.getDiscoveryContents();
    protonFeedItems = await ProtonFeedItem.loadsFromContents(contents);
    initialized = true;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
