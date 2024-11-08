use andromeda_api::proton_email_address::{
    ApiAllKeyAddressKey, ApiProtonAddress, ApiProtonAddressKey,
};

#[derive(Debug)]
pub struct AllKeyAddressKey {
    pub flags: u32,
    pub public_key: String,
    pub source: u32,
}

impl From<ApiAllKeyAddressKey> for AllKeyAddressKey {
    fn from(all_key_address_key: ApiAllKeyAddressKey) -> Self {
        AllKeyAddressKey {
            flags: all_key_address_key.Flags,
            public_key: all_key_address_key.PublicKey,
            source: all_key_address_key.Source,
        }
    }
}

#[derive(Debug)]
pub struct ProtonAddress {
    pub id: String,
    pub domain_id: Option<String>,
    pub email: String,
    pub status: u32,
    pub r#type: u32,
    pub receive: u32,
    pub send: u32,
    pub display_name: String,
    pub keys: Option<Vec<ProtonAddressKey>>,
}

impl From<ApiProtonAddress> for ProtonAddress {
    fn from(proton_address: ApiProtonAddress) -> Self {
        ProtonAddress {
            id: proton_address.ID,
            domain_id: proton_address.DomainID,
            email: proton_address.Email,
            status: proton_address.Status,
            r#type: proton_address.Type,
            receive: proton_address.Receive,
            send: proton_address.Send,
            display_name: proton_address.DisplayName,
            keys: proton_address
                .Keys
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
        }
    }
}

#[derive(Debug, Clone)]
pub struct ProtonAddressKey {
    pub id: String,
    pub version: u32,
    pub public_key: String,
    pub private_key: Option<String>,
    pub token: Option<String>,
    pub signature: Option<String>,
    pub primary: u32,
    pub active: u32,
    pub flags: u32,
}

impl From<ApiProtonAddressKey> for ProtonAddressKey {
    fn from(proton_address_key: ApiProtonAddressKey) -> Self {
        ProtonAddressKey {
            id: proton_address_key.ID,
            version: proton_address_key.Version,
            public_key: proton_address_key.PublicKey,
            private_key: proton_address_key.PrivateKey,
            token: proton_address_key.Token,
            signature: proton_address_key.Signature,
            primary: proton_address_key.Primary,
            active: proton_address_key.Active,
            flags: proton_address_key.Flags,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use andromeda_api::proton_email_address::{
        ApiAllKeyAddressKey, ApiProtonAddress, ApiProtonAddressKey,
    };

    fn mock_api_all_key_address_key() -> ApiAllKeyAddressKey {
        ApiAllKeyAddressKey {
            Flags: 1,
            PublicKey: "test_public_key".to_string(),
            Source: 123,
        }
    }

    fn mock_api_proton_address_key() -> ApiProtonAddressKey {
        ApiProtonAddressKey {
            ID: "key_id_1".to_string(),
            Version: 1,
            PublicKey: "test_public_key".to_string(),
            PrivateKey: Some("private_key".to_string()),
            Token: None,
            Signature: None,
            Primary: 1,
            Active: 1,
            Flags: 0,
        }
    }

    fn mock_api_proton_address() -> ApiProtonAddress {
        ApiProtonAddress {
            ID: "address_id".to_string(),
            DomainID: Some("domain_id".to_string()),
            Email: "test@example.com".to_string(),
            Status: 1,
            Type: 1,
            Receive: 1,
            Send: 1,
            DisplayName: "Test Display".to_string(),
            Keys: Some(vec![mock_api_proton_address_key()]),
        }
    }

    #[test]
    fn test_all_key_address_key_conversion() {
        let api_key = mock_api_all_key_address_key();
        let key: AllKeyAddressKey = api_key.into();

        assert_eq!(key.flags, 1);
        assert_eq!(key.public_key, "test_public_key");
        assert_eq!(key.source, 123);
    }

    #[test]
    fn test_proton_address_conversion() {
        let api_address = mock_api_proton_address();
        let address: ProtonAddress = api_address.into();

        assert_eq!(address.id, "address_id");
        assert_eq!(address.email, "test@example.com");
        assert!(address.keys.is_some());
        assert_eq!(address.keys.unwrap().len(), 1);
    }

    #[test]
    fn test_proton_address_key_conversion() {
        let api_key = mock_api_proton_address_key();
        let key: ProtonAddressKey = api_key.into();

        assert_eq!(key.id, "key_id_1");
        assert_eq!(key.public_key, "test_public_key");
        assert_eq!(key.version, 1);
        assert!(key.private_key.is_some());
    }
}
