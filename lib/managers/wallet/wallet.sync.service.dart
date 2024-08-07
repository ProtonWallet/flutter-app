// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/services/service.dart';

class WalletSyncService extends Service {
  final BDKTransactionDataProvider transactionDataProvider;

  WalletSyncService(
    this.transactionDataProvider, {
    required super.duration,
  });

  @override
  Future<Duration?> onUpdate() async {
    return null;
  }
}
