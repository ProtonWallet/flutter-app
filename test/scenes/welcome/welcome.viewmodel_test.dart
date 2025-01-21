import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';

import '../../helper.dart';
import '../../mocks/manager.factory.mocks.dart';
import '../../mocks/native.view.channel.mocks.dart';
import '../../mocks/proton.api.service.manager.mocks.dart';
import '../../mocks/user.manager.mocks.dart';
import '../../mocks/welcome.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WelcomeViewmodelImpl', () {
    testUnit('loadData test', () async {
      final mockWelcomeCoordinator = MockWelcomeCoordinator();
      final mockManagerFactory = MockManagerFactory();
      final mockUserManager = MockUserManager();
      final mockNativeChannel = MockNativeViewChannel();

      final mockUserInfo = MockUserInfo();
      final userID = "test_id";
      when(mockUserInfo.userId).thenReturn(userID);
      when(mockUserManager.login(userID)).thenAnswer((_) async {});

      final viewModel = WelcomeViewModelImpl(
        mockWelcomeCoordinator,
        mockNativeChannel,
        mockUserManager,
        mockManagerFactory,
      );

      final mockApiServiceManager = MockProtonApiServiceManager();
      provideDummy<ProtonApiServiceManager>(mockApiServiceManager);

      /// Stub the stream
      final streamController = StreamController<NativeLoginState>.broadcast();
      final completer = Completer<void>();
      when(mockNativeChannel.stream).thenAnswer((_) => streamController.stream);
      when(mockUserManager.nativeLogin(mockUserInfo)).thenAnswer((_) async {});
      when(mockManagerFactory.login(userID)).thenAnswer((_) async {});
      when(mockManagerFactory.get<ProtonApiServiceManager>())
          .thenReturn(mockApiServiceManager);
      when(mockApiServiceManager.initalOldApiService())
          .thenAnswer((_) async {});

      when(mockWelcomeCoordinator.showHome(appConfig.apiEnv))
          .thenAnswer((_) {});
      when(mockWelcomeCoordinator.showNativeSignin()).thenAnswer((_) {});
      when(mockWelcomeCoordinator.showNativeSignup()).thenAnswer((_) {});
      when(mockWelcomeCoordinator.showFlutterSignin(appConfig.apiEnv))
          .thenAnswer((_) {});

      await viewModel.loadData();

      streamController.stream.listen((event) {
        if (event is NativeLoginSuccess) {
          Future.delayed(const Duration(milliseconds: 300), completer.complete);
        }
      });
      streamController.add(NativeLoginSuccess(mockUserInfo));
      await completer.future;
      // Assertions
      expect(viewModel.env, equals(appConfig.apiEnv));
      expect(viewModel.isLoginToHomepage, isFalse);

      // Verify interactions
      verify(mockNativeChannel.stream).called(1);
      verify(mockUserManager.nativeLogin(mockUserInfo)).called(1);
      verify(mockManagerFactory.login(userID)).called(1);
      verify(mockWelcomeCoordinator.showHome(appConfig.apiEnv)).called(1);

      ///
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await viewModel.move(NavID.nativeSignin);
      verify(mockWelcomeCoordinator.showNativeSignin()).called(1);
      await viewModel.move(NavID.nativeSignup);
      verify(mockWelcomeCoordinator.showNativeSignup()).called(1);

      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await viewModel.move(NavID.nativeSignin);
      verify(mockManagerFactory.get<ProtonApiServiceManager>()).called(1);
      verify(mockApiServiceManager.initalOldApiService()).called(1);
      verify(mockWelcomeCoordinator.showFlutterSignin(appConfig.apiEnv))
          .called(1);

      viewModel.dispose();
      streamController.close();
    });
  });
}
