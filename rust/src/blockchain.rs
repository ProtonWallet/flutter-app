use crate::psbt::Transaction;
use anyhow::Ok;
use bdk::blockchain::esplora::EsploraBlockchain;
use bdk::blockchain::Blockchain as BdkBlockchain;
use bdk::blockchain::{
    AnyBlockchain,
    GetBlockHash,
    GetHeight,
};
use bdk::esplora_client::Builder;
use bdk::{Error as BdkError, FeeRate};
use lazy_static::lazy_static;
use std::collections::HashMap;
use std::sync::RwLock;
use std::sync::{Arc, Mutex, MutexGuard};
lazy_static! {
    static ref BLOCKCHAIN: RwLock<HashMap<String, Arc<Blockchain>>> = RwLock::new(HashMap::new());
}
fn persist_blockchain(id: String, blockchain: Blockchain) {
    let mut blockchain_lock = BLOCKCHAIN.write().unwrap();
    blockchain_lock.insert(id, Arc::new(blockchain));
    return;
}
pub struct Blockchain {
    pub blockchain_mutex: Mutex<AnyBlockchain>,
}

impl From<EsploraConfig> for EsploraBlockchain {
    //ref: /bdk-0.28.2/src/blockchain/esplora/blocking.rs
    fn from(config: EsploraConfig) -> EsploraBlockchain {
        // here change to customized esplora client
        let mut builder = Builder::new(config.base_url.as_str());

        if let Some(timeout) = config.timeout {
            builder = builder.timeout(timeout);
        }

        if let Some(proxy) = &config.proxy {
            builder = builder.proxy(proxy);
        }

        let mut blockchain =
            EsploraBlockchain::from_client(builder.build_blocking()?, config.stop_gap);

        if let Some(concurrency) = config.concurrency {
            blockchain = blockchain.with_concurrency(concurrency);
        }
        
        Ok(blockchain);
    }
}

impl Blockchain {
    pub fn new(esplora_config: EsploraConfig) -> Result<String, BdkError> {
        // let blockchain = AnyBlockchain::from_config(&any_blockchain_config)?;
        let blockchain = AnyBlockchain::Esplora(Box::new(esplora_config?));
        let id = rand::random::<char>().to_string();
        persist_blockchain(
            id.clone(),
            Blockchain {
                blockchain_mutex: Mutex::new(blockchain),
            },
        );
        Ok(id)
    }

    pub fn retrieve_blockchain(id: String) -> Arc<Blockchain> {
        let blockchain_lock = BLOCKCHAIN.read().unwrap();
        blockchain_lock.get(id.as_str()).unwrap().clone()
    }
    pub fn get_blockchain(&self) -> MutexGuard<AnyBlockchain> {
        self.blockchain_mutex.lock().expect("blockchain")
    }

    pub(crate) fn broadcast(&self, tx: Transaction) -> Result<String, BdkError> {
        self.get_blockchain()
            .broadcast(&tx.internal.clone())
            .expect("Broadcast Error");
        return Ok(tx.internal.txid().to_string());
    }

    pub fn get_height(&self) -> Result<u32, BdkError> {
        self.get_blockchain().get_height()
    }
    pub fn estimate_fee(&self, target: u64) -> Result<Arc<FeeRate>, BdkError> {
        let result: Result<FeeRate, bdk::Error> =
            self.get_blockchain().estimate_fee(target as usize);
        result.map(Arc::new)
    }
    pub fn get_block_hash(&self, height: u32) -> Result<String, BdkError> {
        self.get_blockchain()
            .get_block_hash(u64::from(height))
            .map(|hash| hash.to_string())
    }
}

///Configuration for an EsploraBlockchain
pub struct EsploraConfig {
    ///Base URL of the esplora service
    ///eg. https://blockstream.info/api/
    pub base_url: String,
    ///  Optional URL of the proxy to use to make requests to the Esplora server
    /// The string should be formatted as: <protocol>://<user>:<password>@host:<port>.
    /// Note that the format of this value and the supported protocols change slightly between the sync version of esplora (using ureq) and the async version (using reqwest).
    ///  For more details check with the documentation of the two crates. Both of them are compiled with the socks feature enabled.
    /// The proxy is ignored when targeting wasm32.
    pub proxy: Option<String>,
    ///Number of parallel requests sent to the esplora service (default: 4)
    pub concurrency: Option<u8>,
    ///Stop searching addresses for transactions after finding an unused gap of this length.
    pub stop_gap: u64,
    ///Socket timeout.
    pub timeout: Option<u64>,
}
/// Type that can contain any of the blockchain configurations defined by the library.
pub enum BlockchainConfig {
    /// Esplora client
    Esplora { config: EsploraConfig },
}
