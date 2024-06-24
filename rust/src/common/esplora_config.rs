// esplora_config.rs

///Configuration for an EsploraBlockchain
pub struct EsploraConfig {
    // pub base_url: String,
    // pub proxy: Option<String>,
    ///Number of parallel requests sent to the esplora service (default: 4)
    pub concurrency: Option<u8>,
    ///Stop searching addresses for transactions after finding an unused gap of this length.
    pub stop_gap: u64,
    ///Socket timeout.
    pub timeout: Option<u64>,
}
