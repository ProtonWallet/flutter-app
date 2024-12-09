import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/logger.dart';

class AppConfig {
  /// Used for derivation creation, e.g., `m/$ScriptType/$CoinType/$accountIndex`
  final CoinType coinType;

  /// Script type for derivation creation.
  final ScriptTypeInfo scriptTypeInfo;

  /// API environment configuration.
  final ApiEnv apiEnv;

  /// URL for accessing the Esplora webpage.
  final String esploraWebpageUrl;

  /// URL for accessing the Esplora API.
  final String esploraApiUrl;

  /// Flag for enabling/disabling test output.
  final bool testMode;

  /// Stop gap value for address generation.
  final int stopGap;

  ///
  AppConfig({
    required this.coinType,
    required this.scriptTypeInfo,
    required this.apiEnv,
    required this.esploraWebpageUrl,
    required this.esploraApiUrl,
    required this.testMode,
    required this.stopGap,
  });

  static void initAppEnv() {
    const environment = String.fromEnvironment('appEnv', defaultValue: 'prod');
    logger.i('App environment: $environment');
    if (environment == 'payment') {
      appConfig = appConfigForPayments;
    } else if (environment == 'prod') {
      appConfig = appConfigForProduction;
    } else if (environment == 'atlas') {
      appConfig = appConfigForRegtest.copyWith(
        apiEnv: ApiEnv.atlas(null),
      );
    } else if (environment.isNotEmpty) {
      appConfig = appConfigForRegtest.copyWith(
        apiEnv: ApiEnv.atlas(environment),
      );
    }
  }

  AppConfig copyWith({required ApiEnv apiEnv}) {
    return AppConfig(
      coinType: coinType,
      scriptTypeInfo: scriptTypeInfo,
      apiEnv: apiEnv,
      esploraWebpageUrl: esploraWebpageUrl,
      esploraApiUrl: esploraApiUrl,
      testMode: testMode,
      stopGap: stopGap,
    );
  }
}

var appConfig = appConfigForProduction;

///predefined app config for test net
final appConfigForTestNet = AppConfig(
  coinType: bitcoinTestnet,
  scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
  apiEnv: ApiEnv.atlas(null),
  esploraWebpageUrl: esploraTestnet,
  esploraApiUrl: esploraTestnetApi,
  testMode: true,
  stopGap: 50,
);

///predefined app config for regtest
final appConfigForRegtest = AppConfig(
  coinType: bitcoinRegtest,
  scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
  apiEnv: ApiEnv.atlas(null),
  esploraWebpageUrl: esploraTestnet,
  esploraApiUrl: esploraTestnetApi,
  testMode: true,
  stopGap: 50,
);

// payment test
final appConfigForPayments = AppConfig(
  coinType: bitcoinTestnet,
  scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
  apiEnv: payments,
  esploraWebpageUrl: esploraTestnet,
  esploraApiUrl: esploraTestnetApi,
  testMode: true,
  stopGap: 30,
);

// production and this will be the default
final appConfigForProduction = AppConfig(
  coinType: bitcoin,
  scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
  apiEnv: const ApiEnv.prod(),
  esploraWebpageUrl: esploraMainnet,
  esploraApiUrl: esploraMainnetApi,
  testMode: false,
  stopGap: 50,
);

/// test net
const String esploraTestnet = "https://blockstream.info/testnet/";
const String esploraTestnetApi = "https://blockstream.info/testnet/";

/// main net
const String esploraMainnet = "https://proton.me/wallet/explorer/";
const String esploraMainnetApi = "https://proton.me/wallet/explorer/";
