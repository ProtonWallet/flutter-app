import 'dart:async';

import 'package:unleash_proxy_client_flutter/unleash_proxy_client_flutter.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';

class UnleashDataProvider extends DataProvider {
  late UnleashClient unleashClient;
  final ApiEnv apiEnv;
  final String userAgent;
  final String appVersion;
  final String uid;
  final String accessToken;

  UnleashDataProvider(
    this.apiEnv,
    this.appVersion,
    this.userAgent,
    this.uid,
    this.accessToken,
  ) {
    // live example: 'https://wallet.proton.me/api/feature/v2/frontend'
    var hostApiPath = apiEnv.apiPath;
    var appName = 'ProtonWallet';
    var duration = const Duration(minutes: 10).inSeconds;
    unleashClient = UnleashClient(
        url: Uri.parse('$hostApiPath/feature/v2/frontend'),
        clientKey: '-',
        appName: appName,
        refreshInterval: duration,
        disableRefresh: true,
        customHeaders: {
          "User-Agent": userAgent,
          "X-Pm-Appversion": appVersion,
          "X-Pm-Uid": uid,
          "Authorization": accessToken,
        });

    unleashClient.start();
    unleashClient.on('ready', (value) {
      if (unleashClient.isEnabled('WalletFirstFlag')) {
        logger.i('WalletFirstFlag is enabled');
      } else {
        logger.i('WalletFirstFlag is disabled');
      }
    });

    unleashClient.on('error', (error) {
      logger.i('UnleashClient Error: $error');
    });

    unleashClient.on('initialized', (value) {
      logger.i('UnleashClient initialized: $value');
    });

    unleashClient.on('update', (value) {
      logger.i('UnleashClient update: $value');
    });

    unleashClient.on('impression', (value) {
      logger.i('UnleashClient impression: $value');
    });
  }

  Future<void> getTest() async {
    if (unleashClient.isEnabled('WalletFirstFlag')) {
      logger.i('proxy.demo is enabled');
    } else {
      logger.i('proxy.demo is disabled');
    }
  }

  @override
  Future<void> clear() async {
    unleashClient.stop();
  }
}
