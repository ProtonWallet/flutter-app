import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';

import '../../helper.dart';
import '../../mocks/manager.factory.mocks.dart';
import '../../mocks/native.view.channel.mocks.dart';
import '../../mocks/user.manager.mocks.dart';

void main() {
  testUnit('welcome ccoordinator test', () {
    final mockNativeChannel = MockNativeViewChannel();
    when(mockNativeChannel.switchToNativeLogin()).thenAnswer((_) async {});
    when(mockNativeChannel.switchToNativeSignup()).thenAnswer((_) async {});
    final coordinator = WelcomeCoordinator(
      nativeViewChannel: mockNativeChannel,
    );

    final mockUserManager = MockUserManager();
    final mockManagerFactory = MockManagerFactory();
    provideDummy<UserManager>(mockUserManager);
    // Override the singleton instance with the mock
    ManagerFactory.mockInstance = mockManagerFactory;
    when(mockManagerFactory.get<UserManager>()).thenReturn(mockUserManager);

    /// Call the start method
    final view = coordinator.start();

    // Verify the widget is created as expected
    expect(view, isA<WelcomeView>());
    final welcomeView = view as WelcomeView;

    // Verify the ViewModel is of the correct type
    expect(welcomeView.viewModel, isA<WelcomeViewModelImpl>());

    // Verify the ViewModel was initialized with the correct arguments
    final viewModel = welcomeView.viewModel as WelcomeViewModelImpl;
    expect(viewModel.coordinator, coordinator);

    coordinator.showNativeSignin();
    coordinator.showNativeSignup();

    // Optionally verify service manager interactions
    verify(mockManagerFactory.get<UserManager>()).called(1);
    verify(mockNativeChannel.switchToNativeLogin()).called(1);
    verify(mockNativeChannel.switchToNativeSignup()).called(1);
    coordinator.end();
  });
}
