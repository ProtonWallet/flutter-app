use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::wallet_user_settings_dao::WalletUserSettingsDao,
    model::wallet_user_settings_model::WalletUserSettingsModel,
};

pub struct WalletUserSettingsDataProvider {
    pub(crate) dao: WalletUserSettingsDao,
}

impl WalletUserSettingsDataProvider {
    pub fn new(dao: WalletUserSettingsDao) -> Self {
        WalletUserSettingsDataProvider { dao }
    }
}

impl DataProvider<WalletUserSettingsModel> for WalletUserSettingsDataProvider {
    async fn upsert(&mut self, item: WalletUserSettingsModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, user_id: &str) -> Result<Option<WalletUserSettingsModel>> {
        Ok(self.dao.get_by_user_id(user_id).await?)
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::wallet_user_settings_dao::WalletUserSettingsDao;
    use crate::proton_wallet::db::model::wallet_user_settings_model::WalletUserSettingsModel;
    use crate::proton_wallet::provider::{
        provider::DataProvider, wallet_user_settings::WalletUserSettingsDataProvider,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_contact_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_user_settings_dao = WalletUserSettingsDao::new(conn_arc.clone());
        let _ = wallet_user_settings_dao.database.migration_0().await;
        let mut wallet_user_settings_provider =
            WalletUserSettingsDataProvider::new(wallet_user_settings_dao);

        let setting = WalletUserSettingsModel {
            user_id: "mock_user_id".to_string(),
            bitcoin_unit: "MBTC".to_string(),
            fiat_currency: "CNY".to_string(),
            hide_empty_used_addresses: 1,
            show_wallet_recovery: 1,
            two_factor_amount_threshold: 66.66,
            receive_inviter_notification: 0,
            receive_email_integration_notification: 1,
            wallet_created: 0,
            accept_terms_and_conditions: 0,
        };

        wallet_user_settings_provider
            .upsert(setting.clone())
            .await
            .unwrap();

        // Test get
        let user_setting = wallet_user_settings_provider
            .get("mock_user_id2")
            .await
            .unwrap();
        assert!(user_setting.is_none());

        let user_setting = wallet_user_settings_provider
            .get("mock_user_id")
            .await
            .unwrap();
        assert!(user_setting.is_some());
        let user_setting = user_setting.unwrap();
        assert_eq!(
            user_setting.accept_terms_and_conditions,
            setting.accept_terms_and_conditions
        );
        assert_eq!(user_setting.bitcoin_unit, setting.bitcoin_unit);
        assert_eq!(user_setting.fiat_currency, setting.fiat_currency);
        assert_eq!(
            user_setting.hide_empty_used_addresses,
            setting.hide_empty_used_addresses
        );
        assert_eq!(
            user_setting.show_wallet_recovery,
            setting.show_wallet_recovery
        );
        assert_eq!(
            user_setting.receive_inviter_notification,
            setting.receive_inviter_notification
        );
        assert_eq!(
            user_setting.receive_email_integration_notification,
            setting.receive_email_integration_notification
        );
        assert_eq!(user_setting.wallet_created, setting.wallet_created);
        assert_eq!(
            user_setting.accept_terms_and_conditions,
            setting.accept_terms_and_conditions
        );
    }
}
