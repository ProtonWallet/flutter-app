use andromeda_api::proton_users::ProtonUserKey;
use proton_crypto_account::keys::{LockedKey, UserKeys};

/// convert ProtonUserKey to LockedKey
struct UserKeyWrap(ProtonUserKey);
struct UserKeysWrap(Vec<ProtonUserKey>);
impl From<UserKeyWrap> for LockedKey {
    fn from(user_key: UserKeyWrap) -> Self {
        LockedKey {
            id: user_key.0.ID.into(),
            version: user_key.0.Version,
            private_key: user_key.0.PrivateKey.into(),
            token: user_key.0.Token.map(Into::into),
            signature: None,
            activation: None,
            primary: user_key.0.Primary != 0,
            active: user_key.0.Active != 0,
            flags: None,
            recovery_secret: user_key.0.RecoverySecret,
            recovery_secret_signature: user_key.0.RecoverySecretSignature,
            address_forwarding_id: None,
        }
    }
}

impl From<UserKeysWrap> for Vec<LockedKey> {
    fn from(user_keys: UserKeysWrap) -> Self {
        user_keys
            .0
            .into_iter()
            .map(|proton_key| UserKeyWrap(proton_key).into())
            .collect()
    }
}

impl From<ProtonUserKey> for UserKeyWrap {
    fn from(proton_key: ProtonUserKey) -> Self {
        UserKeyWrap(proton_key)
    }
}
impl From<Vec<ProtonUserKey>> for UserKeysWrap {
    fn from(proton_keys: Vec<ProtonUserKey>) -> Self {
        UserKeysWrap(proton_keys)
    }
}

pub fn user_key_conversion_from_key(proton_key: ProtonUserKey) -> LockedKey {
    UserKeyWrap::from(proton_key).into()
}

pub fn user_key_conversion_from_keys(proton_keys: Vec<ProtonUserKey>) -> UserKeys {
    let user_key: Vec<LockedKey> = UserKeysWrap::from(proton_keys).into();
    UserKeys::new(user_key)
}
