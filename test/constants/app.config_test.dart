import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/script_type.dart';

import '../helper.dart';

void main() {
  testUnit('AppConfig instance creation', () {
    final appConfig = AppConfig(
      coinType: bitcoin,
      scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
      apiEnv: const ApiEnv.prod(),
      esploraWebpageUrl: esploraMainnet,
      esploraApiUrl: esploraMainnetApi,
      testMode: false,
      stopGap: 50,
    );

    expect(appConfig.coinType, bitcoin);
    expect(appConfig.scriptTypeInfo, ScriptTypeInfo.nativeSegWit);
    expect(appConfig.apiEnv, const ApiEnv.prod());
    expect(appConfig.esploraWebpageUrl, esploraMainnet);
    expect(appConfig.esploraApiUrl, esploraMainnetApi);
    expect(appConfig.testMode, false);
    expect(appConfig.stopGap, 50);
  });

  testUnit('Predefined configuration for production', () {
    expect(appConfigForProduction.coinType, bitcoin);
    expect(appConfigForProduction.scriptTypeInfo, ScriptTypeInfo.nativeSegWit);
    expect(appConfigForProduction.apiEnv, const ApiEnv.prod());
    expect(appConfigForProduction.esploraWebpageUrl, esploraMainnet);
    expect(appConfigForProduction.esploraApiUrl, esploraMainnetApi);
    expect(appConfigForProduction.testMode, false);
    expect(appConfigForProduction.stopGap, 50);
  });

  testUnit('Predefined configuration for test net', () {
    expect(appConfigForTestNet.coinType, bitcoinTestnet);
    expect(appConfigForTestNet.scriptTypeInfo, ScriptTypeInfo.nativeSegWit);
    expect(appConfigForTestNet.apiEnv, ApiEnv.atlas(null));
    expect(appConfigForTestNet.esploraWebpageUrl, esploraTestnet);
    expect(appConfigForTestNet.esploraApiUrl, esploraTestnetApi);
    expect(appConfigForTestNet.testMode, true);
    expect(appConfigForTestNet.stopGap, 50);

    expect(appConfigForRegtest.coinType, bitcoinRegtest);
    expect(appConfigForRegtest.scriptTypeInfo, ScriptTypeInfo.nativeSegWit);
    expect(appConfigForRegtest.apiEnv, ApiEnv.atlas(null));
    expect(appConfigForRegtest.esploraWebpageUrl, esploraTestnet);
    expect(appConfigForRegtest.esploraApiUrl, esploraTestnetApi);
    expect(appConfigForRegtest.testMode, true);
    expect(appConfigForRegtest.stopGap, 50);

    expect(appConfigForPayments.coinType, bitcoinTestnet);
    expect(appConfigForPayments.scriptTypeInfo, ScriptTypeInfo.nativeSegWit);
    expect(appConfigForPayments.apiEnv, payments);
    expect(appConfigForPayments.esploraWebpageUrl, esploraTestnet);
    expect(appConfigForPayments.esploraApiUrl, esploraTestnetApi);
    expect(appConfigForPayments.testMode, true);
    expect(appConfigForPayments.stopGap, 30);
  });

  testUnit('AppConfig copyWith method', () {
    final updatedConfig = appConfigForTestNet.copyWith(
      apiEnv: const ApiEnv.prod(),
    );

    expect(updatedConfig.coinType, bitcoinTestnet); // Unchanged
    expect(updatedConfig.apiEnv, const ApiEnv.prod()); // Updated
    expect(updatedConfig.esploraWebpageUrl, esploraTestnet); // Unchanged
    expect(updatedConfig.testMode, true); // Unchanged
  });

  testUnit('initAppEnv sets appConfig correctly', () {
    const environment = String.fromEnvironment('appEnv', defaultValue: 'prod');
    AppConfig.initAppEnv();

    if (environment == 'payment') {
      expect(appConfig, appConfigForPayments);
    } else if (environment == 'prod') {
      expect(appConfig, appConfigForProduction);
    } else if (environment == 'atlas') {
      expect(appConfig.apiEnv, ApiEnv.atlas(null));
    } else if (environment.isNotEmpty) {
      expect(appConfig.apiEnv, ApiEnv.atlas(environment));
    }
  });
}
