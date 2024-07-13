import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/models/wallet.passphrase.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/wallet.dart';
import 'package:wallet/rust/common/network.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';

// Define the events
abstract class CreateWalletEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Define the state
class CreateWalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

extension CreatingWalletState on CreateWalletState {}

extension AddingEmailState on CreateWalletState {}

/// Define the Bloc
class CreateWalletBloc extends Bloc<CreateWalletEvent, CreateWalletState> {
  final UserManager userManager;
  final WalletKeysProvider walletKeysProvider;
  final WalletsDataProvider walletsDataProvider;
  final WalletPassphraseProvider walletPassphraseProvider;

  /// initialize the bloc with the initial state
  CreateWalletBloc(
    this.userManager,
    this.walletsDataProvider,
    this.walletKeysProvider,
    this.walletPassphraseProvider,
  ) : super(CreateWalletState()) {
    on<CreateWalletEvent>((event, emit) async {
      // int walletID = await processWalletData(
      //     walletData, walletName, encryptedMnemonic, fingerprint, walletType);
      // await WalletManager.setWalletKey([walletData.walletKey]);
      // await WalletManager.addWalletAccount(
      //     walletID, appConfig.scriptTypeInfo, "My wallet account", fiatCurrency);
    });
  }

  ///### None block functions

  Future<ApiWalletData> createWallet(
    String walletName,
    String mnemonicStr,
    Network network,
    int walletType,
    String walletPassphrase,
  ) async {
    /// Generate a wallet secret key
    final SecretKey secretKey = WalletKeyHelper.generateSecretKey();
    final Uint8List entropy = Uint8List.fromList(await secretKey.extractBytes());

    /// get first user key (primary user key)
    final firstUserKey = await userManager.getFirstKey();
    final String userPrivateKey = firstUserKey.privateKey;
    final String userKeyID = firstUserKey.keyID;
    final String passphrase = firstUserKey.passphrase;

    /// encrypt mnemonic with wallet key
    final String encryptedMnemonic = await WalletKeyHelper.encrypt(
      secretKey,
      mnemonicStr,
    );

    /// encrypt wallet name with wallet key
    final String clearWalletName = walletName.isNotEmpty ? walletName : "My Wallet";
    final String encryptedWalletName = await WalletKeyHelper.encrypt(
      secretKey,
      clearWalletName,
    );

    /// get fingerprint from mnemonic
    final frbWallet = FrbWallet(
      network: network,
      bip39Mnemonic: mnemonicStr,
      bip38Passphrase: walletPassphrase.isNotEmpty ? walletPassphrase : null,
    );
    final String fingerprint = frbWallet.getFingerprint();

    /// encrypt wallet key with user private key
    final String encryptedWalletKey = proton_crypto.encryptBinaryArmor(
      userPrivateKey,
      entropy,
    );

    /// sign wallet key with user private key
    final String walletKeySignature = proton_crypto.getBinarySignatureWithContext(
      userPrivateKey,
      passphrase,
      entropy,
      gpgContextWalletKey,
    );

    final CreateWalletReq walletReq = _buildWalletRequest(
        encryptedWalletName,
        walletType,
        encryptedMnemonic,
        fingerprint,
        userPrivateKey,
        userKeyID,
        encryptedWalletKey,
        walletKeySignature,
        walletPassphrase.isNotEmpty);

    /// save wallet to server through provder
    final ApiWalletData walletData =
        await walletsDataProvider.createWallet(walletReq);

    /// save wallet key to local storage
    walletKeysProvider.saveApiWalletKeys([walletData.walletKey]);

    /// save wallet passphrase to secure storage
    if (walletPassphrase.isNotEmpty) {
      walletPassphraseProvider.saveWalletPassphrase(
        WalletPassphrase(
          walletID: walletData.wallet.id,
          passphrase: walletPassphrase,
        ),
      );
    }

    return walletData;
  }

  Future<ApiWalletAccount> createWalletAccount(
    String walletID,
    ScriptTypeInfo scriptType,
    String label,
    FiatCurrency fiatCurrency,
    int accountIndex,
  ) async {
    final String serverWalletID = walletID;

    final firstUserKey = await userManager.getFirstKey();
    final walletKey = await walletKeysProvider.getWalletKey(serverWalletID);
    if (walletKey == null) {
      throw Exception("Wallet key not found");
    }
    final secretKey = WalletKeyHelper.decryptWalletKey(firstUserKey, walletKey);
    // var signature = walletKey.walletKeySignature;

    /// get new derivation path
    final String derivationPath = await walletsDataProvider.getNewDerivationPathBy(
      serverWalletID,
      scriptType,
      appConfig.coinType,
      accountIndex: accountIndex,
    );

    final CreateWalletAccountReq request = CreateWalletAccountReq(
      label: await WalletKeyHelper.encrypt(secretKey, label),
      derivationPath: derivationPath,
      scriptType: appConfig.scriptTypeInfo.index,
    );

    final apiWalletAccount = await walletsDataProvider.createWalletAccount(
        serverWalletID, request, fiatCurrency);

    return apiWalletAccount;
  }

  CreateWalletReq _buildWalletRequest(
    String encryptedName,
    int type,
    String mnemonic,
    String fingerprint,
    String userKey,
    String userKeyID,
    String encryptedWalletKey,
    String walletKeySignature,
    bool hasPassphrase,
  ) {
    return CreateWalletReq(
      name: encryptedName,
      isImported: type,
      type: WalletModel.typeOnChain,
      hasPassphrase: hasPassphrase ? 1 : 0,
      userKeyId: userKeyID,
      walletKey: encryptedWalletKey,
      fingerprint: fingerprint,
      mnemonic: mnemonic,
      walletKeySignature: walletKeySignature,
      isAutoCreated: 0,
    );
  }
}
