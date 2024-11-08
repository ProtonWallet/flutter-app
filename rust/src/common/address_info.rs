// address_info.rs
use andromeda_bitcoin::{AddressInfo, KeychainKind};

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

#[cfg(test)]
mod tests {
    use super::*;
    use andromeda_bitcoin::{Address, AddressInfo, KeychainKind};
    use std::str::FromStr;

    fn mock_address_info() -> AddressInfo {
        AddressInfo {
            index: 1,
            address: Address::from_str("tb1qnmsyczn68t628m4uct5nqgjr7vf3w6mc0lvkfn")
                .unwrap()
                .assume_checked(),
            keychain: KeychainKind::External,
        }
    }

    #[test]
    fn test_conversion_from_address_info() {
        let address_info = mock_address_info();
        let frb_address_info: FrbAddressInfo = address_info.clone().into();

        assert_eq!(frb_address_info.index, address_info.index);
        assert_eq!(frb_address_info.address, address_info.address.to_string());
        assert_eq!(frb_address_info.keychain, address_info.keychain);
    }
}
