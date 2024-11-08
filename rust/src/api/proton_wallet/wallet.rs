use std::sync::Arc;

use super::{
    features::backup_mnemonic::FrbBackupMnemonic,
    storage::{
        user_key_store::FrbUserKeyStore, wallet_key_store::FrbWalletKeyStore,
        wallet_mnemonic_store::FrbWalletMnemonicStore,
    },
};
use crate::{
    api::api_service::proton_api_service::ProtonAPIService,
    proton_wallet::{db::app_database::AppDatabase, wallet::ProtonWallet},
};

pub struct FrbProtonWallet {
    pub(crate) inner: ProtonWallet,
}

impl FrbProtonWallet {
    pub async fn new(
        api: Arc<ProtonAPIService>,
        db_path: String,
        user_key_tore: FrbUserKeyStore,
        wallet_key_store: FrbWalletKeyStore,
        wallet_mnemonic_store: FrbWalletMnemonicStore,
    ) -> FrbProtonWallet {
        let mut db = AppDatabase::new(&db_path);
        db.init().await.unwrap();
        db.build_database(1).await.unwrap();
        FrbProtonWallet {
            inner: ProtonWallet::new(
                api.inner.clone(),
                Arc::new(db),
                Arc::new(user_key_tore.inner),
                Arc::new(wallet_key_store.inner),
                Arc::new(wallet_mnemonic_store.inner),
            ),
        }
    }
}

impl FrbProtonWallet {
    pub fn get_backup_mnemonic_feature(&self) -> FrbBackupMnemonic {
        FrbBackupMnemonic {
            inner: self.inner.get_backup_mnemonic(),
        }
    }
}
