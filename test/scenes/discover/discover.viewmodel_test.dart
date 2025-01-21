import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/rust/proton_api/discovery_content.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

import '../../helper.dart';
import '../../mocks/clients/discovery.content.client.mocks.dart';
import '../../mocks/discovery.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DiscoverViewModelImpl', () {
    testUnit('loadData test', () async {
      final mockDiscoveryContentClient = MockDiscoveryContentClient();
      final mockDiscoverCoordinator = MockDiscoverCoordinator();

      final viewModel = DiscoverViewModelImpl(
        mockDiscoveryContentClient,
        mockDiscoverCoordinator,
      );

      // Mock the data returned by the discoveryContentClient
      final mockContents = [
        Content(
          title: "Bitcoin guide for newcomers",
          link: "https://proton.me/wallet/bitcoin-guide-for-newcomers",
          description:
              "We review some important history and features of Bitcoin for newcomers.",
          pubDate: 1721701601,
          author: "Proton Team",
          category: "Bitcoin basics",
        ),
        Content(
          title: "Bitcoin guide for newcomers 2",
          link: "https://proton.me/wallet/bitcoin-guide-for-newcomers",
          description: "We review some important history and feature",
          pubDate: 1721701601,
          author: "Proton Team",
          category: "Bitcoin basics",
        )
      ];

      when(mockDiscoveryContentClient.getDiscoveryContents()).thenAnswer(
        (_) async => mockContents,
      );

      await viewModel.loadData();

      // Assertions
      expect(viewModel.protonFeedItems.length, 2);
      expect(viewModel.initialized, isTrue);

      // Verify interactions
      verify(mockDiscoveryContentClient.getDiscoveryContents()).called(1);
      await viewModel.move(NavID.root);
    });
  });
}
