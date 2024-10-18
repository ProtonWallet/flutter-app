use std::sync::Arc;

use crate::{
    api::api_service::proton_api_service::ProtonAPIService,
    proton_wallet::{db::app_database::AppDatabase, wallet::ProtonWallet},
};

use super::features::wallet_creation::FrbWalletCreation;

pub struct FrbProtonWallet {
    pub(crate) inner: ProtonWallet,
}

impl FrbProtonWallet {
    pub fn new(api: Arc<ProtonAPIService>, db_path: String) -> FrbProtonWallet {
        FrbProtonWallet {
            inner: ProtonWallet::new(api.inner.clone(), Arc::new(AppDatabase::new(&db_path))),
        }
    }
}

impl FrbProtonWallet {
    pub fn get_wallet_crateion_feature(&self) -> FrbWalletCreation {
        FrbWalletCreation {
            inner: self.inner.get_wallet_createion(),
        }
    }
}
