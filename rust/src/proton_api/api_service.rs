use std::{collections::HashMap, sync::{Arc, RwLock}};
use lazy_static::lazy_static;

use muon::{
    session::{Error, Session}, store::SimpleAuthStore, AppSpec
};

lazy_static! {
    static ref PROTON_API: RwLock<HashMap<String, Arc<ProtonAPIService>>> = RwLock::new(HashMap::new());
}
fn persist_proton_api(id: String, proton_api: ProtonAPIService) {
    let mut api_lock = PROTON_API.write().unwrap();
    api_lock.insert(id, Arc::new(proton_api));
}

pub(crate) struct ProtonAPIService {
    //session renew need to connect to cache
    // app_spec: AppSpec,
    // auth_store: WalletAuthStore,
    session: Session,
}

impl Default for ProtonAPIService {
    fn default() -> Self {
        // TODO:: change this to real wallet Product and device agent.
        let app_spec = AppSpec::default();
        let auth_store = SimpleAuthStore::new("atlas"); // replace with WalletAuthStore that handling the cache
        let session = Session::new(auth_store, app_spec).unwrap();
        Self {
            // app_spec,
            // auth_store,
            session,
        }
    }

    // new with app_spec and auth_store
    // TODO::
}

impl ProtonAPIService {

    pub fn new_proton_api() -> Result<String, Error> {
        let proton_api = ProtonAPIService::default();
        let id = "1234567890".to_string();
        persist_proton_api(id.clone(), proton_api);
        Ok(id)
    }

    pub fn retrieve_proton_api(id: String) -> Arc<ProtonAPIService> {
        let wallet_lock = PROTON_API.read().unwrap();
        wallet_lock.get(id.as_str()).unwrap().clone()
    }

    pub async fn login(&mut self, username: &str, password: &str) -> Result<(), Error> {
        // let mut session = Session::new(self.auth_store, self.app_spec).unwrap();// get_session()?;
        _ = self.session.authenticate(username, password).await;
        Ok(())
    }
    pub fn session_ref(&self) -> &Session {
        &self.session
    }
}

// TODO:: add generarc error parser

#[cfg(test)]
mod test {
   
}
