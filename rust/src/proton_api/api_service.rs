// use super::wallet_auth_store::WalletAuthStore;
use muon::{
    session::{Error, Session}, AppSpec, SimpleAuthStore
};

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
