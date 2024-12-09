use crate::{api::errors::BridgeError, proton_wallet::features::proton_recovery::ProtonRecovery};

pub struct FrbProtonRecovery {
    pub(crate) inner: ProtonRecovery,
}

impl FrbProtonRecovery {
    pub async fn recovery_status(&self) -> Result<u32, BridgeError> {
        Ok(self.inner.recovery_status().await?)
    }

    pub async fn two_fa_status(&self) -> Result<u8, BridgeError> {
        Ok(self.inner.two_fa_status().await?)
    }

    pub async fn enable_recovery(
        &self,
        login_password: &str,
        twofa: &str,
    ) -> Result<Vec<String>, BridgeError> {
        Ok(self.inner.enable_recovery(login_password, twofa).await?)
    }

    pub async fn reactive_recovery(
        &self,
        login_password: Option<String>,
        twofa: &str,
    ) -> Result<Vec<String>, BridgeError> {
        Ok(self.inner.reactive_recovery(login_password, twofa).await?)
    }

    pub async fn disable_recovery(
        &self,
        login_password: &str,
        twofa: &str,
    ) -> Result<(), BridgeError> {
        Ok(self.inner.disable_recovery(login_password, twofa).await?)
    }
}
