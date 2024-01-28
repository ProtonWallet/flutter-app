use muon::session::Session;

use super::types::ResponseCode;

struct Block {
    pub(crate) id: String,
    pub(crate) block_height: u64,
    pub(crate) version: u64,
    pub(crate) timestamp: u64,
    pub(crate) tx_count: u64,
    pub(crate) size: u64,
    pub(crate) weight: u64,
    pub(crate) merkle_root: String,
    pub(crate) previous_block_hash: String,
    pub(crate) median_time: u64,
    pub(crate) nonce: u64,
    pub(crate) bits: u64,
    pub(crate) difficulty: u64,
}

struct BLockList {
    pub code: i64,
    pub(crate) blocks: Vec<Block>,
}

struct BlockClient {
    pub(crate) session: Session,
}
pub(crate) trait BlockRoute {
    async fn get_blocks(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    
}
