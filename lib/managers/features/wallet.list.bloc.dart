import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
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
import 'package:wallet/rust/proton_api/exchange_rate.dart';

// Define the events
abstract class WalletListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SelectWallet extends WalletListEvent {
  final String walletID;

  SelectWallet(this.walletID);

  @override
  List<Object> get props => [walletID];
}

class UpdateWalletName extends WalletListEvent {
  final WalletModel walletModel;
  final String newName;

  UpdateWalletName(this.walletModel, this.newName);

  @override
  List<Object> get props => [walletModel, newName];
}

class StartLoading extends WalletListEvent {
  StartLoading();

  @override
  List<Object> get props => [];
}

class UpdateBalance extends WalletListEvent {
  UpdateBalance();

  @override
  List<Object> get props => [];
}

class SelectAccount extends WalletListEvent {
  final String walletID;
  final String accountID;

  SelectAccount(this.walletID, this.accountID);

  @override
  List<Object> get props => [walletID, accountID];
}

class UpdateAccountName extends WalletListEvent {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final String newName;

  UpdateAccountName(this.walletModel, this.accountModel, this.newName);

  @override
  List<Object> get props => [walletModel, accountModel, newName];
}

class AddEmailIntegration extends WalletListEvent {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final String emailID;

  AddEmailIntegration(this.walletModel, this.accountModel, this.emailID);

  @override
  List<Object> get props => [walletModel, accountModel, emailID];
}

class RemoveEmailIntegration extends WalletListEvent {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final String emailID;

  RemoveEmailIntegration(this.walletModel, this.accountModel, this.emailID);

  @override
  List<Object> get props => [walletModel, accountModel, emailID];
}

class UpdateAccountFiat extends WalletListEvent {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final String fiatName;

  UpdateAccountFiat(this.walletModel, this.accountModel, this.fiatName);

  @override
  List<Object> get props => [walletModel, accountModel, fiatName];
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
  final BDKTransactionDataProvider bdkTransactionDataProvider;

  StreamSubscription? walletPassDataSubscription;
  StreamSubscription? bdkTransactionDataSubscription;
  StreamSubscription? walletsDataSubscription;
  StreamSubscription? selectedWalletChangeSubscription;

  VoidCallback? startLoadingCallback;
  VoidCallback? onboardingCallback;

  WalletListBloc(
    this.walletsDataProvider,
    this.walletPassProvider,
    this.walletKeysProvider,
    this.userManager,
    this.userSettingsDataProvider,
    this.bdkTransactionDataProvider,
  ) : super(const WalletListState(initialized: false, walletsModel: [])) {
    selectedWalletChangeSubscription = walletsDataProvider
        .selectedWalletUpdateController.stream
        .listen((data) async {
      if (walletsDataProvider.selectedServerWalletID.isNotEmpty) {
        if (walletsDataProvider.selectedServerWalletAccountID.isEmpty) {
          /// wallet view
          add(SelectWallet(
            walletsDataProvider.selectedServerWalletID,
          ));
        } else {
          /// wallet account view
          add(SelectAccount(
            walletsDataProvider.selectedServerWalletID,
            walletsDataProvider.selectedServerWalletAccountID,
          ));
        }
      }
    });

    walletsDataSubscription =
        walletsDataProvider.dataUpdateController.stream.listen((onData) {
      //TODO:: improve me
      add(StartLoading());
    });

    bdkTransactionDataSubscription =
        bdkTransactionDataProvider.dataUpdateController.stream.listen((state) {
      add(UpdateBalance());
    });

    walletPassDataSubscription =
        walletPassProvider.dataUpdateController.stream.listen((onData) {
      //TODO:: improve me
      add(StartLoading());
    });

    on<StartLoading>((event, emit) async {
      // loading wallet data
      var wallets = await walletsDataProvider.getWallets();
      if (wallets == null || wallets.isEmpty) {
        onboardingCallback?.call();
        emit(state.copyWith(initialized: true, walletsModel: []));
        return; // error;
      }

      bool hasSelected = false;

      /// get user key
      var firstUserKey = await userManager.getFirstKey();
      List<WalletMenuModel> walletsModel = [];
      int index = 0;
      for (WalletData wallet in wallets) {
        WalletMenuModel walletModel = WalletMenuModel(wallet.wallet);
        walletModel.currentIndex = index++;
        if (walletModel.walletModel.walletID ==
                walletsDataProvider.selectedServerWalletID &&
            walletsDataProvider.selectedServerWalletAccountID.isEmpty) {
          walletModel.isSelected = true;
          hasSelected = true;
        }
        // check if wallet has password valid. no password is valid
        walletModel.hasValidPassword = await _hasValidPassphrase(
          wallet.wallet,
          walletPassProvider,
        );

        var walletKey = await walletKeysProvider.getWalletKey(
          wallet.wallet.walletID,
        );
        SecretKey? secretKey;
        if (walletKey != null) {
          secretKey = WalletKeyHelper.decryptWalletKey(
            firstUserKey,
            walletKey,
          );

          var isValidWalletKeySignature =
              await WalletKeyHelper.verifySecretKeySignature(
            firstUserKey,
            walletKey,
            secretKey,
          );

          walletModel.isSignatureValid = isValidWalletKeySignature;
          logger.i("isValidWalletKeySignature = $isValidWalletKeySignature");
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
          if (walletModel.walletModel.walletID ==
                  walletsDataProvider.selectedServerWalletID &&
              accMenuModel.accountModel.accountID ==
                  walletsDataProvider.selectedServerWalletAccountID) {
            hasSelected = true;
            accMenuModel.isSelected = true;
          }
          if (secretKey != null) {
            var encrypted = base64Encode(account.label);
            try {
              accMenuModel.label = await WalletKeyHelper.decrypt(
                secretKey,
                encrypted,
              );
            } catch (e) {
              logger.e(e.toString());
            }
          }

          var balance = await WalletManager.getWalletAccountBalance(
            wallet.wallet.walletID,
            account.accountID,
          );

          accMenuModel.balance = balance.toInt();
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

          accMenuModel.emailIds =
              await WalletManager.getAccountAddressIDs(account.accountID);
          walletModel.accounts.add(accMenuModel);
        }
        walletsModel.add(walletModel);
      }
      emit(state.copyWith(initialized: true, walletsModel: walletsModel));
      if (hasSelected == false) {
        /// trigger startLoadingCallback to select default wallet
        startLoadingCallback?.call();
      }
    });

    on<SelectWallet>((event, emit) async {
      final walletID = event.walletID;
      for (WalletMenuModel walletModel in state.walletsModel) {
        walletModel.isSelected = walletModel.walletModel.walletID == walletID;
        bool isSelectedWallet = false;
        if (walletModel.isSelected) {
          walletsDataProvider.selectedServerWalletID = walletID;
          isSelectedWallet = true;
        }
        bool hasUpdateUserSetting = false;
        for (AccountMenuModel account in walletModel.accounts) {
          account.isSelected = false;
          if (isSelectedWallet && hasUpdateUserSetting == false) {
            userSettingsDataProvider.updateFiatCurrency(
                account.accountModel.fiatCurrency.toFiatCurrency());
            hasUpdateUserSetting = true;
          }
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<SelectAccount>((event, emit) async {
      final walletID = event.walletID;
      final accountID = event.accountID;

      for (WalletMenuModel walletModel in state.walletsModel) {
        walletModel.isSelected = false;
        if (walletModel.walletModel.walletID == walletID) {
          for (AccountMenuModel account in walletModel.accounts) {
            account.isSelected = account.accountModel.accountID == accountID;
            if (account.isSelected) {
              userSettingsDataProvider.updateFiatCurrency(
                  account.accountModel.fiatCurrency.toFiatCurrency());
            }
          }
        } else {
          for (AccountMenuModel account in walletModel.accounts) {
            account.isSelected = false;
          }
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<UpdateWalletName>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          walletModel.walletName = event.newName;

          /// TODO:: infomr data provider to update name? but this is WalletMenuModel only, data provider need walletMdoel
          break;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<UpdateAccountFiat>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          if (walletModel.isSelected) {
            /// wallet view, check if the update fiat is the default account
            AccountMenuModel? accountMenuModel =
                walletModel.accounts.firstOrNull;
            if (accountMenuModel != null) {
              if (accountMenuModel.accountModel.accountID ==
                  event.accountModel.accountID) {
                userSettingsDataProvider.updateFiatCurrency(
                  event.fiatName.toFiatCurrency(),
                );
              }
            }
          }
          for (AccountMenuModel account in walletModel.accounts) {
            if (account.accountModel.accountID ==
                event.accountModel.accountID) {
              /// TODO:: handle wallet account view change here
              if (account.isSelected) {
                userSettingsDataProvider.updateFiatCurrency(
                  event.fiatName.toFiatCurrency(),
                );
              }
              account.accountModel.fiatCurrency = event.fiatName;
              walletsDataProvider.updateWalletAccount(
                  accountModel: event.accountModel);

              double estimateValue = 0.0;
              var settings = await userSettingsDataProvider.getSettings();

              var balance = await WalletManager.getWalletAccountBalance(
                walletModel.walletModel.walletID,
                account.accountModel.accountID,
              );
              // Tempary need to use providers
              var fiatCurrency =
                  WalletManager.getAccountFiatCurrency(account.accountModel);
              ProtonExchangeRate? exchangeRate =
                  await ExchangeRateService.getExchangeRate(fiatCurrency);
              estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
                exchangeRate,
                balance.toInt(),
              );

              account.currencyBalance =
                  "${event.fiatName} ${estimateValue.toStringAsFixed(defaultDisplayDigits)}";
              account.btcBalance = ExchangeCalculator.getBitcoinUnitLabel(
                (settings?.bitcoinUnit ?? "btc").toBitcoinUnit(),
                balance.toInt(),
              );
              break;
            }
          }
          break;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<UpdateAccountName>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          for (AccountMenuModel account in walletModel.accounts) {
            if (account.accountModel.accountID ==
                event.accountModel.accountID) {
              account.label = event.newName;
              break;
            }
          }
          break;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<AddEmailIntegration>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          for (AccountMenuModel account in walletModel.accounts) {
            if (account.accountModel.accountID ==
                event.accountModel.accountID) {
              if (account.emailIds.contains(event.emailID) == false) {
                account.emailIds.add(event.emailID);
              }
              break;
            }
          }
          break;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<RemoveEmailIntegration>((event, emit) async {
      for (WalletMenuModel walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          for (AccountMenuModel account in walletModel.accounts) {
            if (account.accountModel.accountID ==
                event.accountModel.accountID) {
              account.emailIds.remove(event.emailID);
              break;
            }
          }
          break;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<UpdateBalance>((event, emit) async {
      var wallets = state.walletsModel;
      for (WalletMenuModel walletModel in wallets) {
        for (AccountMenuModel account in walletModel.accounts) {
          var balance = await WalletManager.getWalletAccountBalance(
            walletModel.walletModel.walletID,
            account.accountModel.accountID,
          );
          account.balance = balance.toInt();
          double estimateValue = 0.0;
          var settings = await userSettingsDataProvider.getSettings();
          // Tempary need to use providers
          var fiatCurrency =
              WalletManager.getAccountFiatCurrency(account.accountModel);
          ProtonExchangeRate? exchangeRate =
              await ExchangeRateService.getExchangeRate(fiatCurrency);
          estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
            exchangeRate,
            balance.toInt(),
          );
          var fiatName = fiatCurrency.name.toString().toUpperCase();
          account.currencyBalance =
              "$fiatName ${estimateValue.toStringAsFixed(defaultDisplayDigits)}";
          account.btcBalance = ExchangeCalculator.getBitcoinUnitLabel(
            (settings?.bitcoinUnit ?? "btc").toBitcoinUnit(),
            balance.toInt(),
          );
        }
      }
      emit(state.copyWith(walletsModel: wallets));
    });
  }

  void init({
    VoidCallback? startLoadingCallback,
    required VoidCallback onboardingCallback,
  }) {
    this.startLoadingCallback = startLoadingCallback;
    this.onboardingCallback = onboardingCallback;
    add(StartLoading());
  }

  void selectWallet(WalletModel wallet) {
    add(SelectWallet(wallet.walletID));
  }

  void selectAccount(WalletModel wallet, AccountModel acct) {
    add(SelectAccount(wallet.walletID, acct.accountID));
  }

  void updateWalletName(WalletModel wallet, String newName) {
    add(UpdateWalletName(wallet, newName));
  }

  void updateAccountName(
      WalletModel wallet, AccountModel acct, String newName) {
    add(UpdateAccountName(wallet, acct, newName));
  }

  void addEmailIntegration(
      WalletModel wallet, AccountModel acct, String emailID) {
    add(AddEmailIntegration(wallet, acct, emailID));
  }

  void removeEmailIntegration(
      WalletModel wallet, AccountModel acct, String emailID) {
    add(RemoveEmailIntegration(wallet, acct, emailID));
  }

  void updateAccountFiat(
      WalletModel wallet, AccountModel acct, String fiatName) {
    add(UpdateAccountFiat(wallet, acct, fiatName));
  }

  Future<bool> _hasValidPassphrase(
    WalletModel wallet,
    WalletPassphraseProvider walletPassProvider,
  ) async {
    // Check if the wallet requires a passphrase and if the passphrase is valid
    if (wallet.passphrase == 1) {
      final passphrase = await walletPassProvider.getPassphrase(
        wallet.walletID,
      );
      return passphrase != null;
    }
    // Default to false if none of the above conditions are met
    return true;
  }

  @override
  Future<void> close() {
    walletsDataSubscription?.cancel();
    walletPassDataSubscription?.cancel();
    bdkTransactionDataSubscription?.cancel();
    return super.close();
  }
}
