use crate::proton_api::{errors::ApiError, wallet::WalletData};

// experimental this way look better but need to test out
pub struct ProtonAPIService {
    pub api: andromeda_api::ProtonWalletApiClient,
}

impl ProtonAPIService {
    pub fn new() -> ProtonAPIService {
        ProtonAPIService {
            api: andromeda_api::ProtonWalletApiClient::default(),
        }
    }

    // build functions
    pub async fn init_api_service(user_name: String, password: String) {
        // create a global proton api service
        let mut api = andromeda_api::ProtonWalletApiClient::default();
        api.login(&user_name, &password).await.unwrap();
    }

    pub fn read_text(&self) -> String {
        // self.dir.test()
        "Hello World".to_string()
    }

    pub async fn get_wallets(&self) -> Result<Vec<WalletData>, ApiError> {
        let result = self.api.wallet.get_wallets().await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|w| w.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }
}
