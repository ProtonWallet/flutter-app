// Define the events
import 'package:equatable/equatable.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';

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
