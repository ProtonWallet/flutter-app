use crate::psbt::Transaction;
use crate::types::Network;
use bdk::blockchain::esplora::EsploraBlockchainConfig;
use bdk::blockchain::rpc::Auth as BdkAuth;
use bdk::blockchain::rpc::RpcConfig as BdkRpcConfig;
use bdk::blockchain::Blockchain as BdkBlockchain;
use bdk::blockchain::{
    AnyBlockchain, AnyBlockchainConfig, ConfigurableBlockchain, ElectrumBlockchainConfig,
    GetBlockHash, GetHeight,
};
use bdk::{Error as BdkError, FeeRate};
use lazy_static::lazy_static;
use std::collections::HashMap;
use std::path::PathBuf;
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

impl Blockchain {
    pub fn new(blockchain_config: BlockchainConfig) -> Result<String, BdkError> {
        let any_blockchain_config = match blockchain_config {
            BlockchainConfig::Electrum { config } => {
                AnyBlockchainConfig::Electrum(ElectrumBlockchainConfig {
                    retry: config.retry,
                    socks5: config.socks5,
                    timeout: config.timeout,
                    url: config.url,
                    stop_gap: usize::try_from(config.stop_gap).unwrap(),
                    validate_domain: config.validate_domain,
                })
            }
            BlockchainConfig::Esplora { config } => {
                AnyBlockchainConfig::Esplora(EsploraBlockchainConfig {
                    base_url: config.base_url,
                    proxy: config.proxy,
                    concurrency: config.concurrency,
                    stop_gap: usize::try_from(config.stop_gap).unwrap(),
                    timeout: config.timeout,
                })
            }
            BlockchainConfig::Rpc { config } => {
                let rpc_auth = if let Some(file) = config.auth_cookie {
                    bdk::blockchain::rpc::Auth::Cookie {
                        file: PathBuf::from(file),
                    }
                } else if let Some(user_pass) = config.auth_user_pass {
                    bdk::blockchain::rpc::Auth::UserPass {
                        username: user_pass.username,
                        password: user_pass.password,
                    }
                } else {
                    bdk::blockchain::rpc::Auth::None
                };
                AnyBlockchainConfig::Rpc(BdkRpcConfig {
                    url: config.url,
                    // auth: config.auth.into(),
                    auth: rpc_auth,
                    network: config.network.into(),
                    wallet_name: config.wallet_name,
                    sync_params: config.sync_params.map(|p| p.into()),
                })
            }
        };
        let blockchain = AnyBlockchain::from_config(&any_blockchain_config)?;
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
pub enum Auth {
    None,
    /// Authentication with username and password, usually [Auth::Cookie] should be preferred
    UserPass {
        /// Username
        username: String,
        /// Password
        password: String,
    },
    /// Authentication with a cookie file
    Cookie {
        /// Cookie file
        file: String,
    },
}
impl From<Auth> for BdkAuth {
    fn from(auth: Auth) -> Self {
        match auth {
            Auth::None => BdkAuth::None,
            Auth::UserPass { username, password } => BdkAuth::UserPass { username, password },
            Auth::Cookie { file } => BdkAuth::Cookie {
                file: PathBuf::from(file),
            },
        }
    }
}

/// Sync parameters for Bitcoin Core RPC.
///
/// In general, BDK tries to sync `scriptPubKey`s cached in `Database` with
/// `scriptPubKey`s imported in the Bitcoin Core Wallet. These parameters are used for determining
/// how the `importdescriptors` RPC calls are to be made.
///
#[derive(Clone, Default)]
pub struct RpcSyncParams {
    /// The minimum number of scripts to scan for on initial sync.
    pub start_script_count: u64,
    /// Time in unix seconds in which initial sync will start scanning from (0 to start from genesis).
    pub start_time: u64,
    /// Forces every sync to use `start_time` as import timestamp.
    pub force_start_time: bool,
    /// RPC poll rate (in seconds) to get state updates.
    pub poll_rate_sec: u64,
}
impl From<RpcSyncParams> for bdk::blockchain::rpc::RpcSyncParams {
    fn from(params: RpcSyncParams) -> Self {
        bdk::blockchain::rpc::RpcSyncParams {
            start_script_count: params.start_script_count as usize,
            start_time: params.start_time,
            force_start_time: params.force_start_time,
            poll_rate_sec: params.poll_rate_sec,
        }
    }
}
/// RpcBlockchain configuration options
///
pub struct UserPass {
    /// Username
    pub username: String,
    /// Password
    pub password: String,
}
pub struct RpcConfig {
    /// The bitcoin node url
    pub url: String,
    /// The bitcoin node authentication mechanism
    pub auth_cookie: Option<String>,
    pub auth_user_pass: Option<UserPass>,
    /// The network we are using (it will be checked the bitcoin node network matches this)
    pub network: Network,
    /// The wallet name in the bitcoin node
    pub wallet_name: String,
    /// Sync parameters
    pub sync_params: Option<RpcSyncParams>,
}
/// Configuration for an ElectrumBlockchain
pub struct ElectrumConfig {
    ///URL of the Electrum server (such as ElectrumX, Esplora, BWT) may start with ssl:// or tcp:// and include a port
    ///eg. ssl://electrum.blockstream.info:60002
    pub url: String,
    ///URL of the socks5 proxy server or a Tor service
    pub socks5: Option<String>,
    ///Request retry count
    pub retry: u8,
    ///Request timeout (seconds)
    pub timeout: Option<u8>,
    ///Stop searching addresses for transactions after finding an unused gap of this length
    pub stop_gap: u64,
    /// Validate the domain when using SSL
    pub validate_domain: bool,
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
    /// Electrum client
    Electrum { config: ElectrumConfig },
    /// Esplora client
    Esplora { config: EsploraConfig },
    /// Bitcoin Core RPC client
    Rpc { config: RpcConfig },
}
