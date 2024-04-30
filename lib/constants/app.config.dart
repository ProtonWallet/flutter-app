import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/script_type.dart';

class AppConfig {
  CoinType
      coinType; // use for derivation creation, e.g. m/$ScriptType/$CoinType/$accountIndex
  ScriptType
      scriptType; // use for derivation creation, e.g. m/$ScriptType/$CoinType/$accountIndex
  ApiEnv apiEnv;
  String esploraBaseUrl;
  bool testMode; // TODO:: use this flag to enable / disable test output
  AppConfig(
      {required this.coinType,
      required this.scriptType,
      required this.apiEnv,
      required this.esploraBaseUrl,
      required this.testMode});
}

final appConfigForTestNet = AppConfig(
    coinType: bitcoinTestnet,
    scriptType: ScriptType.nativeSegWit,
    apiEnv: pascal,
    esploraBaseUrl: "https://blockstream.info/testnet/",
    testMode: true);

final appConfigForProduction = AppConfig(
    coinType: bitcoin,
    scriptType: ScriptType.nativeSegWit,
    apiEnv: const ApiEnv.prod(),
    esploraBaseUrl: "https://blockstream.info/",
    testMode: false);

final appConfig = appConfigForTestNet;