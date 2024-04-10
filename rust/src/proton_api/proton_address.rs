use andromeda_api::proton_email_address::{ApiProtonAddress, ApiProtonAddressKey};

#[derive(Debug)]
pub struct ProtonAddress {
    pub id: String,
    pub domain_id: String,
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

#[derive(Debug)]
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
