use std::sync::Arc;

use andromeda_api::{
    core::ApiClient,
    settings::FiatCurrencySymbol as FiatCurrency,
    wallet::{
        ApiEmailAddress, ApiWallet, ApiWalletAccount, ApiWalletData, ApiWalletSettings,
        CreateWalletTransactionRequestBody, WalletTransactionFlag,
    },
};

use crate::{
    wallet::{CreateWalletReq, WalletTransaction},
    wallet_account::CreateWalletAccountReq,
    BridgeError,
};

use super::proton_api_service::ProtonAPIService;

pub struct WalletClient {
    pub(crate) inner: Arc<andromeda_api::wallet::WalletClient>,
}

impl WalletClient {
    pub fn new(service: &ProtonAPIService) -> WalletClient {
        WalletClient {
            inner: Arc::new(andromeda_api::wallet::WalletClient::new(
                service.inner.clone(),
            )),
        }
    }

    // wallets
    pub async fn get_wallets(&self) -> Result<Vec<ApiWalletData>, BridgeError> {
        let result: Result<Vec<andromeda_api::wallet::ApiWalletData>, andromeda_api::error::Error> =
            self.inner.get_wallets().await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn create_wallet(
        &self,
        wallet_req: CreateWalletReq,
    ) -> Result<ApiWalletData, BridgeError> {
        let result = self.inner.create_wallet(wallet_req.into()).await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_wallet_name(
        &self,
        wallet_id: String,
        new_name: String,
    ) -> Result<ApiWallet, BridgeError> {
        let result = self.inner.update_wallet_name(wallet_id, new_name).await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn delete_wallet(&self, wallet_id: String) -> Result<(), BridgeError> {
        let result = self.inner.delete_wallet(wallet_id).await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    // wallet accounts
    pub async fn get_wallet_accounts(
        &self,
        wallet_id: String,
    ) -> Result<Vec<ApiWalletAccount>, BridgeError> {
        let result = self.inner.get_wallet_accounts(wallet_id).await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn get_wallet_account_addresses(
        &self,
        wallet_id: String,
        wallet_account_id: String,
    ) -> Result<Vec<ApiEmailAddress>, BridgeError> {
        let result = self
            .inner
            .get_wallet_account_addresses(wallet_id, wallet_account_id)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn create_wallet_account(
        &self,
        wallet_id: String,
        req: CreateWalletAccountReq,
    ) -> Result<ApiWalletAccount, BridgeError> {
        let result = self
            .inner
            .create_wallet_account(wallet_id, req.into())
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_wallet_account_label(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        new_label: String,
    ) -> Result<ApiWalletAccount, BridgeError> {
        let result = self
            .inner
            .update_wallet_account_label(wallet_id, wallet_account_id, new_label)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_wallet_accounts_order(
        &self,
        wallet_id: String,
        wallet_account_ids: Vec<String>,
    ) -> Result<Vec<ApiWalletAccount>, BridgeError> {
        let result = self
            .inner
            .update_wallet_accounts_order(wallet_id, wallet_account_ids)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_wallet_account_last_used_index(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        last_used_index: u32,
    ) -> Result<ApiWalletAccount, BridgeError> {
        let result = self
            .inner
            .update_wallet_account_last_used_index(wallet_id, wallet_account_id, last_used_index)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_wallet_account_fiat_currency(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        new_fiat_currency: FiatCurrency,
    ) -> Result<ApiWalletAccount, BridgeError> {
        let result = self
            .inner
            .update_wallet_account_fiat_currency(wallet_id, wallet_account_id, new_fiat_currency)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn delete_wallet_account(
        &self,
        wallet_id: String,
        wallet_account_id: String,
    ) -> Result<(), BridgeError> {
        let result = self
            .inner
            .delete_wallet_account(wallet_id, wallet_account_id)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    /// wallet email related
    pub async fn add_email_address(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        address_id: String,
    ) -> Result<ApiWalletAccount, BridgeError> {
        let result = self
            .inner
            .add_email_address(wallet_id, wallet_account_id, address_id)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn remove_email_address(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        address_id: String,
    ) -> Result<ApiWalletAccount, BridgeError> {
        let result = self
            .inner
            .remove_email_address(wallet_id, wallet_account_id, address_id)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    /// Wallet transaction related

    pub async fn get_wallet_transactions(
        &self,
        wallet_id: String,
        wallet_account_id: Option<String>,
        hashed_txids: Option<Vec<String>>,
    ) -> Result<Vec<WalletTransaction>, BridgeError> {
        let result = self
            .inner
            .get_wallet_transactions(wallet_id, wallet_account_id, hashed_txids)
            .await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|v| v.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }

    #[allow(clippy::too_many_arguments)]
    pub async fn create_wallet_transactions(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        transaction_id: String,
        hashed_transaction_id: String,
        label: Option<String>,
        exchange_rate_id: Option<String>,
        transaction_time: Option<String>,
    ) -> Result<WalletTransaction, BridgeError> {
        let payload = CreateWalletTransactionRequestBody {
            TransactionID: transaction_id,
            HashedTransactionID: hashed_transaction_id,
            Label: label,
            ExchangeRateID: exchange_rate_id,
            TransactionTime: transaction_time,
        };
        let result = self
            .inner
            .create_wallet_transaction(wallet_id, wallet_account_id, payload)
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_wallet_transaction_label(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
        label: String,
    ) -> Result<WalletTransaction, BridgeError> {
        let result = self
            .inner
            .update_wallet_transaction_label(
                wallet_id,
                wallet_account_id,
                wallet_transaction_id,
                label,
            )
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn update_external_wallet_transaction_sender(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
        sender: String,
    ) -> Result<WalletTransaction, BridgeError> {
        let result = self
            .inner
            .update_external_wallet_transaction_sender(
                wallet_id,
                wallet_account_id,
                wallet_transaction_id,
                sender,
            )
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn set_wallet_transaction_private_flag(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
    ) -> Result<WalletTransaction, BridgeError> {
        let result = self
            .inner
            .set_wallet_transaction_flag(
                wallet_id,
                wallet_account_id,
                wallet_transaction_id,
                WalletTransactionFlag::Private,
            )
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn set_wallet_transaction_suspicious_flag(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
    ) -> Result<WalletTransaction, BridgeError> {
        let result = self
            .inner
            .set_wallet_transaction_flag(
                wallet_id,
                wallet_account_id,
                wallet_transaction_id,
                WalletTransactionFlag::Suspicious,
            )
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn delete_wallet_transaction_private_flag(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
    ) -> Result<WalletTransaction, BridgeError> {
        let result = self
            .inner
            .delete_wallet_transaction_flag(
                wallet_id,
                wallet_account_id,
                wallet_transaction_id,
                WalletTransactionFlag::Private,
            )
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn delete_wallet_transaction_suspicious_flag(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
    ) -> Result<WalletTransaction, BridgeError> {
        let result = self
            .inner
            .delete_wallet_transaction_flag(
                wallet_id,
                wallet_account_id,
                wallet_transaction_id,
                WalletTransactionFlag::Suspicious,
            )
            .await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn delete_wallet_transactions(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        wallet_transaction_id: String,
    ) -> Result<(), BridgeError> {
        let result = self
            .inner
            .delete_wallet_transactions(wallet_id, wallet_account_id, wallet_transaction_id)
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn disable_show_wallet_recovery(
        &self,
        wallet_id: String,
    ) -> Result<ApiWalletSettings, BridgeError> {
        let result = self.inner.disable_show_wallet_recovery(wallet_id).await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }
}
