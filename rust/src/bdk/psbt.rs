use crate::bdk::types::{TxIn, TxOut};
use bdk::bitcoin::consensus::Decodable;
use bdk::bitcoin::psbt::PartiallySignedTransaction as BdkPartiallySignedTransaction;
use bdk::bitcoin::Transaction as BdkTransaction;
use bdk::psbt::PsbtUtils;
use bdk::{Error as BdkError, FeeRate};
use bitcoin::consensus::serialize;
use std::borrow::Borrow;
use std::io::Cursor;
use std::ops::Deref;
use std::str::FromStr;
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct PartiallySignedTransaction {
    pub internal: Mutex<BdkPartiallySignedTransaction>,
}

impl PartiallySignedTransaction {
    pub(crate) fn new(psbt_base64: String) -> Result<Self, BdkError> {
        let psbt: BdkPartiallySignedTransaction =
            BdkPartiallySignedTransaction::from_str(psbt_base64.borrow())?;
        Ok(PartiallySignedTransaction {
            internal: Mutex::new(psbt),
        })
    }

    pub(crate) async fn serialize(&self) -> String {
        let psbt = self.internal.lock().await.clone();
        psbt.to_string()
    }

    pub(crate) async fn txid(&self) -> String {
        let tx = self.internal.lock().await.clone().extract_tx();
        let txid = tx.txid();
        txid.to_string()
    }

    /// Return the transaction.
    pub(crate) async fn extract_tx(&self) -> Transaction {
        let tx = self.internal.lock().await.clone().extract_tx();
        Transaction { internal: tx }
    }

    /// Combines this PartiallySignedTransaction with other PSBT as described by BIP 174.
    ///
    /// In accordance with BIP 174 this function is commutative i.e., `A.combine(B) == B.combine(A)`
    pub(crate) async fn combine(
        &self,
        other: Arc<PartiallySignedTransaction>,
    ) -> Result<Arc<PartiallySignedTransaction>, BdkError> {
        let other_psbt = other.internal.lock().await.clone();
        let mut original_psbt = self.internal.lock().await.clone();

        original_psbt.combine(other_psbt)?;
        Ok(Arc::new(PartiallySignedTransaction {
            internal: Mutex::new(original_psbt),
        }))
    }

    /// The total transaction fee amount, sum of input amounts minus sum of output amounts, in Sats.
    /// If the PSBT is missing a TxOut for an input returns None.
    pub(crate) async fn fee_amount(&self) -> Option<u64> {
        self.internal.lock().await.fee_amount()
    }

    /// The transaction's fee rate. This value will only be accurate if calculated AFTER the
    /// `PartiallySignedTransaction` is finalized and all witness/signature data is added to the
    /// transaction.
    /// If the PSBT is missing a TxOut for an input returns None.
    pub(crate) async fn fee_rate(&self) -> Option<Arc<FeeRate>> {
        self.internal.lock().await.fee_rate().map(Arc::new)
    }

    /// Serialize the PSBT data structure as a String of JSON.
    pub(crate) async fn json_serialize(&self) -> String {
        let psbt = self.internal.lock().await;
        serde_json::to_string(psbt.deref()).unwrap()
    }
}
