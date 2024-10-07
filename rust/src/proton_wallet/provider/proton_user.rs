use super::provider::DataProvider;
use crate::proton_wallet::db::dao::proton_user_dao::ProtonUserDao;
use crate::proton_wallet::db::model::proton_user_model::ProtonUserModel;
use std::error::Error;

pub struct ProtonUserDataProvider {
    dao: ProtonUserDao,
}

impl ProtonUserDataProvider {
    pub fn new(dao: ProtonUserDao) -> Self {
        ProtonUserDataProvider { dao: dao }
    }

    pub async fn get_all(&mut self) -> Result<Vec<ProtonUserModel>, Box<dyn Error>> {
        Ok(self.dao.get_all().await?)
    }
}

impl DataProvider<ProtonUserModel> for ProtonUserDataProvider {
    async fn upsert(&mut self, item: ProtonUserModel) -> Result<(), Box<dyn Error>> {
        // only implemet insert() for proton user, can add update function if needed
        let result = self.dao.insert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, user_id: &str) -> Result<Option<ProtonUserModel>, Box<dyn Error>> {
        Ok(self.dao.get_by_user_id(user_id).await?)
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::proton_user_dao::ProtonUserDao;
    use crate::proton_wallet::db::model::proton_user_model::ProtonUserModel;
    use crate::proton_wallet::provider::{
        proton_user::ProtonUserDataProvider, provider::DataProvider,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_proton_user_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let proton_user_dao = ProtonUserDao::new(conn_arc.clone());
        let _ = proton_user_dao.database.migration_0().await;
        let mut proton_user_provider = ProtonUserDataProvider::new(proton_user_dao);

        let proton_user1 = ProtonUserModel {
            id: 0,
            user_id: "mock_user_id".to_string(),
            name: "test proton user".to_string(),
            used_space: 6666,
            currency: "CHF".to_string(),
            credit: 168,
            create_time: 55688,
            max_space: 9999,
            max_upload: 1234,
            role: 10,
            private: 1,
            subscribed: 0,
            services: 12,
            delinquent: 0,
            organization_private_key: None,
            email: Some("test@example.com".to_string()),
            display_name: Some("Test User".to_string()),
        };
        let _ = proton_user_provider.upsert(proton_user1.clone()).await;

        // Test get
        let fetched_proton_user1 = proton_user_provider
            .get("mock_user_id")
            .await
            .expect("Failed to get exchange rate")
            .expect("Exchange rate not found");
        assert_eq!(fetched_proton_user1.user_id, proton_user1.user_id);
        assert_eq!(fetched_proton_user1.used_space, proton_user1.used_space);
        assert_eq!(fetched_proton_user1.max_space, proton_user1.max_space);
        assert_eq!(fetched_proton_user1.max_upload, proton_user1.max_upload);

        // Test get_all
        let all_proton_users = proton_user_provider
            .get_all()
            .await
            .expect("Failed to get all exchange rates");
        assert_eq!(all_proton_users.len(), 1);
        assert_eq!(all_proton_users[0].user_id, proton_user1.user_id);
        assert_eq!(all_proton_users[0].used_space, proton_user1.used_space);
        assert_eq!(all_proton_users[0].max_space, proton_user1.max_space);
        assert_eq!(all_proton_users[0].max_upload, proton_user1.max_upload);
    }
}
