// transactions.rs
use andromeda_bitcoin::Transaction as BdkTransaction;
use flutter_rust_bridge::frb;

use crate::BridgeError;

#[derive(Clone, PartialEq, Eq, Debug, Hash)]
pub struct FrbTransaction {
    pub(crate) inner: BdkTransaction,
}

impl FrbTransaction {
    pub(crate) fn clone_inner(&self) -> BdkTransaction {
        self.inner.clone()
    }
}

impl From<BdkTransaction> for FrbTransaction {
    fn from(value: BdkTransaction) -> Self {
        FrbTransaction { inner: value }
    }
}

impl From<String> for FrbTransaction {
    fn from(tx: String) -> Self {
        let tx_: BdkTransaction = serde_json::from_str(&tx).expect("Invalid Transaction");
        FrbTransaction { inner: tx_ }
    }
}
impl From<FrbTransaction> for String {
    fn from(tx: FrbTransaction) -> Self {
        match serde_json::to_string(&tx.inner) {
            Ok(e) => e,
            Err(e) => panic!("Unable to deserialize the Tranaction {:?}", e),
        }
    }
}

impl FrbTransaction {
    #[frb(sync)]
    pub fn new(transaction_bytes: Vec<u8>) -> Result<Self, BridgeError> {
        let tx: BdkTransaction = serde_json::from_slice(&transaction_bytes.as_slice())?;
        Ok(FrbTransaction { inner: tx })
    }

    pub fn compute_txid(&self) -> String {
        self.inner.compute_txid().to_string()
    }
}
