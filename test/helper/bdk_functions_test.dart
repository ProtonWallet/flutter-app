import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/api/bdk_wallet/storage.dart';
import 'package:wallet/rust/api/bdk_wallet/wallet.dart';
import 'package:wallet/rust/common/address_info.dart';
import 'package:wallet/rust/common/network.dart';
import 'package:wallet/rust/common/script_type.dart';
import 'package:wallet/rust/common/word_count.dart';
import 'package:wallet/rust/frb_generated.dart';

// final BdkLibrary lib = BdkLibrary(coinType: appConfig.coinType);

FrbAccount prepareWallet(
  String strMnemonic,
  String strDerivationPath,
) {
  var wallet = FrbWallet(
    bip39Mnemonic: strMnemonic,
    network: Network.testnet,
  );
  var storageFactory = OnchainStoreFactory(folderPath: "./");
  var account = wallet.addAccount(
    scriptType: ScriptType.nativeSegwit,
    derivationPath: strDerivationPath,
    storageFactory: storageFactory,
  );
  return account;
}

Future<void> main() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return;
  }
  FrbMnemonic? mnemonic12;
  FrbMnemonic? mnemonic18;
  FrbMnemonic? mnemonic24;

  FrbAccount? wallet1;
  FrbAccount? wallet2;
  FrbAddressInfo addressinfo;
  setUpAll(() async {
    await RustLib.init();
    wallet1 = prepareWallet(
        "ability hair dune bubble science thumb aware cruel cube decide enlist evidence",
        "m/84'/1'/0'/0");

    wallet2 = prepareWallet(
        "debris tool angle nation wage stand jealous lamp reflect lecture luggage ecology",
        "m/84'/1'/168'/0");

    mnemonic12 = FrbMnemonic(wordCount: WordCount.words12);
    mnemonic18 = FrbMnemonic(wordCount: WordCount.words18);
    mnemonic24 = FrbMnemonic(wordCount: WordCount.words24);
  });

  group('Bdk functions', () {
    test('getAddress case 1', () async {
      addressinfo = await wallet1!.getAddress(index: 0);
      expect(addressinfo.address,
          equals("tb1q3vp8n7tqmtttl4qjaaq0wzvjahgwwjxsecg447"));

      addressinfo = await wallet1!.getAddress(index: 1);
      expect(addressinfo.address,
          equals("tb1qx6xqmj2fz7chmm9nmg4mfw4nraaktq40lj2esj"));

      addressinfo = await wallet1!.getAddress(index: 2);
      expect(addressinfo.address,
          equals("tb1q8ck8exngh0cedpl6t6lsp5u3azfq49t356jw3a"));
    });

    test('getAddress case 2', () async {
      addressinfo = await wallet2!.getAddress(index: 11);
      expect(addressinfo.address,
          equals("tb1qtqg9xy8c9zxmz7l3p9chz6pa8vwa9satudq4cg"));

      addressinfo = await wallet2!.getAddress(index: 12);
      expect(addressinfo.address,
          equals("tb1qjwavecdtylmk5grdd3aln4jczkjfj0hffep8wu"));

      addressinfo = await wallet2!.getAddress(index: 13);
      expect(addressinfo.address,
          equals("tb1qxxt62rks07r9302gfmf5h80mmjt28mhg0qee20"));
    });

    test('getBalance case 1', () async {
      expect((await wallet1!.getBalance()).total().toSat(), equals(0));
      expect((await wallet2!.getBalance()).total().toSat(), equals(0));
    });

    test('createMnemonic case 1', () {
      List<String> words12 = mnemonic12!.asString().split(" ");
      List<String> words18 = mnemonic18!.asString().split(" ");
      List<String> words24 = mnemonic24!.asString().split(" ");
      expect(words12.length, equals(12));
      expect(words18.length, equals(18));
      expect(words24.length, equals(24));
      for (String word in words12 + words18 + words24) {
        expect(word.length, greaterThanOrEqualTo(3));
        expect(word.length, lessThanOrEqualTo(8));
      }
    });
  });
}
