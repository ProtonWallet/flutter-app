import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';

class HistoryTransaction {
  final String txID;
  final int? createTimestamp;
  final int? updateTimestamp;
  final int feeInSATS;
  final int amountInSATS;
  final ProtonExchangeRate? exchangeRate;
  final String? label;
  final String sender;
  final String toList;
  final bool inProgress;
  final String? body;
  final AccountModel accountModel;

  HistoryTransaction(
      {required this.txID,
      this.createTimestamp,
      this.updateTimestamp,
      required this.amountInSATS,
      required this.feeInSATS,
      this.exchangeRate,
      this.label,
      required this.sender,
      required this.toList,
      this.inProgress = false,
      this.body,
      required this.accountModel});
}
