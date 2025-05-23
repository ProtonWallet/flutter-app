// wallet.rs
use andromeda_bitcoin::{
    transactions::Pagination, utils::SortOrder, wallet::Wallet, TransactionFilter,
};
use andromeda_common::{Network, ScriptType};
use flutter_rust_bridge::frb;
use std::sync::Arc;

use super::{
    account::FrbAccount, balance::FrbBalance, derivation_path::FrbDerivationPath,
    discovered_account::DiscoveredAccount, storage::WalletMobilePersisterFactory,
    transaction_details::FrbTransactionDetails,
};
use crate::{api::api_service::proton_api_service::ProtonAPIService, BridgeError};

#[derive(Debug)]
pub struct FrbWallet {
    pub(crate) inner: Wallet,
}

impl FrbWallet {
    #[allow(dead_code)]
    pub(crate) fn get_inner(&self) -> &Wallet {
        &self.inner
    }
}

impl FrbWallet {
    #[frb(sync)]
    pub fn new(
        network: Network,
        bip39_mnemonic: String,
        bip38_passphrase: Option<String>,
    ) -> Result<FrbWallet, BridgeError> {
        let wallet =
            andromeda_bitcoin::wallet::Wallet::new(network, bip39_mnemonic, bip38_passphrase)?;
        Ok(FrbWallet { inner: wallet })
    }

    pub async fn discover_account(
        &self,
        api_service: Arc<ProtonAPIService>,
        factory: WalletMobilePersisterFactory,
        account_stop_gap: u32,
        address_stop_gap: usize,
    ) -> Result<Vec<DiscoveredAccount>, BridgeError> {
        let found = self
            .inner
            .discover_accounts(
                api_service.inner.clone(),
                factory,
                Some(account_stop_gap),
                Some(address_stop_gap),
            )
            .await?;
        let out_vec = found.into_iter().map(|x| x.into()).collect();

        Ok(out_vec)
    }

    #[frb(sync)]
    pub fn add_account(
        &mut self,
        script_type: ScriptType,
        derivation_path: String,
        factory: WalletMobilePersisterFactory,
    ) -> Result<FrbAccount, BridgeError> {
        // In a multi-wallet context, an account must be defined by the BIP32 masterkey
        // (fingerprint), and its derivation path (unique)
        let derivation_path = FrbDerivationPath::new(&derivation_path)?;
        let account =
            self.inner
                .add_account(script_type, derivation_path.clone_inner(), factory)?;

        Ok(account.into())
    }

    #[frb(sync)]
    pub fn get_account(&mut self, derivation_path: String) -> Option<FrbAccount> {
        let derivation_path = FrbDerivationPath::new(&derivation_path).ok();

        if let Some(der_path) = derivation_path {
            self.inner
                .get_account(&der_path.clone_inner())
                .map(|account| account.into())
        } else {
            None
        }
    }

    pub async fn get_balance(&self) -> Result<FrbBalance, BridgeError> {
        let balance = self.inner.get_balance().await?;
        Ok(balance.into())
    }

    pub async fn get_transactions(
        &self,
        pagination: Option<Pagination>,
        sort: Option<SortOrder>,
        TransactionFilter: TransactionFilter,
    ) -> Result<Vec<FrbTransactionDetails>, BridgeError> {
        let transactions = self
            .inner
            .get_transactions(pagination, sort, TransactionFilter)
            .await?;

        let out_transactions = transactions
            .into_iter()
            .map(FrbTransactionDetails::from)
            .collect();

        Ok(out_transactions)
    }

    pub async fn get_transaction(
        &self,
        account_key: &FrbDerivationPath,
        txid: String,
    ) -> Result<FrbTransactionDetails, BridgeError> {
        let transaction = self
            .inner
            .get_transaction(&account_key.clone_inner(), txid)
            .await?;

        Ok(transaction.into())
    }

    #[frb(sync)]
    pub fn get_fingerprint(&self) -> String {
        self.inner.get_fingerprint()
    }
}

#[cfg(test)]
mod test {
    use super::FrbWallet;
    use crate::api::{
        api_service::{
            proton_api_service::ProtonAPIService, wallet_auth_store::ProtonWalletAuthStore,
        },
        bdk_wallet::{
            account_syncer::FrbAccountSyncer, blockchain::FrbBlockchainClient,
            storage::WalletMobilePersisterFactory,
        },
    };
    use crate::mocks::constant::tests::{TEST_MNEMONIC_1, TEST_MNEMONIC_2};
    use andromeda_bitcoin::TransactionFilter;
    use andromeda_common::{Network, ScriptType};
    use std::time::Instant;
    use std::{env, sync::Arc};
    #[tokio::test]
    #[ignore]
    async fn test_wallet_import_sync() {
        tracing_subscriber::fmt::init();
        env::set_var("RUST_LOG", "debug");

        let storage_factory = WalletMobilePersisterFactory::new(".".to_string());
        let network = Network::Testnet;
        let bip39_mnemonic = TEST_MNEMONIC_1.to_string();

        let mut frb_wallet = FrbWallet::new(network, bip39_mnemonic, None).unwrap();

        let fingerprint = frb_wallet.get_fingerprint();
        println!("fingerprint: {}", fingerprint);
        assert!(!fingerprint.is_empty());

        let external_path = "m/84'/1'/0'".to_string();
        let frb_account = frb_wallet
            .add_account(
                ScriptType::NativeSegwit,
                external_path.clone(),
                storage_factory,
            )
            .unwrap();
        let path = frb_account.get_derivation_path().unwrap();
        assert!(external_path.contains(&path));
        println!("path: {}", path);

        let app_version = "android-wallet@1.0.0.72".to_string();
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let store = ProtonWalletAuthStore::new("atlas").unwrap();
        let api_service = Arc::new(
            ProtonAPIService::new("atlas".to_string(), app_version, user_agent, store).unwrap(),
        );
        let _ = api_service
            .login("pro".to_string(), "pro".to_string())
            .await;

        let balance = frb_account.get_balance().await.total();
        println!("balance: {}", balance.to_btc());
        let block_client = FrbBlockchainClient::new(&api_service);
        let wallet_sync = FrbAccountSyncer::new(&block_client, &frb_account);

        let result = wallet_sync.should_sync().await.unwrap();
        println!("should sync: {}", result);

        if result {
            let now = Instant::now();
            println!("start syncing");
            wallet_sync.full_sync(Some(20)).await.unwrap();

            let elapsed = now.elapsed();
            println!("sync end: {:.2?}", elapsed);
            let balance = frb_account.get_balance().await.total();
            println!("balance: {}", balance.to_btc());
        }

        let now = Instant::now();
        println!("start partial syncing");
        wallet_sync.partial_sync().await.unwrap();
        let elapsed = now.elapsed();
        println!("sync end: {:.2?}", elapsed);
        let balance = frb_account.get_balance().await;
        println!("\nBALANCE");
        println!("confirmed: {}", balance.inner.confirmed);
        println!("trusted_spendable: {}", balance.inner.trusted_spendable());
        println!("trusted_pending: {}", balance.inner.trusted_pending);
        println!("untrusted_pending: {}", balance.inner.untrusted_pending);
        println!("balance: {}", balance.total().to_btc());

        let address1 = frb_account.get_address(Some(0)).await.unwrap();
        let address2 = frb_account.get_address(Some(1)).await.unwrap();
        let address3 = frb_account.get_address(Some(2)).await.unwrap();
        let address4 = frb_account.get_address(Some(3)).await.unwrap();
        let address5 = frb_account.get_address(Some(4)).await.unwrap();
        assert_ne!(address1, address2);
        assert_ne!(address2, address3);
        assert_ne!(address3, address4);
        assert_ne!(address4, address5);

        let now = Instant::now();
        println!("start partial syncing");
        wallet_sync.partial_sync().await.unwrap();
        let elapsed = now.elapsed();
        println!("sync end: {:.2?}", elapsed);
        let balance = frb_account.get_balance().await.total();
        println!("balance: {}", balance.to_btc());

        let trans = frb_account
            .get_transactions(None, TransactionFilter::All)
            .await
            .unwrap();

        let mut builder = frb_account.build_tx().await.unwrap();
        builder = builder.add_recipient(
            Some("bc1q5x4vux7ts33kdukga7lqr7t4rf5ys0ctzlp6qn".to_string()),
            Some(1400),
        );

        let _ = builder
            .create_draft_psbt(network, Some(false))
            .await
            .unwrap();

        assert!(!trans.is_empty());
    }

    #[tokio::test]
    #[ignore]
    async fn test_wallet_sync_fail() {
        tracing_subscriber::fmt::init();
        env::set_var("RUST_LOG", "debug");

        let storage_factory = WalletMobilePersisterFactory::new(".".to_string());
        let network = Network::Bitcoin;
        let bip39_mnemonic = TEST_MNEMONIC_2.to_string();

        let mut frb_wallet = FrbWallet::new(network, bip39_mnemonic, None).unwrap();

        let fingerprint = frb_wallet.get_fingerprint();
        println!("fingerprint: {}", fingerprint);
        assert!(!fingerprint.is_empty());

        let external_path = "m/84'/0'/1'".to_string();
        let frb_account = frb_wallet
            .add_account(
                ScriptType::NativeSegwit,
                external_path.clone(),
                storage_factory,
            )
            .unwrap();
        let path = frb_account.get_derivation_path().unwrap();
        assert!(external_path.contains(&path));
        println!("path: {}", path);

        let app_version = "android-wallet@1.0.0.77-dev".to_string();
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let store = ProtonWalletAuthStore::new("prod").unwrap();
        let api_service = Arc::new(
            ProtonAPIService::new("prod".to_string(), app_version, user_agent, store).unwrap(),
        );
        let _ = api_service
            .login("feng200".to_string(), "12345678".to_string())
            .await;

        let balance = frb_account.get_balance().await.total();
        println!("balance: {}", balance.to_btc());
        let block_client = FrbBlockchainClient::new(&api_service);
        let wallet_sync = FrbAccountSyncer::new(&block_client, &frb_account);

        let result = wallet_sync.should_sync().await.unwrap();
        println!("should sync: {}", result);

        if result {
            let now = Instant::now();
            println!("start syncing");
            wallet_sync.full_sync(Some(20)).await.unwrap();

            let elapsed = now.elapsed();
            println!("sync end: {:.2?}", elapsed);
            let balance = frb_account.get_balance().await.total();
            println!("balance: {}", balance.to_btc());
        }

        let now = Instant::now();
        println!("start partial syncing");
        wallet_sync.partial_sync().await.unwrap();
        let elapsed = now.elapsed();
        println!("sync end: {:.2?}", elapsed);
        let balance = frb_account.get_balance().await;
        println!("\nBALANCE");
        println!("confirmed: {}", balance.inner.confirmed);
        println!("trusted_spendable: {}", balance.inner.trusted_spendable());
        println!("trusted_pending: {}", balance.inner.trusted_pending);
        println!("untrusted_pending: {}", balance.inner.untrusted_pending);
        println!("balance: {}", balance.total().to_btc());

        let transactions = frb_account
            .get_transactions(None, TransactionFilter::All)
            .await
            .unwrap();
        assert!(!transactions.is_empty());

        let address1 = frb_account.get_address(Some(0)).await.unwrap();
        let address2 = frb_account.get_address(Some(1)).await.unwrap();
        let address3 = frb_account.get_address(Some(2)).await.unwrap();
        let address4 = frb_account.get_address(Some(3)).await.unwrap();
        let address5 = frb_account.get_address(Some(4)).await.unwrap();
        assert_ne!(address1, address2);
        assert_ne!(address2, address3);
        assert_ne!(address3, address4);
        assert_ne!(address4, address5);

        let now = Instant::now();
        println!("start partial syncing");
        wallet_sync.partial_sync().await.unwrap();
        let elapsed = now.elapsed();
        println!("sync end: {:.2?}", elapsed);
        let balance = frb_account.get_balance().await.total();
        println!("balance: {}", balance.to_btc());

        let trans = frb_account
            .get_transactions(None, TransactionFilter::All)
            .await
            .unwrap();
        assert!(!trans.is_empty());

        let mut tx_builder = frb_account.build_tx().await.unwrap();

        tx_builder = tx_builder.add_recipient(
            Some("bc1qjr76689vkjgtjvqvupexlh4jkht55u95h5zmy2".to_string()),
            Some(5000),
        );
        tx_builder = tx_builder.set_fee_rate(2).await;
        let frb_psbt = tx_builder.create_draft_psbt(network, None).await.unwrap();
        let fee = frb_psbt.fee().unwrap().to_sat();
        println!("fee: {}", fee);

        let mut frb_psbt = tx_builder.create_pbst(network).await.unwrap();
        let fee = frb_psbt.fee().unwrap().to_sat();
        println!("fee: {}", fee);

        frb_psbt = frb_account.sign(&mut frb_psbt, network).await.unwrap();
        // frb_psbt = frb_account.sign(network).await.unwrap();
        // block_client.broadcast(&frb_psbt).await.unwrap();
        print!("{:?}", frb_psbt.fee());
    }
}
