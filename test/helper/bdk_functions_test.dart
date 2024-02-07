import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

final BdkLibrary lib = BdkLibrary();

Future<Wallet> prepareWallet(
    String strMnemonic, String strDerivationPath) async {
  Wallet wallet;
  Mnemonic mnemonic = await Mnemonic.fromString(strMnemonic);
  final DerivationPath derivationPath =
      await DerivationPath.create(path: strDerivationPath);
  final aliceDescriptor =
      await lib.createDerivedDescriptor(mnemonic, derivationPath);
  wallet = await lib.restoreWalletInMemory(aliceDescriptor);
  return wallet;
}

Future<void> main() async {
  if (Platform.isLinux) {
    return;
  }
  Mnemonic? mnemonic12;
  Mnemonic? mnemonic18;
  Mnemonic? mnemonic24;

  Wallet? wallet1;
  Wallet? wallet2;
  AddressInfo addressinfo;
  setUpAll(() async {
    await RustLib.init();
    wallet1 = await prepareWallet(
        "ability hair dune bubble science thumb aware cruel cube decide enlist evidence",
        "m/84'/1'/0'/0");

    wallet2 = await prepareWallet(
        "debris tool angle nation wage stand jealous lamp reflect lecture luggage ecology",
        "m/84'/1'/168'/0");

    mnemonic12 = await Mnemonic.create(WordCount.words12);
    mnemonic18 = await Mnemonic.create(WordCount.words18);
    mnemonic24 = await Mnemonic.create(WordCount.words24);
  });

  group('Bdk functions', () {
    test('getAddress case 1', () async {
      addressinfo = await lib.getAddress(wallet1!, addressIndex: 0);
      expect(addressinfo.address,
          equals("tb1q3vp8n7tqmtttl4qjaaq0wzvjahgwwjxsecg447"));

      addressinfo = await lib.getAddress(wallet1!, addressIndex: 1);
      expect(addressinfo.address,
          equals("tb1qx6xqmj2fz7chmm9nmg4mfw4nraaktq40lj2esj"));

      addressinfo = await lib.getAddress(wallet1!, addressIndex: 2);
      expect(addressinfo.address,
          equals("tb1q8ck8exngh0cedpl6t6lsp5u3azfq49t356jw3a"));
    });

    test('getAddress case 2', () async {
      addressinfo = await lib.getAddress(wallet2!, addressIndex: 11);
      expect(addressinfo.address,
          equals("tb1qtqg9xy8c9zxmz7l3p9chz6pa8vwa9satudq4cg"));

      addressinfo = await lib.getAddress(wallet2!, addressIndex: 12);
      expect(addressinfo.address,
          equals("tb1qjwavecdtylmk5grdd3aln4jczkjfj0hffep8wu"));

      addressinfo = await lib.getAddress(wallet2!, addressIndex: 13);
      expect(addressinfo.address,
          equals("tb1qxxt62rks07r9302gfmf5h80mmjt28mhg0qee20"));
    });

    test('getBalance case 1', () async {
      expect((await lib.getBalance(wallet1!)).total, equals(0));
      expect((await lib.getBalance(wallet2!)).total, equals(0));
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
