use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::contacts_dao::ContactsDao, model::contacts_model::ContactsModel,
};

pub struct ContactsDataProvider {
    dao: ContactsDao,
}

impl ContactsDataProvider {
    pub fn new(dao: ContactsDao) -> Self {
        ContactsDataProvider { dao }
    }

    pub async fn get_all(&mut self) -> Result<Vec<ContactsModel>> {
        Ok(self.dao.get_all().await?)
    }
}

impl DataProvider<ContactsModel> for ContactsDataProvider {
    async fn upsert(&mut self, item: ContactsModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<ContactsModel>> {
        Ok(self.dao.get_by_server_id(server_id).await?)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_contact_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let contacts_dao = ContactsDao::new(conn_arc.clone());
        let _ = contacts_dao.database.migration_0().await;
        let mut contacts_provider = ContactsDataProvider::new(contacts_dao);

        let contact1 = ContactsModel {
            id: Some(1),
            server_contact_id: "server_contact_123".to_string(),
            name: "John Doe".to_string(),
            email: "john.doe@example.com".to_string(),
            canonical_email: "johndoe@example.com".to_string(),
            is_proton: 1,
        };
        let contact2 = ContactsModel {
            id: Some(2),
            server_contact_id: "server_contact_222".to_string(),
            name: "Mark Yan".to_string(),
            email: "mark_yyy@example.com".to_string(),
            canonical_email: "mark_yyy@example.com".to_string(),
            is_proton: 0,
        };
        let _ = contacts_provider.upsert(contact1.clone()).await;
        let _ = contacts_provider.upsert(contact2.clone()).await;

        // Test get_all
        let contacts = contacts_provider.get_all().await.unwrap();
        assert_eq!(contacts.len(), 2);
        assert_eq!(contacts[0].server_contact_id, contact1.server_contact_id);
        assert_eq!(contacts[0].name, contact1.name);
        assert_eq!(contacts[0].email, contact1.email);
        assert_eq!(contacts[1].server_contact_id, contact2.server_contact_id);
        assert_eq!(contacts[1].name, contact2.name);
        assert_eq!(contacts[1].email, contact2.email);

        // Test get
        let contact = contacts_provider.get("server_contact_222").await.unwrap();
        assert!(contact.is_some());
        let contact = contact.unwrap();
        assert_eq!(contact.server_contact_id, contact2.server_contact_id);
        assert_eq!(contact.name, contact2.name);
        assert_eq!(contact.email, contact2.email);
    }
}
