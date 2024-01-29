use muon::{request::{JsonRequest, Response}, session::{RequestExt}};
use serde::Deserialize;

use super::{api_service::ProtonAPIService, route::RoutePath};

#[derive(Debug, Clone, Deserialize)]
pub struct Block {
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

#[derive(Debug, Clone, Deserialize)]
pub struct BLockList {
    pub code: i64,
    pub(crate) blocks: Vec<Block>,
}

pub(crate) trait BlockRoute {
    // Get block summaries starting at the tip or at height
    async fn get_blocks(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get block summaries starting at the tip or at height
    async fn get_blocks_height(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get block header of a block hash
    async fn get_block_header(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get block hash of a block height
    async fn get_block_hash(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get block status
    async fn get_block_status(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get block by hash
    async fn get_block_by_hash(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get TransactionId at block index
    async fn get_transaction_id(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get the height of the last block
    async fn get_last_block_height(self) -> Result<BLockList, Box<dyn std::error::Error>>;
    // Get the hash of the last block
    async fn get_last_block_hash(self) -> Result<BLockList, Box<dyn std::error::Error>>;
}


impl BlockRoute for ProtonAPIService {
    async fn get_blocks(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        let path = format!("{}{}", self.get_wallet_path(), "/blocks");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_blocks_height(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        let path = format!("{}{}", self.get_wallet_path(), "/blocks/{height}");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_block_header(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        let path = format!("{}{}", self.get_wallet_path(), "/blocks/{blockHash}/header");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_block_hash(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        // https://proton.black/api/wallet/{_version}/blocks/height/{blockHeight}/hash
        let path = format!("{}{}", self.get_wallet_path(), "blocks/height/{blockHeight}/hash");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_block_status(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        // https://proton.black/api/wallet/{_version}/blocks/{blockHash}/status
        let path = format!("{}{}", self.get_wallet_path(), "blocks/{blockHash}/status");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_block_by_hash(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        // https://proton.black/api/wallet/{_version}/blocks/{blockHash}/raw
        let path = format!("{}{}", self.get_wallet_path(), "blocks/{blockHash}/raw");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_transaction_id(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        // https://proton.black/api/wallet/{_version}/blocks/{blockHash}/txid/{txIndex}
        let path = format!("{}{}", self.get_wallet_path(), "blocks/{blockHash}/txid/{txIndex}");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_last_block_height(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        // https://proton.black/api/wallet/{_version}/blocks/tip/height
        let path = format!("{}{}", self.get_wallet_path(), "blocks/tip/height");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_last_block_hash(self) -> Result<BLockList, Box<dyn std::error::Error>> {
        // https://proton.black/api/wallet/{_version}/blocks/tip/hash
        let path = format!("{}{}", self.get_wallet_path(), "blocks/tip/hash");
        let res: BLockList = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }


}

// #[cfg(test)]
// mod test {
//     use crate::proton_api::{api_service::ProtonAPIService, network_routes::NetworkRoute};

//     #[tokio::test]
//     async fn test_ping_ok() {
//         let api_service = ProtonAPIService::default();
//         let result = api_service.ping().await;
//         assert!(result.is_ok());
//         assert_eq!(result.unwrap(), 200);
//     }
//     #[tokio::test]
//     async fn test_ping_object_ok() {
//         let api_service = ProtonAPIService::default();
//         let result = api_service.ping_object().await;
//         assert!(result.is_ok());
//         assert_eq!(result.unwrap().code, 1000);
//     }

//     #[tokio::test]
//     async fn test_get_network_ok() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("feng100", "12345678").await.unwrap();

//         let result = api_service.get_network_type().await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let auth_response = result.unwrap();
//         assert_eq!(auth_response.Code, 1000);
//         assert_eq!(auth_response.Network, 1);
//     }

//     #[tokio::test]
//     #[should_panic] //session issue
//     async fn test_get_network_401() {
//         let api_service = ProtonAPIService::default();
//         api_service.get_network_type().await.unwrap();
//     }
// }
