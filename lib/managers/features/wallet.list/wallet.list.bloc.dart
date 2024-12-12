import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.event.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';

/// Define the Bloc
class WalletListBloc extends Bloc<WalletListEvent, WalletListState> {
  final WalletsDataProvider walletsDataProvider;
  final WalletPassphraseProvider walletPassProvider;
  final WalletKeysProvider walletKeysProvider;
  final UserSettingsDataProvider userSettingsDataProvider;
  final UserManager userManager;
  final WalletManager walletManager;
  final BDKTransactionDataProvider bdkTransactionDataProvider;

  /// app state manager
  final AppStateManager appStateManager;

  bool hasCheckFullSynced = false;
  bool hasShowOnboard = false;

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
    this.walletManager,
    this.userSettingsDataProvider,
    this.bdkTransactionDataProvider,
    this.appStateManager,
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
      add(StartLoading());
    });

    bdkTransactionDataSubscription =
        bdkTransactionDataProvider.stream.listen((state) {
      if (state is BDKSyncUpdated) {
        add(UpdateBalance());
      } else if (state is BDKSyncError) {
        logger.e("WalletListBloc BDKSyncError: ${state.updatedData}");
      } else if (state is BDKCacheCleared) {
        /// trigger startLoadingCallback to select default wallet
        /// so that home page can get reload
        startLoadingCallback?.call();
      }
    });

    walletPassDataSubscription =
        walletPassProvider.dataUpdateController.stream.listen((onData) {
      add(StartLoading());
    });

    on<StartLoading>((event, emit) async {
      try {
        // loading wallet data
        final wallets = await walletsDataProvider.getWallets();
        if (wallets == null || wallets.isEmpty) {
          if (!hasShowOnboard){
            hasShowOnboard = true;
            onboardingCallback?.call();
          }
          emit(state.copyWith(initialized: true, walletsModel: []));
          return; // error;
        }

        bool hasSelected = false;

        /// get user key
        final List<WalletMenuModel> walletsModel = [];
        int index = 0;
        for (WalletData wallet in wallets) {
          final WalletMenuModel walletModel = WalletMenuModel(wallet.wallet);
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

          walletModel.accountSize = wallet.accounts.length;
          walletModel.walletName = wallet.wallet.name;

          try {
            final unlockedWalletKey = await walletKeysProvider
                .getWalletSecretKey(wallet.wallet.walletID);

            try {
              walletModel.walletName = FrbWalletKeyHelper.decrypt(
                base64SecureKey: unlockedWalletKey.toBase64(),
                encryptText: wallet.wallet.name,
              );
            } catch (e) {
              logger.e(e.toString());
            }

            for (final account in wallet.accounts) {
              final accMenuModel = AccountMenuModel(account);
              if (walletModel.walletModel.walletID ==
                      walletsDataProvider.selectedServerWalletID &&
                  accMenuModel.accountModel.accountID ==
                      walletsDataProvider.selectedServerWalletAccountID) {
                hasSelected = true;
                accMenuModel.isSelected = true;
              }
              final encrypted = base64Encode(account.label);
              try {
                accMenuModel.label = FrbWalletKeyHelper.decrypt(
                  base64SecureKey: unlockedWalletKey.toBase64(),
                  encryptText: encrypted,
                );
              } catch (e) {
                logger.e(e.toString());
              }

              final settings = await userSettingsDataProvider.getSettings();
              final fiatCurrency = account.getFiatCurrency();

              /// setup btcBalance
              accMenuModel.btcBalance = ExchangeCalculator.getBitcoinUnitLabel(
                (settings?.bitcoinUnit ?? "btc").toBitcoinUnit(),
                0, // default 0 balance
              );

              final fiatSign = CommonHelper.getFiatCurrencySign(fiatCurrency);
              accMenuModel.currencyBalance = "$fiatSign ----";

              accMenuModel.emailIds = await WalletManager.getAccountAddressIDs(
                account.accountID,
              );
              walletModel.accounts.add(accMenuModel);
            }
          } catch (e, stacktrace) {
            Sentry.captureException(e, stackTrace: stacktrace);
            logger.e(e.toString());
          }

          walletsModel.add(walletModel);
        }
        emit(state.copyWith(initialized: true, walletsModel: walletsModel));
        if (!hasCheckFullSynced) {
          hasCheckFullSynced = true;
          for (WalletMenuModel walletMenuModel in walletsModel) {
            if (walletMenuModel.hasValidPassword) {
              for (AccountMenuModel accountMenuModel
                  in walletMenuModel.accounts) {
                final bool hasFullSynced =
                    await bdkTransactionDataProvider.hasFullSynced(
                        walletMenuModel.walletModel,
                        accountMenuModel.accountModel);
                if (!hasFullSynced) {
                  /// only do full-sync when app onStart()
                  /// no-need to do partial sync since we will show cached transaction/balance
                  /// and trigger partial sync when user switch account
                  bdkTransactionDataProvider.syncWallet(
                    walletMenuModel.walletModel,
                    accountMenuModel.accountModel,
                    forceSync: false,
                    heightChanged: false,
                  );
                }
              }
            }
          }
        }
        if (!hasSelected) {
          /// trigger startLoadingCallback to select default wallet
          startLoadingCallback?.call();
        }
      } on BridgeError catch (e, stacktrace) {
        logger.e("WalletListBloc error: $e, stacktrace: $stacktrace");
        appStateManager.updateStateFrom(e);
      } catch (e, stacktrace) {
        logger.e("WalletListBloc error: $e, stacktrace: $stacktrace");
        Sentry.captureException(e, stackTrace: stacktrace);
      }
    });

    on<SelectWallet>((event, emit) async {
      final walletID = event.walletID;
      for (final walletModel in state.walletsModel) {
        walletModel.isSelected = walletModel.walletModel.walletID == walletID;
        bool isSelectedWallet = false;
        if (walletModel.isSelected) {
          walletsDataProvider.selectedServerWalletID = walletID;
          isSelectedWallet = true;
        }
        bool hasUpdateUserSetting = false;
        for (final account in walletModel.accounts) {
          account.isSelected = false;
          if (isSelectedWallet && !hasUpdateUserSetting) {
            userSettingsDataProvider.updateFiatCurrency(
                account.accountModel.fiatCurrency.toFiatCurrency(),
                notify: false);
            hasUpdateUserSetting = true;
          }
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<SelectAccount>((event, emit) async {
      final walletID = event.walletID;
      final accountID = event.accountID;

      for (final walletModel in state.walletsModel) {
        walletModel.isSelected = false;
        if (walletModel.walletModel.walletID == walletID) {
          for (final account in walletModel.accounts) {
            account.isSelected = account.accountModel.accountID == accountID;
            if (account.isSelected) {
              userSettingsDataProvider.updateFiatCurrency(
                  account.accountModel.fiatCurrency.toFiatCurrency(),
                  notify: false);
            }
          }
        } else {
          for (final account in walletModel.accounts) {
            account.isSelected = false;
          }
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<UpdateWalletName>((event, emit) async {
      for (final walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          walletModel.walletName = event.newName;
          break;
        }
      }
      emit(state.copyWith(walletsModel: state.walletsModel));
    });

    on<UpdateAccountFiat>((event, emit) async {
      /// update local db data
      walletsDataProvider.updateWalletAccountFiatCurrency(
        event.walletModel.walletID,
        event.accountModel.accountID,
        event.fiatName.toFiatCurrency(),
      );

      /// update cached data
      for (final walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          if (walletModel.isSelected) {
            /// wallet view, check if the update fiat is the default account
            final AccountMenuModel? accountMenuModel =
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
          for (final account in walletModel.accounts) {
            if (account.accountModel.accountID ==
                event.accountModel.accountID) {
              if (account.isSelected) {
                userSettingsDataProvider.updateFiatCurrency(
                  event.fiatName.toFiatCurrency(),
                );
              }
              account.accountModel.fiatCurrency = event.fiatName;
              walletsDataProvider.updateWalletAccount(
                  accountModel: event.accountModel);

              double estimateValue = 0.0;
              final settings = await userSettingsDataProvider.getSettings();

              final balance = await walletManager.getWalletAccountBalance(
                walletModel.walletModel.walletID,
                account.accountModel.accountID,
              );
              final fiatCurrency = account.accountModel.getFiatCurrency();
              final ProtonExchangeRate exchangeRate =
                  await ExchangeRateService.getExchangeRate(fiatCurrency);
              estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
                exchangeRate,
                balance,
              );
              final String fiatSign =
                  CommonHelper.getFiatCurrencySign(fiatCurrency);
              account.currencyBalance =
                  "$fiatSign${estimateValue.toStringAsFixed(defaultDisplayDigits)}";
              account.btcBalance = ExchangeCalculator.getBitcoinUnitLabel(
                (settings?.bitcoinUnit ?? "btc").toBitcoinUnit(),
                balance,
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
      for (final walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          for (final account in walletModel.accounts) {
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
      for (final walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          for (final account in walletModel.accounts) {
            if (account.accountModel.accountID ==
                event.accountModel.accountID) {
              if (!account.emailIds.contains(event.emailID)) {
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
      for (final walletModel in state.walletsModel) {
        if (walletModel.walletModel.walletID == event.walletModel.walletID) {
          for (final account in walletModel.accounts) {
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
      final wallets = state.walletsModel;
      for (final walletModel in wallets) {
        for (final account in walletModel.accounts) {
          final balance = await walletManager.getWalletAccountBalance(
            walletModel.walletModel.walletID,
            account.accountModel.accountID,
          );
          account.balance = balance;
          double estimateValue = 0.0;
          final settings = await userSettingsDataProvider.getSettings();
          final fiatCurrency = account.accountModel.getFiatCurrency();
          final exchangeRate = await ExchangeRateService.getExchangeRate(
            fiatCurrency,
          );
          estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
            exchangeRate,
            balance,
          );

          final fiatSign = CommonHelper.getFiatCurrencySign(
            fiatCurrency,
          );
          account.currencyBalance =
              "$fiatSign${estimateValue.toStringAsFixed(defaultDisplayDigits)}";
          account.btcBalance = ExchangeCalculator.getBitcoinUnitLabel(
            (settings?.bitcoinUnit ?? "btc").toBitcoinUnit(),
            balance,
          );
        }
      }
      emit(state.copyWith(walletsModel: wallets));
    });
  }

  void init({
    required VoidCallback onboardingCallback,
    VoidCallback? startLoadingCallback,
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
    WalletModel wallet,
    AccountModel acct,
    String newName,
  ) {
    add(UpdateAccountName(wallet, acct, newName));
  }

  void addEmailIntegration(
    WalletModel wallet,
    AccountModel acct,
    String emailID,
  ) {
    add(AddEmailIntegration(wallet, acct, emailID));
  }

  void removeEmailIntegration(
    WalletModel wallet,
    AccountModel acct,
    String emailID,
  ) {
    add(RemoveEmailIntegration(wallet, acct, emailID));
  }

  void updateAccountFiat(
    WalletModel wallet,
    AccountModel acct,
    String fiatName,
  ) {
    add(UpdateAccountFiat(wallet, acct, fiatName));
  }

  List<String> getUsedEmailIDs() {
    List<String> usedEmailIDs = [];
    for (final walletMenuModel in state.walletsModel) {
      for (final accountMenuModel in walletMenuModel.accounts) {
        usedEmailIDs += accountMenuModel.emailIds;
      }
    }
    return usedEmailIDs;
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
    selectedWalletChangeSubscription?.cancel();
    return super.close();
  }
}
