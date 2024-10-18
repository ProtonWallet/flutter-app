use std::sync::Arc;

use andromeda_api::{core::ApiClient, wallet::WalletClient, ProtonWalletApiClient};

use super::{db::app_database::AppDatabase, features::wallet::wallet_creation::WalletCreation};

// this is the main object that will be used to interact with the wallet and eatch proton account will only have one Proton Wallet object
// per app could have multiple Proton Wallet objects because we will support multiple users
pub(crate) struct ProtonWallet {
    api: Arc<ProtonWalletApiClient>,
    db: Arc<AppDatabase>,
}

impl ProtonWallet {
    // create a new wallet
    pub fn new(api: Arc<ProtonWalletApiClient>, db: Arc<AppDatabase>) -> ProtonWallet {
        ProtonWallet { api, db }
    }

    /// login will be used after get user sessions. The login module will be in a seperate module
    /// @param user_id: the user id of the user that is logging in
    /// @param session_store
    /// @param user_store
    /// @param db
    /// @param network
    /// etc ...
    pub fn login(user_id: String) -> ProtonWallet {
        todo!()
        // ProtonWallet {}
    }
}

impl ProtonWallet {
    pub fn get_wallet_createion(&self) -> WalletCreation<WalletClient> {
        WalletCreation {
            wallet_client: Arc::new(WalletClient::new(self.api.clone())),
            wallet_key_provider: None,
        }
    }
}
