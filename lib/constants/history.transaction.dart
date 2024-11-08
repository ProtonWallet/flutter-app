import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';

class HistoryTransaction {
  final String txID;
  final int? createTimestamp;
  final int? updateTimestamp;
  final int feeInSATS;
  final int amountInSATS;
  final ProtonExchangeRate exchangeRate;
  final String? label;
  final String sender;
  final String toList;
  final bool inProgress;
  final String? body;
  final AccountModel accountModel;
  final List<String> bitcoinAddresses;
  final FrbTransactionDetails frbTransactionDetails;

  HistoryTransaction({
    required this.txID,
    required this.amountInSATS,
    required this.feeInSATS,
    required this.exchangeRate,
    required this.sender,
    required this.toList,
    required this.accountModel,
    required this.bitcoinAddresses,
    required this.frbTransactionDetails,
    this.createTimestamp,
    this.updateTimestamp,
    this.label,
    this.inProgress = false,
    this.body,
  });
}
