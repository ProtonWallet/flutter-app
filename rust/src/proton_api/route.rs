use super::api_service::ProtonAPIService;

pub static PROTON_WALLET_API_VERSION: &str = "v1";
    
pub static PROTON_AUTH_API_VERSION: &str = "v4";

pub trait RoutePath {
    fn get_wallet_path(&self) -> String;
    fn get_auth_path(&self) -> String;
}

impl RoutePath for ProtonAPIService {
    fn get_wallet_path(&self) -> String {
        format!("{}{}", "/wallet/", PROTON_WALLET_API_VERSION)
    }
    fn get_auth_path(&self) -> String {
        format!("{}{}", "/auth/", PROTON_AUTH_API_VERSION)
    }
}