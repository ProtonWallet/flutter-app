import 'package:wallet/rust/common/script_type.dart';

class ScriptTypeInfo {
  String name;
  int index;
  String desc;
  int bipVersion;
  ScriptType type;

  ScriptTypeInfo({
    required this.name,
    required this.index,
    required this.desc,
    required this.bipVersion,
    required this.type,
  });

  static final ScriptTypeInfo legacy = ScriptTypeInfo(
      name: "Legacy",
      index: 1,
      desc: "BIP-0044, P2PKH",
      bipVersion: 44,
      type: ScriptType.legacy);
  static final ScriptTypeInfo nestedSegWit = ScriptTypeInfo(
      name: "Legacy Segwit",
      index: 2,
      desc: "BIP-0049, P2SH",
      bipVersion: 49,
      type: ScriptType.nestedSegwit);
  static final ScriptTypeInfo nativeSegWit = ScriptTypeInfo(
      name: "Native Segwit",
      index: 3,
      desc: "BIP-0084, P2WPKH",
      bipVersion: 84,
      type: ScriptType.nativeSegwit);
  static final ScriptTypeInfo taproot = ScriptTypeInfo(
      name: "Taproot",
      index: 4,
      desc: "BIP-0086, P2TR",
      bipVersion: 86,
      type: ScriptType.taproot);

  static List scripts = [legacy, nestedSegWit, nativeSegWit, taproot];
}
