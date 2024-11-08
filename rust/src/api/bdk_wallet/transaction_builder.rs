// transaction_builder.rs
use andromeda_bitcoin::{
    transaction_builder::{CoinSelection, TxBuilder},
    ChangeSpendPolicy,
};
use andromeda_common::Network;
use flutter_rust_bridge::frb;

use super::{account::FrbAccount, local_output::FrbOutPoint, psbt::FrbPsbt};
use crate::proton_bdk::storage::{WalletMobileConnector, WalletMobilePersister};
use crate::BridgeError;

#[derive(Debug)]
pub struct FrbTxBuilder {
    pub(crate) inner: TxBuilder<WalletMobileConnector, WalletMobilePersister>,
}

impl From<TxBuilder<WalletMobileConnector, WalletMobilePersister>> for FrbTxBuilder {
    fn from(inner: TxBuilder<WalletMobileConnector, WalletMobilePersister>) -> Self {
        FrbTxBuilder { inner }
    }
}

pub struct FrbRecipient(pub String, pub String, pub u64);

impl FrbTxBuilder {
    #[frb(sync)]
    pub fn new() -> FrbTxBuilder {
        FrbTxBuilder {
            inner: TxBuilder::new(),
        }
    }

    pub async fn set_account(&self, account: &FrbAccount) -> Result<FrbTxBuilder, BridgeError> {
        Ok(self.inner.set_account(account.get_inner()).into())
    }

    #[frb(sync)]
    pub fn clear_recipients(&self) -> FrbTxBuilder {
        let inner = self.inner.clear_recipients();
        inner.into()
    }

    #[frb(sync)]
    pub fn add_recipient(&self, address_str: Option<String>, amount: Option<u64>) -> FrbTxBuilder {
        let inner = self.inner.add_recipient(Some((address_str, amount)));
        inner.into()
    }

    #[frb(sync)]
    pub fn remove_recipient(&self, index: usize) -> FrbTxBuilder {
        let inner = self.inner.remove_recipient(index);
        inner.into()
    }

    pub async fn update_recipient(
        &self,
        index: usize,
        address_str: Option<String>,
        amount: Option<u64>,
    ) -> Result<FrbTxBuilder, BridgeError> {
        let inner = self.inner.update_recipient(index, (address_str, amount));

        Ok(inner.into())
    }

    pub async fn update_recipient_amount_to_max(
        &self,
        index: usize,
    ) -> Result<FrbTxBuilder, BridgeError> {
        let inner = self.inner.update_recipient_amount_to_max(index).await;

        Ok(inner.into())
    }

    pub async fn constrain_recipient_amounts(&mut self) -> Result<FrbTxBuilder, BridgeError> {
        let inner = self.inner.constrain_recipient_amounts().await;

        Ok(inner.into())
    }

    #[frb(sync)]
    pub fn clear_utxos_to_spend(&self) -> FrbTxBuilder {
        let inner = self.inner.clear_utxos_to_spend();
        FrbTxBuilder { inner }
    }

    #[frb(sync)]
    pub fn get_utxos_to_spend(&self) -> Vec<FrbOutPoint> {
        self.inner
            .utxos_to_spend
            .clone()
            .into_iter()
            .map(|outpoint| {
                let utxo: FrbOutPoint = outpoint.into();
                utxo
            })
            .collect()
    }

    /**
     * Coin selection enforcement
     */

    #[frb(sync)]
    pub fn set_coin_selection(&self, coin_selection: CoinSelection) -> Self {
        let inner = self.inner.set_coin_selection(coin_selection.into());
        FrbTxBuilder { inner }
    }
    #[frb(sync)]
    pub fn get_coin_selection(&self) -> CoinSelection {
        self.inner.coin_selection.clone().into()
    }

    /**
     * RBF
     */
    #[frb(sync)]
    pub fn enable_rbf(&self) -> FrbTxBuilder {
        let inner = self.inner.enable_rbf();
        FrbTxBuilder { inner }
    }

    #[frb(sync)]
    pub fn disable_rbf(&self) -> FrbTxBuilder {
        let inner = self.inner.disable_rbf();
        FrbTxBuilder { inner }
    }

    #[frb(sync)]
    pub fn get_rbf_enabled(&self) -> bool {
        self.inner.rbf_enabled
    }

    /**
     * Change policy
     */

    #[frb(sync)]
    pub fn set_change_policy(&self, change_policy: ChangeSpendPolicy) -> Self {
        let inner = self.inner.set_change_policy(change_policy);
        FrbTxBuilder { inner }
    }

    #[frb(sync)]
    pub fn get_change_policy(&self) -> ChangeSpendPolicy {
        self.inner.change_policy.into()
    }

    /**
     * Fees
     */

    pub async fn set_fee_rate(&self, sat_per_vb: u64) -> Self {
        let inner = self.inner.set_fee_rate(sat_per_vb);
        FrbTxBuilder { inner }
    }

    #[frb(sync)]
    pub fn get_fee_rate(&self) -> Option<u64> {
        if let Some(fee_rate) = self.inner.fee_rate {
            Some(fee_rate.to_sat_per_vb_ceil())
        } else {
            None
        }
    }

    /**
     * Locktime
     */

    // pub fn add_locktime(&self, locktime: LockTime) -> Self {
    //     let inner = self.inner.add_locktime(locktime.into());
    //     Self { inner }
    // }

    #[frb(sync)]
    pub fn remove_locktime(&self) -> Self {
        let inner = self.inner.remove_locktime();
        Self { inner }
    }

    // pub fn get_locktime(&self) -> Option<LockTime> {
    //     self.inner.locktime.map(|l| l.into())
    // }

    /**
     * Final
     */

    pub async fn create_pbst(&mut self, network: Network) -> Result<FrbPsbt, BridgeError> {
        let psbt = self.inner.create_psbt(false, false).await?;

        FrbPsbt::from_psbt(&psbt, network)
    }

    pub async fn create_draft_psbt(
        &mut self,
        network: Network,
        allow_dust: Option<bool>,
    ) -> Result<FrbPsbt, BridgeError> {
        let psbt = self
            .inner
            .create_draft_psbt(allow_dust.unwrap_or(false))
            .await?;
        FrbPsbt::from_psbt(&psbt, network)
    }
}
