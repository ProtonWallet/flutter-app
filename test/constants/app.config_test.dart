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

  testUnit('AppConfig.initAppEnv for "payment" environment', () {
    AppConfig.initAppEnv(customEnv: 'payment');
    expect(appConfig, equals(appConfigForPayments));
  });

  testUnit('AppConfig.initAppEnv for "prod" environment', () {
    AppConfig.initAppEnv(customEnv: 'prod');
    expect(appConfig, equals(appConfigForProduction));
  });

  testUnit('AppConfig.initAppEnv for "atlas" environment', () {
    AppConfig.initAppEnv(customEnv: 'atlas');
    expect(appConfig.apiEnv, equals(ApiEnv.atlas(null)));
  });

  testUnit('AppConfig.initAppEnv for custom value', () {
    const customEnv = 'custom';
    AppConfig.initAppEnv(customEnv: customEnv);
    expect(appConfig.apiEnv, equals(ApiEnv.atlas(customEnv)));
  });

  testUnit('should default to "prod" environment', () {
    AppConfig.initAppEnv(); // No environment parameter
    expect(appConfig, equals(appConfigForProduction));
  });
}
