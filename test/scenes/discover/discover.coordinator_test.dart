import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/scenes/discover/discover.coordinator.dart';
import 'package:wallet/scenes/discover/discover.view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

import '../../helper.dart';
import '../../mocks/clients/discovery.content.client.mocks.dart';
import '../../mocks/manager.factory.mocks.dart';
import '../../mocks/proton.api.service.manager.mocks.dart';

void main() {
  testUnit('start() creates DiscoverView with the correct ViewModel', () {
    final coordinator = DiscoverCoordinator();

    final mockApiServiceManager = MockProtonApiServiceManager();
    final mockManagerFactory = MockManagerFactory();
    final mockDiscoveryContentClient = MockDiscoveryContentClient();
    provideDummy<ProtonApiServiceManager>(mockApiServiceManager);
    when(mockApiServiceManager.getDiscoveryContentClient())
        .thenReturn(mockDiscoveryContentClient);
    // Override the singleton instance with the mock
    ManagerFactory.mockInstance = mockManagerFactory;
    // Stub the service manager to return the mocked API service manager
    when(mockManagerFactory.get<ProtonApiServiceManager>())
        .thenReturn(mockApiServiceManager);
    // Call the start method
    final view = coordinator.start();

    // Verify the widget is created as expected
    expect(view, isA<DiscoverView>());
    final discoverView = view as DiscoverView;

    // Verify the ViewModel is of the correct type
    expect(discoverView.viewModel, isA<DiscoverViewModelImpl>());

    // Verify the ViewModel was initialized with the correct arguments
    final viewModel = discoverView.viewModel as DiscoverViewModelImpl;
    expect(viewModel.discoveryContentClient, mockDiscoveryContentClient);
    expect(viewModel.coordinator, coordinator);

    // Optionally verify service manager interactions
    verify(mockManagerFactory.get<ProtonApiServiceManager>()).called(1);
    verify(mockApiServiceManager.getDiscoveryContentClient()).called(1);

    coordinator.end();
  });
}
