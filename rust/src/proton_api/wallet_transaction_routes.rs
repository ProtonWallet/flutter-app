use super::types::ResponseCode;

pub(crate) trait WalletTransactionRoute {
    async fn get_transactions(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn create_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn update_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn delete_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;

}