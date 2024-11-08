use proton_crypto_account::keys::{ArmoredPrivateKey, KeyFlag, LockedKey};

use crate::proton_address::ProtonAddressKey;

pub struct AddressKeyWrap(ProtonAddressKey);
impl AddressKeyWrap {
    pub fn new(proton_key: ProtonAddressKey) -> Self {
        AddressKeyWrap(proton_key)
    }
}

pub struct AddressKeysWrap(Vec<ProtonAddressKey>);
impl AddressKeysWrap {
    pub fn new(proton_keys: Vec<ProtonAddressKey>) -> Self {
        AddressKeysWrap(proton_keys)
    }
}

impl From<AddressKeyWrap> for LockedKey {
    fn from(addr_key: AddressKeyWrap) -> Self {
        LockedKey {
            id: addr_key.0.id.into(),
            version: addr_key.0.version,
            private_key: ArmoredPrivateKey::from(addr_key.0.private_key.unwrap_or_default()),
            token: addr_key.0.token.map(Into::into),
            signature: addr_key.0.signature.map(Into::into),
            activation: None,
            primary: addr_key.0.primary != 0,
            active: addr_key.0.active != 0,
            flags: Some(KeyFlag::from(addr_key.0.flags)),
            recovery_secret: None,
            recovery_secret_signature: None,
            address_forwarding_id: None,
        }
    }
}

impl From<AddressKeysWrap> for Vec<LockedKey> {
    fn from(addr_keys: AddressKeysWrap) -> Self {
        addr_keys
            .0
            .into_iter()
            .map(|proton_key| AddressKeyWrap(proton_key).into())
            .collect()
    }
}
