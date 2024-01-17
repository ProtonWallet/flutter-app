class ScriptType {
  String name;
  int index;
  String desc;

  ScriptType({required this.name, required this.index, required this.desc});

  static final ScriptType legacy =
      ScriptType(name: "Legacy", index: 0, desc: "BIP-0044, P2PKH");
  static final ScriptType nestedSegWit =
      ScriptType(name: "NestedSegWit", index: 1, desc: "BIP-0049, P2SH");
  static final ScriptType nativeSegWit =
      ScriptType(name: "NativeSegWit", index: 2, desc: "BIP-0084, P2WPKH");
  static final ScriptType taproot =
      ScriptType(name: "Taproot", index: 3, desc: "BIP-0086, P2TR");
}
