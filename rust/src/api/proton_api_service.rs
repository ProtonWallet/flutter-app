use crate::proton_api::{errors::ApiError, wallet::WalletData};

// experimental this way look better but need to test out
pub struct ProtonAPIService {
    pub api: andromeda_api::ProtonWalletApiClient,
}

impl Default for ProtonAPIService {
    fn default() -> Self {
        Self::new()
    }
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
        let response = api.login(&user_name, &password).await;
        match response {
            Ok(_) => {
                // store the api service in the global state
                // store the user_name and password in the global state
            }
            Err(err) => {
                println!("Error: {:?}", err);
            }
        }
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
