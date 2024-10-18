use andromeda_api::proton_users::ProtonUserKey;
use proton_crypto_account::keys::{ArmoredPrivateKey, EncryptedKeyToken, KeyId, LockedKey};
use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
pub struct ProtonUserKeyModel {
    pub key_id: String,
    pub user_id: String,
    pub version: u32,
    pub private_key: String,
    pub token: Option<String>,
    pub fingerprint: Option<String>,
    pub recovery_secret: Option<String>,
    pub recovery_secret_signature: Option<String>,
    pub primary: u32,
    pub active: u32,
}

impl ModelBase for ProtonUserKeyModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<ProtonUserKeyModel>(row).unwrap())
    }
}

// Implementing conversion from ProtonUserKeyModel to LockedKey
impl From<ProtonUserKeyModel> for LockedKey {
    fn from(user_key: ProtonUserKeyModel) -> Self {
        let token = user_key.token.clone().take().map(EncryptedKeyToken::from);
        LockedKey {
            id: KeyId::from(user_key.key_id),
            version: user_key.version,
            private_key: ArmoredPrivateKey::from(user_key.private_key),
            token,
            // Assuming signature is not available in ProtonUserKeyModel
            signature: None,
            // Assuming activation is not available
            activation: None,
            // Convert primary field to bool
            primary: user_key.primary == 1,
            active: true, // Assuming the key is active (update logic if needed)
            // Assuming flags is not available in ProtonUserKeyModel
            flags: None,
            recovery_secret: user_key.recovery_secret,
            recovery_secret_signature: user_key.recovery_secret_signature,
            // Assuming not available
            address_forwarding_id: None,
        }
    }
}

impl From<ProtonUserKey> for ProtonUserKeyModel {
    fn from(user_key: ProtonUserKey) -> Self {
        ProtonUserKeyModel {
            key_id: user_key.ID,
            version: user_key.Version,
            private_key: user_key.PrivateKey,
            token: user_key.Token,
            fingerprint: Some(user_key.Fingerprint),
            recovery_secret: user_key.RecoverySecret,
            recovery_secret_signature: user_key.RecoverySecretSignature,
            primary: user_key.Primary,
            active: user_key.Active,
            user_id: "".to_owned(),
        }
    }
}
