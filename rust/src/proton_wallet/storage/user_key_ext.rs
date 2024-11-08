use andromeda_api::proton_users::ProtonUserKey;
use proton_crypto_account::keys::{LockedKey, UserKeys};

/// Converts ProtonUserKey to LockedKey
pub struct UserKeyWrap(ProtonUserKey);
impl UserKeyWrap {
    pub fn new(proton_key: ProtonUserKey) -> Self {
        UserKeyWrap(proton_key)
    }
}

pub struct UserKeysWrap(Vec<ProtonUserKey>);

impl UserKeysWrap {
    pub fn new(proton_keys: Vec<ProtonUserKey>) -> Self {
        UserKeysWrap(proton_keys)
    }
}

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
        UserKeyWrap::new(proton_key)
    }
}

impl From<Vec<ProtonUserKey>> for UserKeysWrap {
    fn from(proton_keys: Vec<ProtonUserKey>) -> Self {
        UserKeysWrap(proton_keys)
    }
}

/// Convert a single ProtonUserKey to LockedKey
pub fn user_key_conversion_from_key(proton_key: ProtonUserKey) -> LockedKey {
    UserKeyWrap::from(proton_key).into()
}

/// Convert a vector of ProtonUserKeys to UserKeys
pub fn user_key_conversion_from_keys(proton_keys: Vec<ProtonUserKey>) -> UserKeys {
    let user_key: Vec<LockedKey> = UserKeysWrap::from(proton_keys).into();
    UserKeys::new(user_key)
}

#[cfg(test)]
mod tests {
    use crate::mocks::user_keys::tests::{mock_fake_proton_user_key, mock_fake_proton_user_key_2};

    use super::*;
    use proton_crypto_account::keys::LockedKey;

    #[test]
    fn test_single_key_conversion() {
        let proton_key = mock_fake_proton_user_key();
        let locked_key: LockedKey = user_key_conversion_from_key(proton_key.clone());

        assert_eq!(locked_key.id.to_string(), proton_key.ID);
        assert_eq!(locked_key.version, proton_key.Version);
        assert_eq!(locked_key.private_key.to_string(), proton_key.PrivateKey);
        assert_eq!(
            locked_key.token.unwrap().to_string(),
            proton_key.Token.unwrap()
        );
        assert!(locked_key.primary);
        assert!(locked_key.active);
        assert_eq!(locked_key.recovery_secret, proton_key.RecoverySecret);
        assert_eq!(
            locked_key.recovery_secret_signature,
            proton_key.RecoverySecretSignature
        );
    }

    #[test]
    fn test_multiple_key_conversion() {
        let proton_keys = vec![mock_fake_proton_user_key(), mock_fake_proton_user_key_2()];
        let user_keys = user_key_conversion_from_keys(proton_keys.clone());
        assert_eq!(user_keys.0.len(), 2);
        for (i, locked_key) in user_keys.0.iter().enumerate() {
            let proton_key = &proton_keys[i];
            assert_eq!(locked_key.id.to_string(), proton_key.ID);
            assert_eq!(locked_key.version, proton_key.Version);
            assert_eq!(locked_key.private_key.to_string(), proton_key.PrivateKey);
            assert_eq!(
                locked_key.token.clone().unwrap().to_string(),
                proton_key.Token.clone().unwrap()
            );
            assert!(locked_key.active);
            assert_eq!(
                locked_key.recovery_secret.clone(),
                proton_key.RecoverySecret.clone()
            );
            assert_eq!(
                locked_key.recovery_secret_signature.clone(),
                proton_key.RecoverySecretSignature.clone()
            );
        }
    }
}
