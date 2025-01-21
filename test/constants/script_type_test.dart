import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/rust/common/script_type.dart';

import '../helper.dart';

void main() {
  testUnit('Verify ScriptTypeInfo instances', () {
    // Check legacy
    expect(ScriptTypeInfo.legacy.name, "Legacy");
    expect(ScriptTypeInfo.legacy.index, 1);
    expect(ScriptTypeInfo.legacy.desc, "BIP-0044, P2PKH");
    expect(ScriptTypeInfo.legacy.bipVersion, 44);
    expect(ScriptTypeInfo.legacy.type, ScriptType.legacy);

    // Check nestedSegWit
    expect(ScriptTypeInfo.nestedSegWit.name, "Legacy Segwit");
    expect(ScriptTypeInfo.nestedSegWit.index, 2);
    expect(ScriptTypeInfo.nestedSegWit.desc, "BIP-0049, P2SH");
    expect(ScriptTypeInfo.nestedSegWit.bipVersion, 49);
    expect(ScriptTypeInfo.nestedSegWit.type, ScriptType.nestedSegwit);

    // Check nativeSegWit
    expect(ScriptTypeInfo.nativeSegWit.name, "Native Segwit");
    expect(ScriptTypeInfo.nativeSegWit.index, 3);
    expect(ScriptTypeInfo.nativeSegWit.desc, "BIP-0084, P2WPKH");
    expect(ScriptTypeInfo.nativeSegWit.bipVersion, 84);
    expect(ScriptTypeInfo.nativeSegWit.type, ScriptType.nativeSegwit);

    // Check taproot
    expect(ScriptTypeInfo.taproot.name, "Taproot");
    expect(ScriptTypeInfo.taproot.index, 4);
    expect(ScriptTypeInfo.taproot.desc, "BIP-0086, P2TR");
    expect(ScriptTypeInfo.taproot.bipVersion, 86);
    expect(ScriptTypeInfo.taproot.type, ScriptType.taproot);
  });

  testUnit('Verify scripts list contains all ScriptTypeInfo instances', () {
    final scripts = ScriptTypeInfo.scripts;

    expect(scripts.length, 4);
    expect(scripts, contains(ScriptTypeInfo.legacy));
    expect(scripts, contains(ScriptTypeInfo.nestedSegWit));
    expect(scripts, contains(ScriptTypeInfo.nativeSegWit));
    expect(scripts, contains(ScriptTypeInfo.taproot));
  });

  testUnit('lookupByType returns correct ScriptTypeInfo', () {
    expect(
      ScriptTypeInfo.lookupByType(ScriptType.legacy),
      ScriptTypeInfo.legacy,
    );
    expect(
      ScriptTypeInfo.lookupByType(ScriptType.nestedSegwit),
      ScriptTypeInfo.nestedSegWit,
    );
    expect(
      ScriptTypeInfo.lookupByType(ScriptType.nativeSegwit),
      ScriptTypeInfo.nativeSegWit,
    );
    expect(
      ScriptTypeInfo.lookupByType(ScriptType.taproot),
      ScriptTypeInfo.taproot,
    );
  });
}
