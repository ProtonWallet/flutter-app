use muon::{session::{Error, Session}, AppSpec};
use super::wallet_auth_store::WalletAuthStore;

pub(crate) struct ProtonAPIService { //session renew need to connect to cache
    // app_spec: AppSpec,
    // auth_store: WalletAuthStore,
    session: Session,
}

impl Default for ProtonAPIService {
    fn default() -> Self {
        // TODO:: change this to real wallet Product and device agent.
        let app_spec = AppSpec::default();
        let auth_store = WalletAuthStore::new("atlas");
        let session = Session::new(auth_store.clone(), app_spec.clone()).unwrap();
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
    pub async fn login(&mut self, username: &str, password: &str) -> Result<(), Error> {
        // let mut session = Session::new(self.auth_store, self.app_spec).unwrap();// get_session()?;
        _ = self.session.authenticate(username, password).await;
        Ok(())
    }
    pub fn session_ref(&self) -> &Session {
        &self.session
    }
}
