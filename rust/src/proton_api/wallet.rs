use super::exchange_rate::ProtonExchangeRate;
use andromeda_api::{
    bitcoin_address::ApiBitcoinAddressCreationPayload,
    email_integration::ApiWalletBitcoinAddressLookup,
    wallet::{ApiWalletTransaction, CreateWalletRequestBody},
};
use flutter_rust_bridge::frb;

/// exposes
pub use andromeda_api::{
    bitcoin_address::ApiWalletBitcoinAddress,
    wallet::{
        ApiWallet, ApiWalletData, ApiWalletKey, ApiWalletSettings, MigratedWallet,
        MigratedWalletAccount, MigratedWalletTransaction, TransactionType,
    },
};

#[frb(mirror(TransactionType))]
pub enum _TransactionType {
    NotSend = 0,
    ProtonToProtonSend = 1,
    ProtonToProtonReceive = 2,
    ExternalSend = 3,
    ExternalReceive = 4,
    Unsupported = 99,
}

#[derive(Debug)]
pub struct WalletTransaction {
    pub id: String,
    pub r#type: Option<TransactionType>,
    pub wallet_id: String,
    pub wallet_account_id: Option<String>,
    pub label: Option<String>,
    pub transaction_id: String,
    pub transaction_time: String,
    pub is_suspicious: u8,
    pub is_private: u8,
    pub exchange_rate: Option<ProtonExchangeRate>,
    pub hashed_transaction_id: Option<String>,
    pub subject: Option<String>,
    pub body: Option<String>,
    pub sender: Option<String>,
    pub tolist: Option<String>,
}
impl From<ApiWalletTransaction> for WalletTransaction {
    fn from(wallet_transaction: ApiWalletTransaction) -> Self {
        WalletTransaction {
            id: wallet_transaction.ID,
            r#type: wallet_transaction.Type,
            wallet_id: wallet_transaction.WalletID,
            wallet_account_id: wallet_transaction.WalletAccountID,
            label: wallet_transaction.Label,
            transaction_id: wallet_transaction.TransactionID,
            transaction_time: wallet_transaction.TransactionTime,
            is_suspicious: wallet_transaction.IsSuspicious,
            is_private: wallet_transaction.IsPrivate,
            exchange_rate: wallet_transaction.ExchangeRate.map(|v| v.into()),
            hashed_transaction_id: wallet_transaction.HashedTransactionID,
            subject: wallet_transaction.Subject,
            body: wallet_transaction.Body,
            sender: wallet_transaction.Sender,
            tolist: wallet_transaction.ToList,
        }
    }
}

#[derive(Debug)]
pub struct EmailIntegrationBitcoinAddress {
    pub bitcoin_address: Option<String>,
    pub bitcoin_address_signature: Option<String>,
}
impl From<ApiWalletBitcoinAddressLookup> for EmailIntegrationBitcoinAddress {
    fn from(wallet_bitcoin_address: ApiWalletBitcoinAddressLookup) -> Self {
        EmailIntegrationBitcoinAddress {
            bitcoin_address: wallet_bitcoin_address.BitcoinAddress,
            bitcoin_address_signature: wallet_bitcoin_address.BitcoinAddressSignature,
        }
    }
}

#[frb(mirror(ApiWalletBitcoinAddress))]
#[allow(non_snake_case)]
pub struct _ApiWalletBitcoinAddress {
    pub ID: String,
    pub WalletID: String,
    pub WalletAccountID: String,
    pub Fetched: u8,
    pub Used: u8,
    pub BitcoinAddress: Option<String>,
    pub BitcoinAddressSignature: Option<String>,
    pub BitcoinAddressIndex: Option<u64>,
}

#[derive(Debug, Clone)]
pub struct BitcoinAddress {
    pub bitcoin_address: String,
    pub bitcoin_address_signature: String,
    pub bitcoin_address_index: u64,
}
impl From<ApiBitcoinAddressCreationPayload> for BitcoinAddress {
    fn from(wallet_bitcoin_address: ApiBitcoinAddressCreationPayload) -> Self {
        BitcoinAddress {
            bitcoin_address: wallet_bitcoin_address.BitcoinAddress,
            bitcoin_address_signature: wallet_bitcoin_address.BitcoinAddressSignature,
            bitcoin_address_index: wallet_bitcoin_address.BitcoinAddressIndex,
        }
    }
}
impl From<BitcoinAddress> for ApiBitcoinAddressCreationPayload {
    fn from(wallet_bitcoin_address: BitcoinAddress) -> Self {
        ApiBitcoinAddressCreationPayload {
            BitcoinAddress: wallet_bitcoin_address.bitcoin_address,
            BitcoinAddressSignature: wallet_bitcoin_address.bitcoin_address_signature,
            BitcoinAddressIndex: wallet_bitcoin_address.bitcoin_address_index,
        }
    }
}

#[frb(mirror(ApiWallet))]
#[allow(non_snake_case)]
pub struct _ApiWallet {
    pub ID: String,
    /// Name of the wallet
    pub Name: String,
    /// 0 if the wallet is created with Proton Wallet
    pub IsImported: u8,
    /// Priority of the wallet (0 is main wallet)
    pub Priority: u8,
    /// 1 is onchain, 2 is lightning
    pub Type: u8,
    /// 1 if the wallet has a passphrase. We don't store it but clients need to
    /// request on first wallet access.
    pub HasPassphrase: u8,
    /// 1 means disabled
    pub Status: u8,
    /// Wallet mnemonic encrypted with the WalletKey, in base64 format
    pub Mnemonic: Option<String>,
    // Unique identifier of the mnemonic, using the first 4 bytes of the master public key hash
    pub Fingerprint: Option<String>,
    /// Wallet master public key encrypted with the WalletKey, in base64 format.
    /// Only allows fetching coins owned by wallet, no spending allowed.
    pub PublicKey: Option<String>,
    /// Temporary field to tell clients to re-encrypt WalletKey
    pub MigrationRequired: Option<u8>,
    /// Field to tell clients if mnemonic uses a legacy encryption scheme
    pub Legacy: Option<u8>,
}

#[frb(mirror(ApiWalletKey))]
#[allow(non_snake_case)]
pub struct _ApiWalletKey {
    pub WalletID: String,
    pub UserKeyID: String,
    pub WalletKey: String,
    pub WalletKeySignature: String,
}

#[frb(mirror(ApiWalletData))]
#[allow(non_snake_case)]
pub struct _ApiWalletData {
    pub Wallet: ApiWallet,
    pub WalletKey: ApiWalletKey,
    pub WalletSettings: ApiWalletSettings,
}

#[derive(Debug, Clone)]
pub struct CreateWalletReq {
    // Name of the wallet
    pub name: String,
    // 0 if the wallet is created with Proton ApiWallet
    pub is_imported: u8,
    // Enum: 1 2
    pub r#type: u8,
    // 1 if the wallet has a passphrase
    pub has_passphrase: u8,
    //An encrypted ID
    pub user_key_id: String,
    // Base64 encoded binary data
    pub wallet_key: String,
    // "<base64_encoded_mnemonic>",
    // Encrypted wallet mnemonic with the ApiWalletKey, in base64 format
    pub mnemonic: Option<String>,
    // "<base64_encoded_publickey>"
    // Encrypted wallet public key with the ApiWalletKey, in base64 format
    pub public_key: Option<String>,

    pub fingerprint: Option<String>,
    pub wallet_key_signature: String,

    /// Flag that indicates the wallet is created from auto creation. 0 for no,
    /// 1 for yes
    pub is_auto_created: u8,
}

impl From<CreateWalletRequestBody> for CreateWalletReq {
    fn from(req: CreateWalletRequestBody) -> Self {
        CreateWalletReq {
            name: req.Name,
            is_imported: req.IsImported,
            r#type: req.Type,
            has_passphrase: req.HasPassphrase,
            user_key_id: req.UserKeyID,
            wallet_key: req.WalletKey,
            mnemonic: req.Mnemonic,
            public_key: req.PublicKey,
            fingerprint: req.Fingerprint,
            wallet_key_signature: req.WalletKeySignature,
            is_auto_created: req.IsAutoCreated,
        }
    }
}

impl From<CreateWalletReq> for CreateWalletRequestBody {
    fn from(req: CreateWalletReq) -> Self {
        CreateWalletRequestBody {
            Name: req.name,
            IsImported: req.is_imported,
            Type: req.r#type,
            HasPassphrase: req.has_passphrase,
            UserKeyID: req.user_key_id,
            WalletKey: req.wallet_key,
            Mnemonic: req.mnemonic,
            PublicKey: req.public_key,
            Fingerprint: req.fingerprint,
            WalletKeySignature: req.wallet_key_signature,
            IsAutoCreated: req.is_auto_created,
        }
    }
}

#[frb(mirror(MigratedWallet))]
#[allow(non_snake_case)]
pub struct _MigratedWallet {
    /// Name of the wallet, encrypted
    pub Name: String,
    /// Encrypted user Id
    pub UserKeyID: String,
    /// Base64 encoded binary data
    pub WalletKey: String,
    /// Detached signature of the encrypted AES-GCM 256 key used to encrypt the
    /// mnemonic or public key, as armored PGP
    pub WalletKeySignature: String,
    /// Wallet mnemonic encrypted with the WalletKey, in base64 format
    pub Mnemonic: String,
    pub Fingerprint: String,
}

#[frb(mirror(MigratedWalletAccount))]
#[allow(non_snake_case)]
pub struct _MigratedWalletAccount {
    // Wallet account ID
    pub ID: String,
    // Encrypted Label
    pub Label: String,
}

#[frb(mirror(MigratedWalletTransaction))]
#[allow(non_snake_case)]
pub struct _MigratedWalletTransaction {
    // Wallet ID
    pub ID: String,
    pub WalletAccountID: String,
    // encrypted transaction ID
    pub HashedTransactionID: Option<String>,
    // encrypted label
    pub Label: Option<String>,
}

#[cfg(test)]
mod tests {
    use super::*;
    use andromeda_api::{
        bitcoin_address::ApiBitcoinAddressCreationPayload,
        wallet::{ApiWalletTransaction, CreateWalletRequestBody, TransactionType},
    };

    fn mock_api_wallet_transaction() -> ApiWalletTransaction {
        ApiWalletTransaction {
            ID: "transaction_id_1".to_string(),
            Type: Some(TransactionType::ProtonToProtonSend),
            WalletID: "wallet_id_1".to_string(),
            WalletAccountID: Some("wallet_account_id_1".to_string()),
            Label: Some("Test Label".to_string()),
            TransactionID: "txid_123".to_string(),
            TransactionTime: "2024-10-22T12:00:00Z".to_string(),
            IsSuspicious: 0,
            IsPrivate: 1,
            ExchangeRate: None, // Simplified for this test
            HashedTransactionID: Some("hashed_txid_123".to_string()),
            Subject: Some("Test Subject".to_string()),
            Body: Some("Test Body".to_string()),
            Sender: Some("test_sender@example.com".to_string()),
            ToList: Some("test_recipient@example.com".to_string()),
        }
    }

    fn mock_api_bitcoin_address_creation_payload() -> ApiBitcoinAddressCreationPayload {
        ApiBitcoinAddressCreationPayload {
            BitcoinAddress: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa".to_string(),
            BitcoinAddressSignature: "signature_123".to_string(),
            BitcoinAddressIndex: 42,
        }
    }

    fn mock_create_wallet_request_body() -> CreateWalletRequestBody {
        CreateWalletRequestBody {
            Name: "Test Wallet".to_string(),
            IsImported: 0,
            Type: 1,
            HasPassphrase: 0,
            UserKeyID: "user_key_123".to_string(),
            WalletKey: "wallet_key_123".to_string(),
            Mnemonic: Some("mnemonic_123".to_string()),
            PublicKey: Some("public_key_123".to_string()),
            Fingerprint: Some("fingerprint_123".to_string()),
            WalletKeySignature: "wallet_signature_123".to_string(),
            IsAutoCreated: 0,
        }
    }

    #[test]
    fn test_wallet_transaction_conversion() {
        let api_txn = mock_api_wallet_transaction();
        let wallet_txn: WalletTransaction = api_txn.into();

        assert_eq!(wallet_txn.id, "transaction_id_1");
        assert_eq!(
            wallet_txn.r#type.unwrap(),
            TransactionType::ProtonToProtonSend
        );
        assert_eq!(wallet_txn.wallet_id, "wallet_id_1");
        assert_eq!(wallet_txn.wallet_account_id.unwrap(), "wallet_account_id_1");
        assert_eq!(wallet_txn.label.unwrap(), "Test Label");
        assert_eq!(wallet_txn.transaction_id, "txid_123");
        assert_eq!(wallet_txn.transaction_time, "2024-10-22T12:00:00Z");
        assert_eq!(wallet_txn.is_suspicious, 0);
        assert_eq!(wallet_txn.is_private, 1);
        assert_eq!(wallet_txn.hashed_transaction_id.unwrap(), "hashed_txid_123");
        assert_eq!(wallet_txn.subject.unwrap(), "Test Subject");
        assert_eq!(wallet_txn.body.unwrap(), "Test Body");
        assert_eq!(wallet_txn.sender.unwrap(), "test_sender@example.com");
        assert_eq!(wallet_txn.tolist.unwrap(), "test_recipient@example.com");
    }

    #[test]
    fn test_email_integration_bitcoin_address() {
        let api_e_i_b_a = ApiWalletBitcoinAddressLookup {
            BitcoinAddress: Some("1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa".to_string()),
            BitcoinAddressSignature: Some("signature_123".to_string()),
        };
        let e_i_b_a: EmailIntegrationBitcoinAddress = api_e_i_b_a.clone().into();
        assert_eq!(e_i_b_a.bitcoin_address, api_e_i_b_a.BitcoinAddress);
        assert_eq!(
            e_i_b_a.bitcoin_address_signature,
            api_e_i_b_a.BitcoinAddressSignature
        );
    }

    #[test]
    fn test_bitcoin_address_conversion() {
        let api_bitcoin_address = mock_api_bitcoin_address_creation_payload();
        let bitcoin_address: BitcoinAddress = api_bitcoin_address.clone().into();

        assert_eq!(
            bitcoin_address.bitcoin_address,
            "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
        );
        assert_eq!(bitcoin_address.bitcoin_address_signature, "signature_123");
        assert_eq!(bitcoin_address.bitcoin_address_index, 42);

        let back_to_api: ApiBitcoinAddressCreationPayload = bitcoin_address.into();
        assert_eq!(
            back_to_api.BitcoinAddress,
            api_bitcoin_address.BitcoinAddress
        );
        assert_eq!(
            back_to_api.BitcoinAddressSignature,
            api_bitcoin_address.BitcoinAddressSignature
        );
        assert_eq!(
            back_to_api.BitcoinAddressIndex,
            api_bitcoin_address.BitcoinAddressIndex
        );
    }

    #[test]
    fn test_create_wallet_request_conversion() {
        let api_wallet_req = mock_create_wallet_request_body();
        let wallet_req: CreateWalletReq = api_wallet_req.clone().into();

        assert_eq!(wallet_req.name, "Test Wallet");
        assert_eq!(wallet_req.is_imported, 0);
        assert_eq!(wallet_req.r#type, 1);
        assert_eq!(wallet_req.has_passphrase, 0);
        assert_eq!(wallet_req.user_key_id, "user_key_123");
        assert_eq!(wallet_req.wallet_key, "wallet_key_123");
        assert_eq!(wallet_req.mnemonic.clone().unwrap(), "mnemonic_123");
        assert_eq!(wallet_req.public_key.clone().unwrap(), "public_key_123");
        assert_eq!(wallet_req.fingerprint.clone().unwrap(), "fingerprint_123");
        assert_eq!(wallet_req.wallet_key_signature, "wallet_signature_123");
        assert_eq!(wallet_req.is_auto_created, 0);

        let back_to_api: CreateWalletRequestBody = wallet_req.into();
        assert_eq!(back_to_api.Name, api_wallet_req.Name);
        assert_eq!(back_to_api.IsImported, api_wallet_req.IsImported);
        assert_eq!(back_to_api.Type, api_wallet_req.Type);
        assert_eq!(back_to_api.HasPassphrase, api_wallet_req.HasPassphrase);
        assert_eq!(back_to_api.UserKeyID, api_wallet_req.UserKeyID);
        assert_eq!(back_to_api.WalletKey, api_wallet_req.WalletKey);
        assert_eq!(
            back_to_api.Mnemonic.unwrap(),
            api_wallet_req.Mnemonic.unwrap()
        );
        assert_eq!(
            back_to_api.PublicKey.unwrap(),
            api_wallet_req.PublicKey.unwrap()
        );
        assert_eq!(
            back_to_api.Fingerprint.unwrap(),
            api_wallet_req.Fingerprint.unwrap()
        );
        assert_eq!(
            back_to_api.WalletKeySignature,
            api_wallet_req.WalletKeySignature
        );
        assert_eq!(back_to_api.IsAutoCreated, api_wallet_req.IsAutoCreated);
    }
}
