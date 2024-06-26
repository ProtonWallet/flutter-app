use andromeda_api::email_integration::ApiWalletBitcoinAddressLookup;
use andromeda_api::wallet::{ApiWalletSettings, ApiWalletTransaction, CreateWalletRequestBody};

pub use andromeda_api::wallet::{ApiWallet, ApiWalletData, ApiWalletKey};

use andromeda_api::bitcoin_address::ApiBitcoinAddressCreationPayload;
use flutter_rust_bridge::frb;

use super::exchange_rate::ProtonExchangeRate;

/// exposes
pub use andromeda_api::bitcoin_address::ApiWalletBitcoinAddress;

#[derive(Debug)]
pub struct WalletTransaction {
    pub id: String,
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

#[derive(Debug)]
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

#[derive(Debug)]
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
    pub is_auto_created: Option<u8>,
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
