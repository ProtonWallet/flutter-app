use proton_crypto_account::{
    errors::KeyError,
    keys::{
        AddressKeys, ArmoredPrivateKey, KeyId, LocalUserKey, LockedKey, UnlockedAddressKey,
        UnlockedAddressKeys, UnlockedUserKey, UnlockedUserKeys, UserKeys,
    },
    proton_crypto::crypto::{AsPublicKeyRef, PGPProvider, PGPProviderSync},
    salts::KeySecret,
};

use super::{errors::WalletCryptoError, Result};

#[derive(Debug, Clone)]
pub struct RelockedKey {
    pub private_key: ArmoredPrivateKey,
    pub key_id: KeyId,
}

pub struct UnlockedPrivateKeys<Provider: PGPProviderSync> {
    pub(crate) user_keys: UnlockedUserKeys<Provider>,
    pub(crate) addr_keys: UnlockedAddressKeys<Provider>,

    // Failed keys, in some cases we can ignore errors and continue
    #[allow(dead_code)]
    pub(crate) user_keys_failed: Vec<KeyError>,
    #[allow(dead_code)]
    pub(crate) addr_keys_failed: Vec<KeyError>,
}

impl<Provider: PGPProviderSync> UnlockedPrivateKeys<Provider> {
    pub fn from_user_key(user_key: UnlockedUserKey<Provider>) -> Self {
        Self {
            user_keys: vec![user_key],
            addr_keys: vec![],
            user_keys_failed: vec![],
            addr_keys_failed: vec![],
        }
    }

    pub fn from_addr_key(address_key: UnlockedAddressKey<Provider>) -> Self {
        Self {
            user_keys: vec![],
            addr_keys: vec![address_key],
            user_keys_failed: vec![],
            addr_keys_failed: vec![],
        }
    }
}

impl<Provider: PGPProviderSync> UnlockedPrivateKeys<Provider> {
    /// Gathers available public keys from address, if no address keys return user keys.
    /// If there are no valid public keys, returns a `WalletCryptoError::NoKeysFound`.
    pub fn as_self_encryption_public_key(&self) -> Result<<Provider as PGPProvider>::PublicKey> {
        // First, check if there are any address keys
        let pub_keys: Vec<<Provider as PGPProvider>::PublicKey> = if !self.addr_keys.is_empty() {
            // If address keys are not empty, return only address keys
            self.addr_keys
                .iter()
                .map(|addr_key| addr_key.as_public_key().clone())
                .collect()
        } else if !self.user_keys.is_empty() {
            // Otherwise, return user keys if address keys are empty and user keys are available
            self.user_keys
                .iter()
                .map(|user_key| user_key.as_public_key().clone())
                .collect()
        } else {
            vec![]
        };
        pub_keys
            .first()
            .cloned()
            .ok_or(WalletCryptoError::NoKeysFound)
    }
}

pub struct LockedPrivateKeys {
    pub(crate) user_keys: UserKeys,
    pub(crate) addr_keys: AddressKeys,
}

impl LockedPrivateKeys {
    pub fn from_primary(primary_key: LockedKey) -> Self {
        Self::from_keys([primary_key].to_vec(), [].to_vec())
    }

    pub fn from_user_keys(user_keys: Vec<LockedKey>) -> Self {
        Self::from_keys(user_keys, [].to_vec())
    }

    pub fn from_keys(user_keys: Vec<LockedKey>, addr_keys: Vec<LockedKey>) -> Self {
        Self {
            user_keys: UserKeys::new(user_keys),
            addr_keys: AddressKeys::new(addr_keys),
        }
    }
}

impl LockedPrivateKeys {
    /// Unlocks both user and address keys using the given provider and secret.
    /// If some keys fail, they are tracked separately in the `UnlockedPrivateKeys`.
    ///
    ///  Notes: unlock user keys and address keys together becuase transaction id could be encrypted with either.
    pub fn unlock_with<T: PGPProviderSync>(
        &self,
        provider: &T,
        user_key_secret: &KeySecret,
    ) -> UnlockedPrivateKeys<T> {
        // unlock user keys
        let unlocked_user_keys = self.user_keys.unlock(provider, user_key_secret);
        // unlock address keys with unlocked user keys
        let unlocked_addr_keys = self.addr_keys.unlock(
            provider,
            &unlocked_user_keys.unlocked_keys,
            Some(user_key_secret),
        );
        // Package everything into the glorious UnlockedPrivateKeys structure!
        UnlockedPrivateKeys {
            user_keys: unlocked_user_keys.unlocked_keys,
            addr_keys: unlocked_addr_keys.unlocked_keys,
            user_keys_failed: unlocked_user_keys.failed,
            addr_keys_failed: unlocked_addr_keys.failed,
        }
    }

    /// Unlocks user using the given provider and secret.
    /// Then relock the user keys with new secret.
    ///
    pub fn relock_user_key_with<T: PGPProviderSync>(
        provider: &T,
        user_keys: UserKeys,
        old_key_secret: &KeySecret,
        new_key_secret: &KeySecret,
    ) -> Result<Vec<RelockedKey>> {
        // unlock user keys
        let unlocked_user_keys = user_keys.unlock(provider, old_key_secret);
        if !unlocked_user_keys.failed.is_empty()
            || unlocked_user_keys.unlocked_keys.len() != user_keys.0.len()
        {
            return Err(WalletCryptoError::RelockKeyCountMismatch(
                "Unlock User Keys".to_owned(),
            ));
        }

        // relock user keys
        let mut new_private_keys: Vec<RelockedKey> = Vec::new();
        for unlocked_key in unlocked_user_keys.unlocked_keys {
            let new_private_key =
                LocalUserKey::relock_user_key(provider, &unlocked_key, new_key_secret)?;
            let new_key = RelockedKey {
                private_key: new_private_key.private_key,
                key_id: unlocked_key.id.clone(),
            };
            new_private_keys.push(new_key);
        }

        // check count
        if new_private_keys.len() != user_keys.0.len() {
            return Err(WalletCryptoError::RelockKeyCountMismatch(
                "Lock User Keys".to_owned(),
            ));
        }

        Ok(new_private_keys)
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_1_locked_user_key, get_test_user_1_locked_user_key_secret,
            get_test_user_2_locked_address_key, get_test_user_2_locked_user_key,
            get_test_user_2_locked_user_key_secret, get_test_user_2_locked_user_keys,
        },
        proton_wallet::crypto::{errors::WalletCryptoError, private_key::LockedPrivateKeys},
    };

    use super::UnlockedPrivateKeys;
    use proton_crypto::crypto::{AccessKeyInfo, PGPProviderSync};
    use proton_crypto_account::{
        keys::{AddressKeys, UserKeys},
        proton_crypto::{crypto::AsPublicKeyRef, new_pgp_provider},
    };

    #[test]
    fn test_unlock_with_ok_keys() {
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: locked_address_keys,
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(!unlocked_private_keys.user_keys.is_empty());
        assert!(unlocked_private_keys.user_keys_failed.is_empty());

        assert!(!unlocked_private_keys.addr_keys.is_empty());
        assert!(unlocked_private_keys.addr_keys_failed.is_empty());
    }

    #[test]
    fn test_unlock_with_failed_keys() {
        let locked_user_keys = get_test_user_1_locked_user_key();
        let key_secret = get_test_user_1_locked_user_key_secret();
        let locked_address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: locked_address_keys,
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(!unlocked_private_keys.user_keys.is_empty());
        assert!(unlocked_private_keys.user_keys_failed.is_empty());

        assert!(unlocked_private_keys.addr_keys.is_empty());
        assert!(!unlocked_private_keys.addr_keys_failed.is_empty());
    }

    #[test]
    fn test_unlock_with_all_failed_keys() {
        let locked_user_keys = get_test_user_1_locked_user_key();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: locked_address_keys,
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(unlocked_private_keys.user_keys.is_empty());
        assert!(!unlocked_private_keys.user_keys_failed.is_empty());

        assert!(unlocked_private_keys.addr_keys.is_empty());
        assert!(!unlocked_private_keys.addr_keys_failed.is_empty());
    }

    #[test]
    fn test_get_unlocked_key_get_pub_key_user_only() {
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: AddressKeys::new([]),
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(!unlocked_private_keys.user_keys.is_empty());
        assert!(unlocked_private_keys.user_keys_failed.is_empty());

        assert!(unlocked_private_keys.addr_keys.is_empty());
        assert!(unlocked_private_keys.addr_keys_failed.is_empty());

        let pub_keys = unlocked_private_keys
            .as_self_encryption_public_key()
            .unwrap();

        let left = pub_keys.key_fingerprint();
        let right = unlocked_private_keys
            .user_keys
            .first()
            .unwrap()
            .as_public_key()
            .key_fingerprint();

        assert!(left == right);
    }

    #[test]
    fn test_get_unlocked_key_get_pub_key() {
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: locked_address_keys,
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(!unlocked_private_keys.user_keys.is_empty());
        assert!(unlocked_private_keys.user_keys_failed.is_empty());

        assert!(!unlocked_private_keys.addr_keys.is_empty());
        assert!(unlocked_private_keys.addr_keys_failed.is_empty());

        let pub_key = unlocked_private_keys
            .as_self_encryption_public_key()
            .unwrap();

        let left = pub_key.key_fingerprint();
        let right = unlocked_private_keys
            .user_keys
            .first()
            .unwrap()
            .as_public_key()
            .key_fingerprint();
        assert_ne!(left, right);

        let left = pub_key.key_fingerprint();
        let right = unlocked_private_keys
            .addr_keys
            .first()
            .unwrap()
            .as_public_key()
            .key_fingerprint();
        assert_eq!(left, right);
    }

    #[test]
    fn test_get_unlocked_key_get_pub_key_empty() {
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_keys = LockedPrivateKeys {
            user_keys: UserKeys::new([]),
            addr_keys: AddressKeys::new([]),
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(unlocked_private_keys.user_keys.is_empty());
        assert!(unlocked_private_keys.user_keys_failed.is_empty());

        assert!(unlocked_private_keys.addr_keys.is_empty());
        assert!(unlocked_private_keys.addr_keys_failed.is_empty());

        let pub_keys = unlocked_private_keys.as_self_encryption_public_key();
        assert!(pub_keys.is_err());
    }

    #[test]
    fn test_unlocked_user_key_only() {
        let locked_user_key = get_test_user_2_locked_user_key();
        let key_secret = get_test_user_2_locked_user_key_secret();
        let locked_keys = LockedPrivateKeys::from_primary(locked_user_key);

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        assert!(!unlocked_private_keys.user_keys.is_empty());
        assert!(unlocked_private_keys.user_keys_failed.is_empty());

        assert!(unlocked_private_keys.addr_keys.is_empty());
        assert!(unlocked_private_keys.addr_keys_failed.is_empty());
    }

    fn create_keys_with_default<Provider: PGPProviderSync>(
        _: &Provider,
    ) -> UnlockedPrivateKeys<Provider> {
        UnlockedPrivateKeys {
            user_keys: Default::default(),
            addr_keys: Default::default(),
            user_keys_failed: Vec::new(),
            addr_keys_failed: Vec::new(),
        }
    }
    #[test]
    fn test_no() {
        let provider = new_pgp_provider();
        let default_keys = create_keys_with_default(&provider);
        let error = default_keys.as_self_encryption_public_key().err();
        assert!(error.is_some());
        match error {
            Some(WalletCryptoError::NoKeysFound) => {}
            _ => panic!("Expected WalletCryptoError::AesGcm variant"),
        }
    }
}
