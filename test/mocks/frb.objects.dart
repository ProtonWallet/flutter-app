import 'package:mockito/annotations.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';
import 'package:wallet/rust/api/bdk_wallet/amount.dart';
import 'package:wallet/rust/api/bdk_wallet/balance.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';

@GenerateMocks([
  FrbAddressDetails,
  FrbAmount,
  FrbBalance,
  FrbTransactionDetails,
])
void main() {}
