// address_info.rs
use andromeda_bitcoin::AddressInfo;
use andromeda_bitcoin::KeychainKind;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbAddressInfo {
    /// Child index of this address
    pub index: u32,
    /// Address
    pub address: String,
    /// Type of keychain
    pub keychain: KeychainKind,
}

impl From<AddressInfo> for FrbAddressInfo {
    fn from(address_info: AddressInfo) -> Self {
        Self {
            index: address_info.index,
            address: address_info.address.to_string(),
            keychain: address_info.keychain,
        }
    }
}
