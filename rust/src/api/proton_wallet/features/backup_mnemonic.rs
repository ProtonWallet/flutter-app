use crate::{
    api::errors::BridgeError,
    proton_wallet::features::backup_mnemonic::{BackupMnemonic, MnemonicResult},
};

pub struct FrbBackupMnemonic {
    pub(crate) inner: BackupMnemonic,
}

impl FrbBackupMnemonic {
    pub async fn two_fa_status(&self) -> Result<u8, BridgeError> {
        Ok(self.inner.two_fa_status().await?)
    }

    pub async fn view_seed(
        &self,
        wallet_id: String,
        login_password: String,
        twofa: String,
    ) -> Result<MnemonicResult, BridgeError> {
        Ok(self
            .inner
            .view_seed(wallet_id, &login_password, &twofa)
            .await?)
    }
}
