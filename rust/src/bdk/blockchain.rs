use super::psbt::Transaction;
use andromeda_api::ProtonWalletApiClient;
use bdk::blockchain::esplora::EsploraBlockchain;
use bdk::blockchain::Blockchain as BdkBlockchain;
use bdk::blockchain::{AnyBlockchain, GetBlockHash, GetHeight};
use bdk::esplora_client::Builder;
use bdk::{Error as BdkError, FeeRate};
use esplora_client::AsyncClient;
use lazy_static::lazy_static;
use log::debug;
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use tokio::sync::{Mutex, MutexGuard};

lazy_static! {
    static ref BLOCKCHAIN: RwLock<HashMap<String, Arc<Blockchain>>> = RwLock::new(HashMap::new());
}

fn persist_blockchain(id: String, blockchain: Blockchain) {
    let mut blockchain_lock = BLOCKCHAIN.write().unwrap();
    blockchain_lock.insert(id, Arc::new(blockchain));
}

pub struct Blockchain {
    pub blockchain_mutex: Mutex<AnyBlockchain>,
}

impl Blockchain {
    /// Create a new EsploraBlockchain
    #[deprecated(since = "0.1.0", note = "Use the `new_blockchain_with_api` instead.")]
    pub fn new_blockchain(esplora_config: EsploraConfig) -> Result<String, BdkError> {
        let mut builder = Builder::new(esplora_config.base_url.as_str());
        if let Some(timeout) = esplora_config.timeout {
            builder = builder.timeout(timeout);
        }
        if let Some(proxy) = &esplora_config.proxy {
            builder = builder.proxy(proxy);
        }
        let mut esplora_blockchain = EsploraBlockchain::from_client(
            builder.build_async()?,
            usize::try_from(esplora_config.stop_gap).unwrap(),
        );

        if let Some(concurrency) = esplora_config.concurrency {
            esplora_blockchain = esplora_blockchain.with_concurrency(concurrency);
        }

        let blockchain = AnyBlockchain::Esplora(Box::new(esplora_blockchain));
        let id = rand::random::<char>().to_string();
        persist_blockchain(
            id.clone(),
            Blockchain {
                blockchain_mutex: Mutex::new(blockchain),
            },
        );
        Ok(id)
    }

    // Create a new EsploraBlockchain with an API client
    pub fn new_blockchain_with_api(
        esplora_config: EsploraConfig,
        api: Arc<ProtonWalletApiClient>,
    ) -> Result<String, BdkError> {
        debug!("Creating new blockchain with api");
        let async_client: AsyncClient = AsyncClient::from_client(esplora_config.base_url, api);
        let mut esplora_blockchain = EsploraBlockchain::from_client(
            async_client,
            usize::try_from(esplora_config.stop_gap).unwrap(),
        );
        if let Some(concurrency) = esplora_config.concurrency {
            esplora_blockchain = esplora_blockchain.with_concurrency(concurrency);
        }

        let blockchain = AnyBlockchain::Esplora(Box::new(esplora_blockchain));
        let id = rand::random::<char>().to_string();
        persist_blockchain(
            id.clone(),
            Blockchain {
                blockchain_mutex: Mutex::new(blockchain),
            },
        );
        Ok(id)
    }

    // retrieve a blockchain by id
    pub fn retrieve_blockchain(id: String) -> Arc<Blockchain> {
        let blockchain_lock = BLOCKCHAIN.read().unwrap();
        blockchain_lock.get(id.as_str()).unwrap().clone()
    }
    pub async fn get_blockchain(&self) -> MutexGuard<AnyBlockchain> {
        self.blockchain_mutex.lock().await
    }

    // broadcast a transaction
    pub(crate) async fn broadcast(&self, tx: Transaction) -> Result<String, BdkError> {
        let _ = self
            .get_blockchain()
            .await
            .broadcast(&tx.internal.clone())
            .await;
        Ok(tx.internal.txid().to_string())
    }

    pub async fn get_height(&self) -> Result<u32, BdkError> {
        self.get_blockchain().await.get_height().await
    }

    // get the fee rate
    pub async fn estimate_fee(&self, target: u64) -> Result<FeeRate, BdkError> {
        self.get_blockchain()
            .await
            .estimate_fee(target as usize)
            .await
    }
    pub async fn get_block_hash(&self, height: u32) -> Result<String, BdkError> {
        self.get_blockchain()
            .await
            .get_block_hash(u64::from(height))
            .await
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
