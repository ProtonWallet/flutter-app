import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/script_type.dart';

class AppConfig {
  // use for derivation creation, e.g. m/$ScriptType/$CoinType/$accountIndex
  CoinType coinType;
  // use for derivation creation, e.g. m/$ScriptType/$CoinType/$accountIndex
  ScriptTypeInfo scriptTypeInfo;
  ApiEnv apiEnv;
  String esploraWebpageUrl;
  String esploraApiUrl;
  // TODO:: use this flag to enable / disable test output
  bool testMode;

  ///
  AppConfig({
    required this.coinType,
    required this.scriptTypeInfo,
    required this.apiEnv,
    required this.esploraWebpageUrl,
    required this.esploraApiUrl,
    required this.testMode,
  });
}

final appConfigForTestNet = AppConfig(
    coinType: bitcoinTestnet,
    scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
    apiEnv: ApiEnv.atlas(null),
    esploraWebpageUrl: "https://proton.me/wallet/explorer/testnet/",
    /// use https://blockstream.info as api service since our own esplora service is not public yet
    /// TODO:: change to our own esplora client once it's public
    esploraApiUrl: "https://blockstream.info/testnet/",
    testMode: true);

final appConfigForProduction = AppConfig(
    coinType: bitcoin,
    scriptTypeInfo: ScriptTypeInfo.nativeSegWit,
    apiEnv: const ApiEnv.prod(),
    esploraWebpageUrl: "https://proton.me/wallet/explorer/",
    /// use https://blockstream.info as api service since our own esplora service is not public yet
    /// TODO:: change to our own esplora client once it's public
    esploraApiUrl: "https://blockstream.info/",
    testMode: false);

final appConfig = appConfigForProduction;
