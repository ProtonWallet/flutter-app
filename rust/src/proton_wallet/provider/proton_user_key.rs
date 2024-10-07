use super::provider::DataProvider;
use crate::proton_wallet::db::dao::proton_user_key_dao::ProtonUserKeyDao;
use crate::proton_wallet::db::model::proton_user_key_model::ProtonUserKeyModel;
use std::error::Error;

pub struct ProtonUserKeyDataProvider {
    dao: ProtonUserKeyDao,
}

impl ProtonUserKeyDataProvider {
    pub fn new(dao: ProtonUserKeyDao) -> Self {
        ProtonUserKeyDataProvider { dao: dao }
    }

    pub async fn get_all(&mut self) -> Result<Vec<ProtonUserKeyModel>, Box<dyn Error>> {
        Ok(self.dao.get_all().await?)
    }

    pub async fn get_all_by_user_id(
        &mut self,
        user_id: &str,
    ) -> Result<Vec<ProtonUserKeyModel>, Box<dyn Error>> {
        Ok(self.dao.get_all_by_user_id(user_id).await?)
    }
}

impl DataProvider<ProtonUserKeyModel> for ProtonUserKeyDataProvider {
    async fn upsert(&mut self, item: ProtonUserKeyModel) -> Result<(), Box<dyn Error>> {
        // only implemet insert() for proton user, can add update function if needed
        let result = self.dao.insert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, key_id: &str) -> Result<Option<ProtonUserKeyModel>, Box<dyn Error>> {
        Ok(self.dao.get_by_key_id(key_id).await?)
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::proton_user_key_dao::ProtonUserKeyDao;
    use crate::proton_wallet::db::model::proton_user_key_model::ProtonUserKeyModel;
    use crate::proton_wallet::provider::{
        proton_user_key::ProtonUserKeyDataProvider, provider::DataProvider,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_proton_user_key_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let proton_user_key_dao = ProtonUserKeyDao::new(conn_arc.clone());
        let _ = proton_user_key_dao.database.migration_0().await;
        let mut proton_user_key_provider = ProtonUserKeyDataProvider::new(proton_user_key_dao);

        let user_key1 = ProtonUserKeyModel {
            key_id: "mock_key_id".to_string(),
            user_id: "mock_user_id".to_string(),
            version: 233,
            private_key: "mock_private_key_here".to_string(),
            token: Some("mock_token".to_string()),
            fingerprint: Some("FTS721AVC2US".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            primary: 1,
        };

        let user_key2 = ProtonUserKeyModel {
            key_id: "mock_key_id_1".to_string(),
            user_id: "mock_user_id".to_string(),
            version: 233,
            private_key: "mock_private_key_here_1".to_string(),
            token: Some("mock_token_1".to_string()),
            fingerprint: Some("SUIGUG125".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            primary: 0,
        };

        let user_key3 = ProtonUserKeyModel {
            key_id: "mock_key_id_2".to_string(),
            user_id: "mock_user_id_2".to_string(),
            version: 233,
            private_key: "mock_private_key_here_2".to_string(),
            token: Some("mock_token_2".to_string()),
            fingerprint: Some("151ASYGU".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            primary: 0,
        };
        let _ = proton_user_key_provider.upsert(user_key1.clone()).await;
        let _ = proton_user_key_provider.upsert(user_key2.clone()).await;
        let _ = proton_user_key_provider.upsert(user_key3.clone()).await;

        // Test get by key_id
        let fetched_user_key1 = proton_user_key_provider
            .get("mock_key_id")
            .await
            .expect("Failed to get user key")
            .expect("User key not found");
        assert_eq!(fetched_user_key1.key_id, user_key1.key_id);
        assert_eq!(fetched_user_key1.user_id, user_key1.user_id);
        assert_eq!(fetched_user_key1.private_key, user_key1.private_key);
        assert_eq!(fetched_user_key1.primary, user_key1.primary);

        // Test get_all_by_user_id
        let user_keys_for_mock_user = proton_user_key_provider
            .get_all_by_user_id("mock_user_id")
            .await
            .expect("Failed to get all user keys by user id");
        assert_eq!(user_keys_for_mock_user.len(), 2);
        assert_eq!(user_keys_for_mock_user[0].key_id, user_key1.key_id);
        assert_eq!(user_keys_for_mock_user[1].key_id, user_key2.key_id);

        let user_keys_for_mock_user = proton_user_key_provider
            .get_all_by_user_id("mock_user_id_2")
            .await
            .expect("Failed to get all user keys by user id");
        assert_eq!(user_keys_for_mock_user.len(), 1);
        assert_eq!(user_keys_for_mock_user[0].key_id, user_key3.key_id);
    }
}
