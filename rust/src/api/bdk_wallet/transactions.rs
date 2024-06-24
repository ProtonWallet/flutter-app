// transactions.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::Transaction as BdkTransaction;

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

    // pub fn txid(&self) -> String {
    //     self.internal.txid().to_string()
    // }

    // pub fn weight(&self) -> u64 {
    //     self.internal.weight().to_wu()
    // }

    // pub fn size(&self) -> u64 {
    //     self.internal.size() as u64
    // }

    // pub fn vsize(&self) -> u64 {
    //     self.internal.vsize() as u64
    // }

    // pub fn serialize(&self) -> Vec<u8> {
    //     serialize(&self.internal)
    // }

    // pub fn is_coin_base(&self) -> bool {
    //     self.internal.is_coin_base()
    // }

    // pub fn is_explicitly_rbf(&self) -> bool {
    //     self.internal.is_explicitly_rbf()
    // }

    // pub fn is_lock_time_enabled(&self) -> bool {
    //     self.internal.is_lock_time_enabled()
    // }

    // pub fn version(&self) -> i32 {
    //     self.internal.version
    // }

    // pub fn lock_time(&self) -> u32 {
    //     self.internal.lock_time.to_consensus_u32()
    // }

    // pub fn input(&self) -> Vec<TxIn> {
    //     self.internal.input.iter().map(|x| x.into()).collect()
    // }

    // pub fn output(&self) -> Vec<TxOut> {
    //     self.internal.output.iter().map(|x| x.into()).collect()
    // }
}
