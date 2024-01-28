use super::types::ResponseCode;

pub(crate) trait WalletAccountRoute {
    async fn get_walelts(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn create_wallet(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}
