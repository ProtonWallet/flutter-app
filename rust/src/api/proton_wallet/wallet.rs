use flutter_rust_bridge::frb;
use std::sync::Arc;
use tracing::debug;

use super::{
    features::{backup_mnemonic::FrbBackupMnemonic, proton_recovery::FrbProtonRecovery},
    storage::{
        user_key_store::FrbUserKeyStore, wallet_key_store::FrbWalletKeyStore,
        wallet_mnemonic_store::FrbWalletMnemonicStore,
    },
};
use crate::{
    api::proton_api::retrieve_proton_api,
    proton_wallet::{db::app_database::AppDatabase, wallet::ProtonWallet},
    BridgeError,
};

pub struct FrbProtonWallet {
    pub(crate) inner: ProtonWallet,
}

impl FrbProtonWallet {
    pub async fn new(
        db_path: String,
        user_key_tore: FrbUserKeyStore,
        wallet_key_store: FrbWalletKeyStore,
        wallet_mnemonic_store: FrbWalletMnemonicStore,
    ) -> Result<FrbProtonWallet, BridgeError> {
        debug!("FrbProtonWallet: AppDatabase::new");
        let mut db: AppDatabase = AppDatabase::new(&db_path);
        debug!("FrbProtonWallet: db.init().await.unwrap();");
        db.init().await.unwrap();
        debug!("FrbProtonWallet: db.build_database(1).await.unwrap();");
        db.build_database(1).await.unwrap();
        debug!("FrbProtonWallet: db.build_database(1).await.unwrap();");
        debug!("FrbProtonWallet: FrbProtonWallet::new");
        Ok(FrbProtonWallet {
            inner: ProtonWallet::new(
                Arc::new(db),
                Arc::new(user_key_tore.inner),
                Arc::new(wallet_key_store.inner),
                Arc::new(wallet_mnemonic_store.inner),
            ),
        })
    }
}

impl FrbProtonWallet {
    #[frb(sync)]
    pub fn get_backup_mnemonic_feature(&self) -> Result<FrbBackupMnemonic, BridgeError> {
        let proton_api = retrieve_proton_api()?;
        Ok(FrbBackupMnemonic {
            inner: self.inner.get_backup_mnemonic(proton_api.get_inner()),
        })
    }

    #[frb(sync)]
    pub fn get_proton_recovery_feature(&self) -> Result<FrbProtonRecovery, BridgeError> {
        let proton_api = retrieve_proton_api()?;
        Ok(FrbProtonRecovery {
            inner: self.inner.get_proton_recovery(proton_api.get_inner()),
        })
    }
}
