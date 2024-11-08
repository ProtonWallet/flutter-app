// import 'dart:typed_data';

// import 'package:cryptography/cryptography.dart';
// @Deprecated("This need to remove after migrate Rust features")
// import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
// import 'package:wallet/constants/constants.dart';
// import 'package:wallet/helper/walletkey_helper.dart';
// import 'package:wallet/managers/users/user.key.dart';
// import 'package:wallet/rust/proton_api/wallet.dart';

// class ProtonWallet {
//   static Future<MigratedWallet> migrateWalletData(
//     UserKey primaryUserKey,
//     SecretKey oldWalletKey,
//     SecretKey newWalleKey,
//     // base 64 encoded wallet name and encrypted
//     String walletName,
//     String base64Mnemonic,
//     String fingerprint,
//   ) async {
//     final String userPrivateKey = primaryUserKey.privateKey;
//     final String userKeyID = primaryUserKey.keyID;
//     final String passphrase = primaryUserKey.passphrase;

//     final clearWalletName = await WalletKeyHelper.decrypt(
//       oldWalletKey,
//       walletName,
//     );

//     final clearMnemonic = await WalletKeyHelper.decrypt(
//       oldWalletKey,
//       base64Mnemonic,
//     );

//     /// new wallet key entropy
//     final newEntropy = Uint8List.fromList(
//       await newWalleKey.extractBytes(),
//     );

//     assert(oldWalletKey != newWalleKey);
//     assert(await oldWalletKey.extractBytes() != newEntropy);

//     /// encrypt wallet name with wallet key
//     final String encryptedWalletName = await WalletKeyHelper.encrypt(
//       newWalleKey,
//       clearWalletName,
//     );

//     /// encrypt mnemonic with wallet key
//     final String encryptedMnemonic = await WalletKeyHelper.encrypt(
//       newWalleKey,
//       clearMnemonic,
//     );

//     /// encrypt wallet key with user private key
//     final String encryptedWalletKey = proton_crypto.encryptBinaryArmor(
//       userPrivateKey,
//       newEntropy,
//     );

//     /// sign wallet key with user private key
//     final String walletKeySignature =
//         proton_crypto.getBinarySignatureWithContext(
//       userPrivateKey,
//       passphrase,
//       newEntropy,
//       gpgContextWalletKey,
//     );

//     ///migrate wallet data
//     final migratedWallet = MigratedWallet(
//       name: encryptedWalletName,
//       userKeyId: userKeyID,
//       walletKey: encryptedWalletKey,
//       walletKeySignature: walletKeySignature,
//       mnemonic: encryptedMnemonic,
//       // shouldnt be null
//       fingerprint: fingerprint,
//     );

//     return migratedWallet;
//   }
// }
