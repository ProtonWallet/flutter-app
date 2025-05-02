import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:wallet/helper/extension/datetime.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/bdk_wallet/account_statement_generator.dart';
import 'package:wallet/rust/common/keychain_kind.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.statement.export/wallet.account.statement.export.coordinator.dart';

enum ExportType {
  pdf,
  csv,
}

abstract class WalletAccountStatementExportViewModel
    extends ViewModel<WalletAccountStatementExportCoordinator> {
  final WalletListBloc walletListBloc;
  final AccountMenuModel accountMenuModel;

  WalletAccountStatementExportViewModel(
    this.walletListBloc,
    this.accountMenuModel,
    super.coordinator,
  );

  /// variables expose for UI
  int accountLastUsedIndex = -1;
  int accountPriority = -1;
  int accountHighestIndexFromBlockchain = -1;
  int accountPoolSize = -1;
  String accountName = "";
  String accountDerivationPath = "";
  ExportType exportType = ExportType.pdf;

  TextEditingController dateTextEditingController = TextEditingController();
  FocusNode dateFocusNode = FocusNode();
  DateTime initialDate = DateTime.now();

  Future<Uint8List?> getAccountStatementData();

  void changeExportType(type);
}

class WalletAccountStatementExportViewModelImpl
    extends WalletAccountStatementExportViewModel {
  WalletAccountStatementExportViewModelImpl(
    super.walletListBloc,
    super.accountMenuModel,
    super.coordinator,
    this.walletManager,
    this.dataProviderManager,
  );

  /// wallet manager
  final WalletManager walletManager;
  final DataProviderManager dataProviderManager;

  @override
  Future<void> loadData() async {
    /// load date
    final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      dateTextEditingController.text = initialDate.toLocaleFormatYMD(context);
    }
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<Uint8List?> getAccountStatementData() async {
    try {
      DateTime dateTime = DateTime.now();
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        dateTime = DateFormat.yMd(Localizations.localeOf(context).toString())
            .parse(dateTextEditingController.text);
      }
      final timestamp = dateTime.secondsSinceEpoch();
      final exchangeRate =
          dataProviderManager.userSettingsDataProvider.exchangeRate;

      final accountStatementGenerator = FrbAccountStatementGenerator(
        exchangeRate: exchangeRate,
      );

      final frbAccount = (await walletManager.loadWalletWithID(
        accountMenuModel.accountModel.walletID,
        accountMenuModel.accountModel.accountID,
        serverScriptType: accountMenuModel.accountModel.scriptType,
      ))!;
      accountStatementGenerator.addAccount(
        account: frbAccount,
        accountName: accountMenuModel.label,
      );
      if (exportType == ExportType.pdf) {
        final data = await accountStatementGenerator.toPdf(
          exportTime: BigInt.from(timestamp),
        );
        return data;
      } else {
        final data = await accountStatementGenerator.toCsv(
          exportTime: BigInt.from(timestamp),
        );
        return data;
      }
    } catch (e) {
      e.toString();
    }
    return null;
  }

  @override
  void changeExportType(type) {
    if (type != exportType) {
      exportType = type;
      sinkAddSafe();
    }
  }
}
