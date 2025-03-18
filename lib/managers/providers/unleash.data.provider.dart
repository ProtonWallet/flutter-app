import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unleash_proxy_client_flutter/toggle_config.dart';
import 'package:unleash_proxy_client_flutter/unleash_proxy_client_flutter.dart';
import 'package:unleash_proxy_client_flutter/variant.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/unleash_client.dart';

/// Enum for feature flags
enum UnleashFeature {
  walletFlutterLogInternal,
  walletMempoolRecommendedFees,
  walletMobileClientDebugMode,
  walletEarlyAccess,
  disableBuyMobile,
  importPaperWallet,
}

/// Function to retrieve all default toggles
Map<String, ToggleConfig> getDefaultToggles() {
  return {
    for (var feature in UnleashFeature.values)
      if (feature.defaultValue case final value?) feature.name: value,
  };
}

/// Extension to get feature names
extension UnleashFeatureExt on UnleashFeature {
  String get name {
    switch (this) {
      case UnleashFeature.walletFlutterLogInternal:
        return "WalletFlutterLogInternal";
      case UnleashFeature.walletMempoolRecommendedFees:
        return "WalletMempoolRecommendedFees";
      case UnleashFeature.walletMobileClientDebugMode:
        return "WalletMobileClientDebugMode";
      case UnleashFeature.walletEarlyAccess:
        return "WalletEarlyAccess";
      case UnleashFeature.disableBuyMobile:
        return "DisableBuyMobile";
      case UnleashFeature.importPaperWallet:
        return "ImportPaperWallet";
    }
  }

  /// Returns the default toggle configuration for the feature, if applicable
  ToggleConfig? get defaultValue {
    switch (this) {
      case UnleashFeature.disableBuyMobile:
        return ToggleConfig(
          enabled: true,
          impressionData: false,
          variant: Variant(enabled: false, name: 'disabled'),
        );
      default:
        return null;
    }
  }
}

class UnleashDataProvider extends DataProvider {
  /// Unleash client for feature toggles
  late final UnleashClient unleashClient;

  /// API client for feature flags
  final FrbUnleashClient frbUnleashClient;

  /// API environment configuration
  final ApiEnv apiEnv;

  /// refresh interval
  final duration = const Duration(minutes: 2).inSeconds;

  /// Timer for periodic refresh
  Timer? refreshTimer;

  UnleashDataProvider(this.apiEnv, this.frbUnleashClient) {
    final hostApiPath = apiEnv.apiPath;
    const appName = 'ProtonWallet';
    unleashClient = UnleashClient(
        url: Uri.parse('$hostApiPath/feature/v2/frontend'),
        clientKey: '-',
        appName: appName,
        refreshInterval: duration,
        disableMetrics: true,
        disableRefresh: true,
        bootstrapOverride: false,
        bootstrap: getDefaultToggles(),
        fetcher: (http.Request request) async {
          final response = await frbUnleashClient.fetchToggles();
          return http.Response.bytes(
            response.body.toList(),
            response.statusCode,
          );
        });
    setupUnleashListeners();
  }

  /// Sets up Unleash event listeners
  void setupUnleashListeners() {
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

  /// Starts the Unleash client and sets up auto-refresh
  Future<void> start() async {
    await unleashClient.start();
    startPeriodicRefresh();
  }

  /// Starts periodic refresh if not already running
  void startPeriodicRefresh() {
    if (refreshTimer == null || !refreshTimer!.isActive) {
      refreshTimer = Timer.periodic(
        Duration(seconds: duration),
        (_) => unleashClient.start(),
      );
    }
  }

  /// Stops and cleans up resources
  @override
  Future<void> clear() async {
    refreshTimer?.cancel();
    refreshTimer = null;
    unleashClient.stop();
  }

  @override
  Future<void> reload() async {}

  /// Generic method to check if a feature flag is enabled
  bool isFeatureEnabled(UnleashFeature feature) {
    return unleashClient.isEnabled(feature.name);
  }

  /// Check specific feature flags
  bool isTraceLoggerEnabled() =>
      kDebugMode || isFeatureEnabled(UnleashFeature.walletFlutterLogInternal);

  bool isUsingMempoolFees() =>
      isFeatureEnabled(UnleashFeature.walletMempoolRecommendedFees);

  bool isMobileClientDebugMode() =>
      isFeatureEnabled(UnleashFeature.walletMobileClientDebugMode);

  bool isWalletEarlyAccess() =>
      isFeatureEnabled(UnleashFeature.walletEarlyAccess);

  bool isBuyMobileDisabled() =>
      isFeatureEnabled(UnleashFeature.disableBuyMobile);

  bool isImportPaperWallet() =>
      isFeatureEnabled(UnleashFeature.importPaperWallet);
}
