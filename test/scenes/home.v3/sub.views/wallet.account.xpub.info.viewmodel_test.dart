import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.viewmodel.dart';

import 'wallet.account.xpub.info.viewmodel_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<WalletAccountXpubInfoCoodinator>(),
  MockSpec<WalletManager>(),
  MockSpec<AccountModel>(),
  MockSpec<FrbAccount>(),
])
void main() {
  late MockWalletAccountXpubInfoCoodinator mockWalletAccountXpubInfoCoordinator;
  late MockWalletManager mockWalletManager;
  late MockAccountModel mockAccountModel;
  late MockFrbAccount mockFrbAccount;
  final String walletId = "test_wallet_id";
  final String accountId = "test_account_id";
  final String xpub = "test_xpub";

  late WalletAccountXpubInfoViewModelImpl sut;
  group('WalletAccountXpubInfoViewModelImpl', () {
    setUp(() {
      mockWalletAccountXpubInfoCoordinator =
          MockWalletAccountXpubInfoCoodinator();
      mockWalletManager = MockWalletManager();
      mockAccountModel = MockAccountModel();
      mockFrbAccount = MockFrbAccount();

      sut = WalletAccountXpubInfoViewModelImpl(
        mockWalletAccountXpubInfoCoordinator,
        mockAccountModel,
        mockWalletManager,
      );
    });
    test('loadData test', () async {
      when(mockAccountModel.walletID).thenReturn(walletId);
      when(mockAccountModel.accountID).thenReturn(accountId);
      when(mockAccountModel.scriptType).thenReturn(1);
      when(mockWalletManager.loadWalletWithID(walletId, accountId,
              serverScriptType: 1))
          .thenAnswer((_) async => mockFrbAccount);
      when(mockFrbAccount.getXpub()).thenAnswer((_) async => xpub);

      await sut.loadData();

      expect(sut.xpub, xpub);
      verify(mockWalletManager.loadWalletWithID(walletId, accountId,
              serverScriptType: 1))
          .called(1);
      verify(mockFrbAccount.getXpub()).called(1);
    });
  });
}
