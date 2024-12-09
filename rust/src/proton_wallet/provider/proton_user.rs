use std::sync::Arc;

use andromeda_api::proton_users::{ProtonSrpClientProofs, ProtonUsersClientExt};
use async_trait::async_trait;

use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::proton_user_dao::ProtonUserDao, model::proton_user_model::ProtonUserModel,
};

#[async_trait]
pub trait ProtonUserDataProvider: Send + Sync {
    async fn unlock_password_change(&self, proofs: ProtonSrpClientProofs) -> Result<String>;
}

pub struct ProtonUserDataProviderImpl {
    dao: ProtonUserDao,
    pub(crate) proton_users_client: Arc<dyn ProtonUsersClientExt + Send + Sync>,
}

impl ProtonUserDataProviderImpl {
    pub fn new(
        dao: ProtonUserDao,
        proton_users_client: Arc<dyn ProtonUsersClientExt + Send + Sync>,
    ) -> Self {
        ProtonUserDataProviderImpl {
            dao,
            proton_users_client,
        }
    }

    pub async fn get_all(&mut self) -> Result<Vec<ProtonUserModel>> {
        Ok(self.dao.get_all().await?)
    }
}

#[async_trait]
impl ProtonUserDataProvider for ProtonUserDataProviderImpl {
    async fn unlock_password_change(&self, proofs: ProtonSrpClientProofs) -> Result<String> {
        Ok(self
            .proton_users_client
            .unlock_password_change(proofs)
            .await?)
    }
}

impl DataProvider<ProtonUserModel> for ProtonUserDataProviderImpl {
    async fn upsert(&mut self, item: ProtonUserModel) -> Result<()> {
        // only implemet insert() for proton user, can add update function if needed
        let result = self.dao.insert(&item).await;
        result?;
        Ok(())
    }
    async fn get(&mut self, user_id: &str) -> Result<Option<ProtonUserModel>> {
        Ok(self.dao.get_by_user_id(user_id).await?)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub ProtonUserDataProvider {}
        #[async_trait]
        impl ProtonUserDataProvider for ProtonUserDataProvider {
            async fn unlock_password_change(&self, proofs: ProtonSrpClientProofs) -> Result<String>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::{
        mocks::proton_user::tests::build_test_proton_user_model,
        proton_wallet::db::dao::proton_user_dao::ProtonUserDao,
    };
    use andromeda_api::tests::proton_users_mock::mock_utils::MockProtonUsersClient;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_proton_user_provider_upsert_and_get() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let proton_user_dao = ProtonUserDao::new(conn.clone());
        proton_user_dao.database.migration_0().await.unwrap();
        let mock_client = MockProtonUsersClient::new();
        let mut proton_user_provider =
            ProtonUserDataProviderImpl::new(proton_user_dao, Arc::new(mock_client));
        // manually insert proton user
        let proton_user = build_test_proton_user_model();
        proton_user_provider
            .upsert(proton_user.clone())
            .await
            .unwrap();
        // try get proton user
        let fetched_user = proton_user_provider
            .get("mock_user_id")
            .await
            .unwrap()
            .unwrap();
        assert_eq!(fetched_user.user_id, proton_user.user_id);
        assert_eq!(fetched_user.used_space, proton_user.used_space);
        assert_eq!(fetched_user.max_space, proton_user.max_space);
        assert_eq!(fetched_user.max_upload, proton_user.max_upload);
        let all_proton_users = proton_user_provider.get_all().await.unwrap();
        assert_eq!(all_proton_users.len(), 1);
        assert_eq!(all_proton_users[0].user_id, proton_user.user_id);
        assert_eq!(all_proton_users[0].used_space, proton_user.used_space);
        assert_eq!(all_proton_users[0].max_space, proton_user.max_space);
        assert_eq!(all_proton_users[0].max_upload, proton_user.max_upload);
    }

    #[tokio::test]
    async fn test_unlock_password_change() {
        let mock_proof = ProtonSrpClientProofs {
            ClientEphemeral: "test_ephemeral".to_string(),
            ClientProof: "test_proof".to_string(),
            SRPSession: "test_session".to_string(),
            TwoFactorCode: None,
        };

        let mut mock_client = MockProtonUsersClient::new();
        mock_client
            .expect_unlock_password_change()
            .with(mockall::predicate::eq(mock_proof.clone()))
            .times(1)
            .returning(|_| Ok("password_changed".to_string()));

        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let proton_user_dao = ProtonUserDao::new(conn);
        proton_user_dao.database.migration_0().await.unwrap();
        let proton_user_provider =
            ProtonUserDataProviderImpl::new(proton_user_dao, Arc::new(mock_client));

        let result = proton_user_provider
            .unlock_password_change(mock_proof)
            .await
            .unwrap();
        // check server proofs
        assert_eq!(result, "password_changed");
    }
}
