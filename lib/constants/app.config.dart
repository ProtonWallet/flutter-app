import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/script_type.dart';

class AppConfig {
  // use for derivation creation, e.g. m/$ScriptType/$CoinType/$accountIndex
  CoinType coinType;
  // use for derivation creation, e.g. m/$ScriptType/$CoinType/$accountIndex
  ScriptTypeInfo scriptTypeInfo;
  ApiEnv apiEnv;
  String esploraBaseUrl;
  // TODO:: use this flag to enable / disable test output
  bool testMode;

  ///
  AppConfig({
    required this.coinType,
    required this.scriptTypeInfo,
    required this.apiEnv,
    required this.esploraBaseUrl,
    required this.testMode,
  });
}

final appConfigForTestNet = AppConfig(
    coinType: bitcoinTestnet,
    scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
    apiEnv: ApiEnv.atlas(null),
    esploraBaseUrl: "https://proton.me/wallet/explorer/testnet/",
    // esploraBaseUrl: "https://blockstream.info/testnet/",
    testMode: true);

final appConfigForProduction = AppConfig(
    coinType: bitcoin,
    scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
    apiEnv: const ApiEnv.prod(),
    esploraBaseUrl: "https://proton.me/wallet/explorer/",
    // esploraBaseUrl: "https://blockstream.info/",
    testMode: false);

final appConfig = appConfigForProduction;
