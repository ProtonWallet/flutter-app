import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unleash_proxy_client_flutter/unleash_proxy_client_flutter.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/unleash_client.dart';

class UnleashDataProvider extends DataProvider {
  /// unleash client
  late UnleashClient unleashClient;

  /// api client
  final FrbUnleashClient frbUnleashClient;

  /// api env
  final ApiEnv apiEnv;

  /// refresh interval
  final duration = const Duration(minutes: 2).inSeconds;

  /// const feature names
  static const String walletFlutterLogInternal = "WalletFlutterLogInternal";
  static const String walletMempoolRecommendedFees =
      "WalletMempoolRecommendedFees";
  static const String walletMobileClientDebugMode =
      "WalletMobileClientDebugMode";
  static const String walletEarlyAccess = "WalletEarlyAccess";

  /// timer for job guardian
  Timer? timer;

  UnleashDataProvider(
    this.apiEnv,
    this.frbUnleashClient,
  ) {
    final hostApiPath = apiEnv.apiPath;
    const appName = 'ProtonWallet';
    unleashClient = UnleashClient(
        url: Uri.parse('$hostApiPath/feature/v2/frontend'),
        clientKey: '-',
        appName: appName,
        refreshInterval: duration,
        disableMetrics: true,
        disableRefresh: true,
        fetcher: (http.Request request) async {
          final response = await frbUnleashClient.fetchToggles();
          return http.Response.bytes(
            response.body.toList(),
            response.statusCode,
          );
        });

    unleashClient.on('ready', (value) {
      if (unleashClient.isEnabled('WalletFirstFlag')) {
        logger.i('WalletFirstFlag is enabled');
      } else {
        logger.i('WalletFirstFlag is disabled');
      }
    });

    unleashClient.on('error', (error) {
      logger.e('UnleashClient Error: $error');
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

  Future<void> start() async {
    await unleashClient.start();
    if (timer == null || timer?.isActive == false) {
      timer = Timer.periodic(Duration(seconds: duration), (timer) {
        start();
      });
    }
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
    final Timer? timer = this.timer;
    if (timer != null && timer.isActive) {
      timer.cancel();
      this.timer = null;
    }
    unleashClient.stop();
  }

  @override
  Future<void> reload() async {}

  bool isTraceLoggerEnabled() {
    if (kDebugMode) {
      return true;
    }
    final enableTrace = unleashClient.isEnabled(walletFlutterLogInternal);
    return enableTrace;
  }

  bool isUsingMempoolFees() {
    return unleashClient.isEnabled(walletMempoolRecommendedFees);
  }

  bool isMobileClientDebugMode() {
    return unleashClient.isEnabled(walletMobileClientDebugMode);
  }

  bool isWalletEarlyAccess() {
    return unleashClient.isEnabled(walletEarlyAccess);
  }
}
