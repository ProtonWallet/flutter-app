use crate::types::{Network, OutPoint};
use bdk::miniscript::descriptor::DescriptorKeyParseError;

/// Errors that can be thrown by the [`Wallet`](crate::wallet::Wallet)
#[derive(Debug)]
pub enum Error {
    /// Wrong number of bytes found when trying to convert to u32
    InvalidU32Bytes(Vec<u8>),
    /// Generic error
    Generic(String),
    /// This error is thrown when trying to convert Bare and Public key script to address
    ScriptDoesntHaveAddressForm,
    /// Cannot build a tx without recipients
    NoRecipients,
    /// `manually_selected_only` option is selected but no utxo has been passed
    NoUtxosSelected,
    /// Output created is under the dust limit, 546 satoshis
    OutputBelowDustLimit(usize),
    /// Wallet's UTXO set is not enough to cover recipient's requested plus fee
    InsufficientFunds {
        /// Sats needed for some transaction
        needed: u64,
        /// Sats available for spending
        available: u64,
    },
    /// Branch and bound coin selection possible attempts with sufficiently big UTXO set could grow
    /// exponentially, thus a limit is set, and when hit, this error is thrown
    BnBTotalTriesExceeded,
    /// Branch and bound coin selection tries to avoid needing a change by finding the right inputs for
    /// the desired outputs plus fee, if there is not such combination this error is thrown
    BnBNoExactMatch,
    /// Happens when trying to spend an UTXO that is not in the internal database
    UnknownUtxo,
    /// Thrown when a tx is not found in the internal database
    TransactionNotFound,
    /// Happens when trying to bump a transaction that is already confirmed
    TransactionConfirmed,
    /// Trying to replace a tx that has a sequence >= `0xFFFFFFFE`
    IrreplaceableTransaction,
    /// When bumping a tx the fee rate requested is lower than required
    FeeRateTooLow {
        /// Required fee rate (satoshi/vbyte)
        required: f32,
    },
    /// When bumping a tx the absolute fee requested is lower than replaced tx absolute fee
    FeeTooLow {
        /// Required fee absolute value (satoshi)
        required: u64,
    },
    /// Node doesn't have data to estimate a fee rate
    FeeRateUnavailable,
    MissingKeyOrigin(String),
    /// Error while working with keys
    Key(String),
    /// Descriptor checksum mismatch
    ChecksumMismatch,
    /// Spending policy is not compatible with this [`KeychainKind`]
    SpendingPolicyRequired(crate::types::KeychainKind),
    /// Error while extracting and manipulating policies
    #[allow(clippy::enum_variant_names)]
    InvalidPolicyPathError(String),
    /// Signing error
    Signer(String),
    /// Invalid network
    InvalidNetwork {
        /// requested network, for example what is given as bdk-cli option
        requested: Network,
        /// found network, for example the network of the bitcoin node
        found: Network,
    },

    /// Requested outpoint doesn't exist in the tx (vout greater than available outputs)
    InvalidOutpoint(OutPoint),

    /// Error related to the parsing and usage of descriptors
    Descriptor(String),
    /// Encoding error
    Encode(String),
    /// Miniscript error
    Miniscript(String),
    /// Miniscript PSBT error
    MiniscriptPsbt(String),
    /// BIP32 error
    Bip32(String),
    /// A secp256k1 error
    Secp256k1(String),
    /// Error serializing or deserializing JSON data
    Json(String),
    /// Hex decoding error
    Hex(String),
    /// Partially signed bitcoin transaction error
    Psbt(String),
    /// Partially signed bitcoin transaction parse error
    PsbtParse(String),

    ///  sync attempt failed due to missing scripts in cache which
    /// are needed to satisfy `stop_gap`.
    MissingCachedScripts(usize, usize),
    /// Electrum client error
    Electrum(String),
    /// Esplora client error
    Esplora(String),

    /// Sled database error
    Sled(String),
    /// Rpc client error
    Rpc(String),
    /// Rusqlite client error
    Rusqlite(String),
}

impl From<bdk::Error> for Error {
    fn from(value: bdk::Error) -> Self {
        match value {
            bdk::Error::InvalidU32Bytes(e) => Error::InvalidU32Bytes(e),
            bdk::Error::Generic(e) => Error::Generic(e),
            bdk::Error::ScriptDoesntHaveAddressForm => Error::ScriptDoesntHaveAddressForm,
            bdk::Error::NoRecipients => Error::NoRecipients,
            bdk::Error::NoUtxosSelected => Error::NoUtxosSelected,
            bdk::Error::OutputBelowDustLimit(e) => Error::OutputBelowDustLimit(e),
            bdk::Error::InsufficientFunds { needed, available } => {
                Error::InsufficientFunds { needed, available }
            }
            bdk::Error::BnBTotalTriesExceeded => Error::BnBTotalTriesExceeded,
            bdk::Error::BnBNoExactMatch => Error::BnBNoExactMatch,
            bdk::Error::UnknownUtxo => Error::UnknownUtxo,
            bdk::Error::TransactionNotFound => Error::TransactionNotFound,
            bdk::Error::TransactionConfirmed => Error::TransactionConfirmed,
            bdk::Error::IrreplaceableTransaction => Error::IrreplaceableTransaction,
            bdk::Error::FeeRateTooLow { required } => Error::FeeRateTooLow {
                required: required.as_sat_per_vb(),
            },
            bdk::Error::FeeTooLow { required } => Error::FeeTooLow { required },
            bdk::Error::FeeRateUnavailable => Error::FeeRateUnavailable,
            bdk::Error::MissingKeyOrigin(e) => Error::MissingKeyOrigin(e),
            bdk::Error::Key(e) => Error::Key(e.to_string()),
            bdk::Error::ChecksumMismatch => Error::ChecksumMismatch,
            bdk::Error::SpendingPolicyRequired(e) => Error::SpendingPolicyRequired(e.into()),
            bdk::Error::InvalidPolicyPathError(e) => Error::InvalidPolicyPathError(e.to_string()),
            bdk::Error::Signer(e) => Error::Signer(e.to_string()),
            bdk::Error::InvalidNetwork { requested, found } => Error::InvalidNetwork {
                requested: requested.into(),
                found: found.into(),
            },
            bdk::Error::InvalidOutpoint(e) => Error::InvalidOutpoint(e.into()),
            bdk::Error::Descriptor(e) => Error::Descriptor(e.to_string()),
            bdk::Error::Encode(e) => Error::Encode(e.to_string()),
            bdk::Error::Miniscript(e) => Error::Miniscript(e.to_string()),
            bdk::Error::MiniscriptPsbt(e) => Error::MiniscriptPsbt(e.to_string()),
            bdk::Error::Bip32(e) => Error::Bip32(e.to_string()),
            bdk::Error::Secp256k1(e) => Error::Secp256k1(e.to_string()),
            bdk::Error::Json(e) => Error::Json(e.to_string()),
            bdk::Error::Hex(e) => Error::Hex(e.to_string()),
            bdk::Error::Psbt(e) => Error::Psbt(e.to_string()),
            bdk::Error::PsbtParse(e) => Error::PsbtParse(e.to_string()),
            bdk::Error::MissingCachedScripts(e) => {
                Error::MissingCachedScripts(e.missing_count, e.last_count)
            }
            bdk::Error::Electrum(e) => Error::Electrum(e.to_string()),
            bdk::Error::Esplora(e) => Error::Esplora(e.to_string()),
            bdk::Error::Sled(e) => Error::Sled(e.to_string()),
            bdk::Error::Rpc(e) => Error::Rpc(e.to_string()),
            bdk::Error::Rusqlite(e) => Error::Rusqlite(e.to_string()),
            _ => Error::Generic("".to_string()),
        }
    }
}
impl From<bdk::miniscript::Error> for Error {
    fn from(value: bdk::miniscript::Error) -> Self {
        Error::Miniscript(value.to_string())
    }
}
impl From<DescriptorKeyParseError> for Error {
    fn from(value: DescriptorKeyParseError) -> Self {
        Error::Descriptor(value.to_string())
    }
}

impl From<bdk::bitcoin::locktime::Error> for Error {
    fn from(value: bdk::bitcoin::locktime::Error) -> Self {
        Error::Miniscript(value.to_string())
    }
}

impl From<serde_json::Error> for Error {
    fn from(value: serde_json::Error) -> Self {
        Error::Json(value.to_string())
    }
}
