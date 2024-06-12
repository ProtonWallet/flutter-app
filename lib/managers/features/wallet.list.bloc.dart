import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/rust/proton_api/exchange_rate.dart';

// Define the events
abstract class WalletListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SelectWallet extends WalletListEvent {
  final WalletModel walletModel;

  SelectWallet(this.walletModel);

  @override
  List<Object> get props => [walletModel];
}

class StartLoading extends WalletListEvent {
  StartLoading();

  @override
  List<Object> get props => [];
}

class SelectAccount extends WalletListEvent {
  final WalletModel walletModel;
  final AccountModel accountModel;

  SelectAccount(this.walletModel, this.accountModel);

  @override
  List<Object> get props => [walletModel, accountModel];
}

// Define the state
class WalletListState extends Equatable {
  final bool initialized;
  final List<WalletMenuModel> walletsModel;

  const WalletListState({
    required this.initialized,
    required this.walletsModel,
  });

  @override
  List<Object?> get props => [initialized, walletsModel];
}

extension WalletListStateCopyWith on WalletListState {
  WalletListState copyWith({
    bool? initialized,
    List<WalletMenuModel>? walletsModel,
  }) {
    return WalletListState(
      initialized: initialized ?? this.initialized,
      walletsModel: walletsModel ?? this.walletsModel,
    );
  }
}

/// Define the Bloc
class WalletListBloc extends Bloc<WalletListEvent, WalletListState> {
  final WalletsDataProvider walletsDataProvider;
  final WalletPassphraseProvider walletPassProvider;
  final WalletKeysProvider walletKeysProvider;
  final UserSettingsDataProvider userSettingsDataProvider;
  final UserManager userManager;

  WalletListBloc(
    this.walletsDataProvider,
    this.walletPassProvider,
    this.walletKeysProvider,
    this.userManager,
    this.userSettingsDataProvider,
  ) : super(const WalletListState(initialized: false, walletsModel: [])) {
    on<StartLoading>((event, emit) async {
      // loading wallet data
      var wallets = await walletsDataProvider.getWallets();
      if (wallets == null) {
        emit(state.copyWith(initialized: true));
        return; // error;
      }

      /// get user key
      var userkey = await userManager.getFirstKey();
      var userPrivateKey = userkey.privateKey;
      var userPassphrase = userkey.passphrase;

      List<WalletMenuModel> walletsModel = [];
      int index = 0;
      for (WalletData wallet in wallets) {
        WalletMenuModel walletModel = WalletMenuModel(wallet.wallet);
        if (index == 0) {
          walletModel.isSelected = true;
        }
        walletModel.currentIndex = index++;

        // check if wallet has password valid. no password is valid
        walletModel.hasValidPassword = await _hasValidPassphrase(
          wallet.wallet,
          walletPassProvider,
        );
        var walletKey = await walletKeysProvider.getWalletKey(
          wallet.wallet.serverWalletID,
        );
        Uint8List? entropy;
        SecretKey? secretKey;
        if (walletKey != null) {
          var pgpEncryptedWalletKey = walletKey.walletKey;
          var signature = walletKey.walletKeySignature;
          // decrypt wallet key
          entropy = proton_crypto.decryptBinaryPGP(
            userPrivateKey,
            userPassphrase,
            pgpEncryptedWalletKey,
          );
          var userPublicKey = proton_crypto.getArmoredPublicKey(userPrivateKey);
          // check signature
          var isValidWalletKeySignature =
              proton_crypto.verifyBinarySignatureWithContext(
            userPublicKey,
            entropy,
            signature,
            gpgContextWalletKey,
          );
          walletModel.isSignatureValid = isValidWalletKeySignature;
          logger.i("isValidWalletKeySignature = $isValidWalletKeySignature");

          secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
        }
        walletModel.accountSize = wallet.accounts.length;
        walletModel.walletName = wallet.wallet.name;

        if (secretKey != null) {
          try {
            walletModel.walletName = await WalletKeyHelper.decrypt(
              secretKey,
              wallet.wallet.name,
            );
          } catch (e) {
            logger.e(e.toString());
          }
        }

        for (AccountModel account in wallet.accounts) {
          AccountMenuModel accMenuModel = AccountMenuModel(account);

          if (secretKey != null) {
            var encrypted = base64Encode(account.label);
            accMenuModel.label = await WalletKeyHelper.decrypt(
              secretKey,
              encrypted,
            );
          }

          // TODO:: fixme
          var balance = await WalletManager.getWalletAccountBalance(
            wallet.wallet.id!,
            account.id!,
          );

          double estimateValue = 0.0;
          var settings = await userSettingsDataProvider.getSettings();
          // Tempary need to use providers
          var fiatCurrency = WalletManager.getAccountFiatCurrency(account);
          ProtonExchangeRate? exchangeRate =
              await ExchangeRateService.getExchangeRate(fiatCurrency);
          estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
            exchangeRate,
            balance.toInt(),
          );
          var fiatName = fiatCurrency.name.toString().toUpperCase();
          accMenuModel.currencyBalance =
              "$fiatName ${estimateValue.toStringAsFixed(defaultDisplayDigits)}";
          accMenuModel.btcBalance = ExchangeCalculator.getBitcoinUnitLabel(
            (settings?.bitcoinUnit ?? "btc").toBitcoinUnit(),
            balance.toInt(),
          );

          ///
          walletModel.accounts.add(accMenuModel);
        }

        ///
        walletsModel.add(walletModel);
      }

      ///
      emit(state.copyWith(initialized: true, walletsModel: walletsModel));
    });

    on<SelectWallet>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        walletModel.isSelected = walletModel.walletModel.serverWalletID ==
            event.walletModel.serverWalletID;
        for (AccountMenuModel account in walletModel.accounts) {
          account.isSelected = false;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<SelectAccount>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        walletModel.isSelected = false;
        if (walletModel.walletModel.serverWalletID ==
            event.walletModel.serverWalletID) {
          for (AccountMenuModel account in walletModel.accounts) {
            account.isSelected =
                account.accountModel.id == event.accountModel.id;
          }
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });
  }

  void init() {
    add(StartLoading());
  }

  void setWallet(WalletModel wallet) {
    add(SelectWallet(wallet));
  }

  void setAccount(WalletModel wallet, AccountModel acct) {
    add(SelectAccount(wallet, acct));
  }

  Future<bool> _hasValidPassphrase(
    WalletModel wallet,
    WalletPassphraseProvider walletPassProvider,
  ) async {
    // Check if the wallet requires a passphrase and if the passphrase is valid
    if (wallet.passphrase == 1) {
      final passphrase = await walletPassProvider.getWalletPassphrase(
        wallet.serverWalletID,
      );
      return passphrase != null;
    }
    // Default to false if none of the above conditions are met
    return true;
  }
}
