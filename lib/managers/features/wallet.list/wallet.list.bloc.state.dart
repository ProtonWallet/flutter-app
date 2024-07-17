// Define the state
import 'package:equatable/equatable.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';

class WalletListState extends Equatable {
  final bool initialized;
  final List<WalletMenuModel> walletsModel;

  const WalletListState({
    required this.initialized,
    required this.walletsModel,
  });

  /// copy state
  WalletListState copyWith({
    bool? initialized,
    List<WalletMenuModel>? walletsModel,
  }) {
    return WalletListState(
      initialized: initialized ?? this.initialized,
      walletsModel: walletsModel ?? this.walletsModel,
    );
  }

  @override
  List<Object?> get props => [initialized, walletsModel];
}
