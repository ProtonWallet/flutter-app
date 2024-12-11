import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/managers/providers/models/wallet.passphrase.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/wallet.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';
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
    on<CreateWalletEvent>((event, emit) async {});
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
    final unlockedWalletKey = FrbWalletKeyHelper.generateSecretKey();

    /// encrypt mnemonic with wallet key
    final encryptedMnemonic = FrbWalletKeyHelper.encrypt(
      base64SecureKey: unlockedWalletKey.toBase64(),
      plaintext: mnemonicStr,
    );

    /// encrypt wallet name with wallet key
    final clearWalletName =
        walletName.isNotEmpty ? walletName : defaultWalletName;
    final encryptedWalletName = FrbWalletKeyHelper.encrypt(
      base64SecureKey: unlockedWalletKey.toBase64(),
      plaintext: clearWalletName,
    );

    /// get fingerprint from mnemonic
    final frbWallet = FrbWallet(
      network: network,
      bip39Mnemonic: mnemonicStr,
      bip38Passphrase: walletPassphrase.isNotEmpty ? walletPassphrase : null,
    );
    final String fingerprint = frbWallet.getFingerprint();

    final primaryUserKey = await userManager.getPrimaryKeyForTL();
    final passphrase = userManager.getUserKeyPassphrase();

    final encryptedWalletKey = await FrbTransitionLayer.encryptWalletKey(
        walletKey: unlockedWalletKey,
        userKey: primaryUserKey,
        userKeyPassphrase: passphrase);

    /// encrypt wallet key with user private key
    final String encryptedArmoredWalletKey = encryptedWalletKey.getArmored();

    /// sign wallet key with user private key
    final String walletKeySignature = encryptedWalletKey.getSignature();

    final CreateWalletReq walletReq = _buildWalletRequest(
        encryptedWalletName,
        walletType,
        encryptedMnemonic,
        fingerprint,
        primaryUserKey.id,
        encryptedArmoredWalletKey,
        walletKeySignature,
        walletPassphrase.isNotEmpty);

    /// save wallet to server through provder
    final ApiWalletData walletData =
        await walletsDataProvider.createWallet(walletReq);

    /// save wallet key to local storage
    walletKeysProvider.saveApiWalletKeys([walletData.walletKey]);

    /// save wallet passphrase to secure storage
    if (walletPassphrase.isNotEmpty) {
      await walletPassphraseProvider.saveWalletPassphrase(
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

    final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
      serverWalletID,
    );

    /// get new derivation path
    final derivationPath = await walletsDataProvider.getNewDerivationPathBy(
      serverWalletID,
      scriptType,
      appConfig.coinType,
      accountIndex: accountIndex,
    );

    final CreateWalletAccountReq request = CreateWalletAccountReq(
      label: FrbWalletKeyHelper.encrypt(
        base64SecureKey: unlockedWalletKey.toBase64(),
        plaintext: label,
      ),
      derivationPath: derivationPath,
      scriptType: scriptType.index,
    );

    final apiWalletAccount = await walletsDataProvider.createWalletAccount(
      serverWalletID,
      request,
      fiatCurrency,
    );

    return apiWalletAccount;
  }

  CreateWalletReq _buildWalletRequest(
    String encryptedName,
    int type,
    String mnemonic,
    String fingerprint,
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
