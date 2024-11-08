use std::sync::Arc;

use andromeda_api::{
    core::ApiClient, wallet::WalletClient, ProtonUsersClient, ProtonWalletApiClient,
};

use super::{
    db::app_database::AppDatabase,
    features::{
        backup_mnemonic::BackupMnemonic, proton_settings::password_scope::PasswordScopeImpl,
    },
    provider::{
        proton_auth::ProtonAuthProviderImpl, proton_user::ProtonUserDataProviderImpl,
        user_keys::UserKeysProviderImpl, wallet::WalletDataProviderImpl,
        wallet_keys::WalletKeysProviderImpl, wallet_mnemonic::WalletMnemonicProviderImpl,
        wallet_name::WalletNameProviderImpl,
    },
    storage::{
        user_key::UserKeySecureStore, wallet_key::WalletKeySecureStore,
        wallet_mnemonic::WalletMnemonicSecureStore,
    },
};

// this is the main object that will be used to interact with the wallet and eatch proton account will only have one Proton Wallet object
// per app could have multiple Proton Wallet objects because we will support multiple users
pub(crate) struct ProtonWallet {
    api: Arc<ProtonWalletApiClient>,
    db: Arc<AppDatabase>,
    user_id: String,

    // pub(crate) auth_provider: Arc<dyn ProtonAuthProvider>,
    user_key_store: Arc<UserKeySecureStore>,
    wallet_key_store: Arc<WalletKeySecureStore>,
    wallet_mnemonic_store: Arc<WalletMnemonicSecureStore>,
}

impl ProtonWallet {
    /// create a new wallet
    /// login will be used after get user sessions. The login module will be in a seperate module
    /// @param user_id: the user id of the user that is logging in
    /// @param session_store
    /// @param user_store
    /// @param db
    /// @param network
    /// etc ...
    pub fn new(
        api: Arc<ProtonWalletApiClient>,
        db: Arc<AppDatabase>,
        user_key_store: Arc<UserKeySecureStore>,
        wallet_key_store: Arc<WalletKeySecureStore>,
        wallet_mnemonic_store: Arc<WalletMnemonicSecureStore>,
    ) -> ProtonWallet {
        ProtonWallet {
            api,
            db,
            user_id: "".to_string(),
            user_key_store,
            wallet_key_store,
            wallet_mnemonic_store,
        }
    }
}

impl ProtonWallet {

    pub fn get_backup_mnemonic(&self) -> BackupMnemonic {
        let proton_user_client = Arc::new(ProtonUsersClient::new(self.api.clone()));
        let wallet_client = Arc::new(WalletClient::new(self.api.clone()));

        let auth_provider = Arc::new(ProtonAuthProviderImpl {
            proton_user_client: Arc::new(ProtonUsersClient::new(self.api.clone())),
        });

        let proton_users_provider = Arc::new(ProtonUserDataProviderImpl::new(
            self.db.proton_user_dao.clone(),
            proton_user_client.clone(),
        ));

        // user keys provider
        let user_keys_provider = Arc::new(UserKeysProviderImpl::new(
            self.user_id.clone(),
            self.user_key_store.clone(),
            Arc::new(self.db.proton_user_key_dao.clone()),
            proton_user_client,
        ));

        // wallet keys provider
        let wallet_keys_provider = Arc::new(WalletKeysProviderImpl::new(
            user_keys_provider.clone(),
            self.wallet_key_store.clone(),
            wallet_client.clone(),
        ));

        let wallet_data_provider = Arc::new(WalletDataProviderImpl::new(
            Arc::new(self.db.wallet_dao.clone()),
            Arc::new(self.db.account_dao.clone()),
            self.wallet_mnemonic_store.clone(),
            wallet_client,
            self.user_id.clone(),
        ));

        let wallet_mnemonic_provider = Arc::new(WalletMnemonicProviderImpl::new(
            wallet_keys_provider.clone(),
            wallet_data_provider.clone(),
            user_keys_provider,
        ));

        let wallet_name_provider = Arc::new(WalletNameProviderImpl::new(
            wallet_keys_provider,
            wallet_data_provider,
        ));

        let unlock_password = Arc::new(PasswordScopeImpl::new(
            auth_provider.clone(),
            proton_users_provider,
        ));

        BackupMnemonic {
            auth_provider,
            wallet_mnemonic_provider,
            wallet_name_provider,
            unlock_password,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;

    #[tokio::test]
    async fn test_get_wallet_creation() {
        let api = Arc::new(ProtonWalletApiClient::default());
        let db = Arc::new(AppDatabase::default());
        let user_key_store = Arc::new(UserKeySecureStore::default());
        let wallet_key_store = Arc::new(WalletKeySecureStore::default());
        let wallet_mnemonic_store = Arc::new(WalletMnemonicSecureStore::default());

        let _ = ProtonWallet::new(
            api.clone(),
            db.clone(),
            user_key_store,
            wallet_key_store,
            wallet_mnemonic_store,
        );

    }

    #[tokio::test]
    async fn test_get_backup_mnemonic() {
        let api = Arc::new(ProtonWalletApiClient::default());
        let db = Arc::new(AppDatabase::default());
        let user_key_store = Arc::new(UserKeySecureStore::default());
        let wallet_key_store = Arc::new(WalletKeySecureStore::default());
        let wallet_mnemonic_store = Arc::new(WalletMnemonicSecureStore::default());

        let proton_wallet = ProtonWallet::new(
            api.clone(),
            db.clone(),
            user_key_store,
            wallet_key_store,
            wallet_mnemonic_store,
        );
        proton_wallet.get_backup_mnemonic();
    }
}
