use andromeda_api::email_integration::ApiWalletBitcoinAddressLookup;
use andromeda_api::wallet::{
    ApiWallet, ApiWalletKey, ApiWalletTransaction, CreateWalletRequestBody,
};

use andromeda_api::bitcoin_address::{ApiBitcoinAddressCreationPayload, ApiWalletBitcoinAddress};

use super::exchange_rate::ProtonExchangeRate;
use super::wallet_settings::WalletSettings;

#[derive(Debug)]
pub struct ProtonWallet {
    pub id: String,
    pub has_passphrase: u8,
    pub is_imported: u8,
    pub mnemonic: Option<String>,
    pub name: String,
    pub priority: u8,
    pub public_key: Option<String>,
    pub status: u8,
    pub r#type: u8,
    pub fingerprint: Option<String>,
}
impl From<ApiWallet> for ProtonWallet {
    fn from(wallet: ApiWallet) -> Self {
        ProtonWallet {
            id: wallet.ID,
            has_passphrase: wallet.HasPassphrase,
            is_imported: wallet.IsImported,
            mnemonic: wallet.Mnemonic,
            name: wallet.Name,
            priority: wallet.Priority,
            public_key: wallet.PublicKey,
            status: wallet.Status,
            r#type: wallet.Type,
            fingerprint: wallet.Fingerprint,
        }
    }
}

#[derive(Debug)]
pub struct WalletTransaction {
    pub id: String,
    pub wallet_id: String,
    pub wallet_account_id: Option<String>,
    pub label: Option<String>,
    pub transaction_id: String,
    pub transaction_time: String,
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

#[derive(Debug)]
pub struct WalletBitcoinAddress {
    pub id: String,
    pub wallet_id: String,
    pub wallet_account_id: String,
    pub fetched: u8,
    pub used: u8,
    pub bitcoin_address: Option<String>,
    pub bitcoin_address_signature: Option<String>,
    pub bitcoin_address_index: Option<u64>,
}
impl From<ApiWalletBitcoinAddress> for WalletBitcoinAddress {
    fn from(wallet_bitcoin_address: ApiWalletBitcoinAddress) -> Self {
        WalletBitcoinAddress {
            id: wallet_bitcoin_address.ID,
            wallet_id: wallet_bitcoin_address.WalletID,
            wallet_account_id: wallet_bitcoin_address.WalletAccountID,
            fetched: wallet_bitcoin_address.Fetched,
            used: wallet_bitcoin_address.Used,
            bitcoin_address: wallet_bitcoin_address.BitcoinAddress,
            bitcoin_address_signature: wallet_bitcoin_address.BitcoinAddressSignature,
            bitcoin_address_index: wallet_bitcoin_address.BitcoinAddressIndex,
        }
    }
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

#[derive(Debug)]
pub struct ProtonWalletKey {
    pub wallet_id: String,
    pub user_key_id: String,
    pub wallet_key: String,
    pub wallet_key_signature: String,
}
impl From<ApiWalletKey> for ProtonWalletKey {
    fn from(wallet_key: ApiWalletKey) -> Self {
        ProtonWalletKey {
            wallet_id: wallet_key.WalletID,
            user_key_id: wallet_key.UserKeyID,
            wallet_key: wallet_key.WalletKey,
            wallet_key_signature: wallet_key.WalletKeySignature,
        }
    }
}

#[derive(Debug)]
pub struct WalletData {
    pub wallet: ProtonWallet,
    pub wallet_key: ProtonWalletKey,
    pub wallet_settings: WalletSettings,
}
impl From<andromeda_api::wallet::ApiWalletData> for WalletData {
    fn from(wallet_data: andromeda_api::wallet::ApiWalletData) -> Self {
        WalletData {
            wallet: wallet_data.Wallet.into(),
            wallet_key: wallet_data.WalletKey.into(),
            wallet_settings: wallet_data.WalletSettings.into(),
        }
    }
}

// #[derive(Debug, Deserialize)]
// pub struct WalletsResponse {
//     pub Code: i32,
//     pub Wallets: Vec<ApiWalletData>,
// }

// #[derive(Debug, Deserialize)]
// pub struct CreateWalletResponse {
//     pub Code: i32,
//     pub ApiWallet: ProtonWallet,
//     pub ApiWalletKey: ProtonWalletKey,
//     pub WalletSettings: WalletSettings,
//     // Error: Option<String>,
// }

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
        }
    }
}
