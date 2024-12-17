use core::str;

use andromeda_api::{proton_users::ProtonUserKey, wallet::ApiWalletKey};
use flutter_rust_bridge::frb;
use proton_crypto::{
    crypto::{DataEncoding, PGPProvider, PGPProviderSync, Signer, SignerSync},
    new_pgp_provider,
};
use proton_crypto_account::{
    keys::{AddressKeys, ArmoredPrivateKey},
    salts::KeySecret,
};

use crate::{
    api::proton_wallet::crypto::wallet_key::{FrbLockedWalletKey, FrbUnlockedWalletKey},
    proton_address::ProtonAddressKey,
    proton_wallet::{
        crypto::{
            binary::Binary,
            message::Message,
            mnemonic_legacy::EncryptedWalletMnemonicLegacy,
            private_key::LockedPrivateKeys,
            public_key::PublicKeys,
            transaction_id::{EncryptedWalletTransactionID, WalletTransactionID},
            wallet_bitcoin_address::WalletBTCAddress,
            wallet_key::LockedWalletKey,
            wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
            wallet_message::WalletMessage,
        },
        features::error::FeaturesError,
        storage::{
            address_key_ext::{AddressKeyWrap, AddressKeysWrap},
            user_key_ext::{UserKeyWrap, UserKeysWrap},
        },
    },
    BridgeError,
};

/// this is a transition layer for the proton wallet move business logics from Dart to rust.
/// this file will be tempary and will be removed once all the business logics are moved to rust.
pub struct FrbTransitionLayer {}

pub struct FrbTLEncryptedTransactionID {
    pub encrypted_transaction_id: String,
    pub index: u32,
}

pub struct FrbTLTransactionID {
    pub transaction_id: String,
    pub index: u32,
}

#[derive(Debug, Default)]
pub struct FrbSenderBody {
    pub to_list: String,
    pub sender: String,
    pub body: String,
}

impl FrbTransitionLayer {
    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn decrypt_transaction_ids(
        user_keys: Vec<ProtonUserKey>,
        addr_keys: Vec<ProtonAddressKey>,
        user_key_password: String,
        enc_transaction_ids: Vec<FrbTLEncryptedTransactionID>,
    ) -> Result<Vec<FrbTLTransactionID>, BridgeError> {
        let provider = new_pgp_provider();
        let user_key_secret = KeySecret::new(user_key_password.into_bytes());

        let crypto_user_keys = UserKeysWrap::new(user_keys).into();
        let crypto_addr_keys = AddressKeysWrap::new(addr_keys).into();
        let locked_private_keys = LockedPrivateKeys::from_keys(crypto_user_keys, crypto_addr_keys);

        let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &user_key_secret);
        enc_transaction_ids
            .into_iter()
            .map(|transaction_id| {
                let decrypted_id =
                    EncryptedWalletTransactionID::from(transaction_id.encrypted_transaction_id)
                        .decrypt_with(&provider, &unlocked_private_keys)
                        .unwrap_or(WalletTransactionID::default())
                        .as_utf8_string()
                        .unwrap_or_default();
                Ok(FrbTLTransactionID {
                    index: transaction_id.index,
                    transaction_id: decrypted_id,
                })
            })
            .collect()
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn decrypt_transaction_id(
        user_keys: Vec<ProtonUserKey>,
        addr_keys: Vec<ProtonAddressKey>,
        user_key_password: String,
        enc_transaction_id: String,
    ) -> Result<String, BridgeError> {
        let provider = new_pgp_provider();
        let user_key_secret = KeySecret::new(user_key_password.into_bytes());

        let crypto_user_keys = UserKeysWrap::new(user_keys).into();
        let crypto_addr_keys = AddressKeysWrap::new(addr_keys).into();
        let locked_private_keys = LockedPrivateKeys::from_keys(crypto_user_keys, crypto_addr_keys);
        let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &user_key_secret);

        let decrypted_id = EncryptedWalletTransactionID::from(enc_transaction_id)
            .decrypt_with(&provider, &unlocked_private_keys)
            .unwrap_or(WalletTransactionID::default())
            .as_utf8_string()
            .unwrap_or_default();

        Ok(decrypted_id)
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn decrypt_messages(
        user_keys: Vec<ProtonUserKey>,
        addr_keys: Vec<ProtonAddressKey>,
        user_key_password: String,
        enc_to_list: Option<String>,
        enc_sender: Option<String>,
        enc_body: Option<String>,
    ) -> Result<FrbSenderBody, BridgeError> {
        let provider = new_pgp_provider();
        let user_key_secret = KeySecret::new(user_key_password.into_bytes());

        let crypto_user_keys = UserKeysWrap::new(user_keys).into();
        let crypto_addr_keys = AddressKeysWrap::new(addr_keys.into()).into();
        let locked_private_keys = LockedPrivateKeys::from_keys(crypto_user_keys, crypto_addr_keys);

        let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &user_key_secret);

        let to_list = enc_to_list
            .and_then(|enc_message| {
                let clear = EncryptedWalletTransactionID::from(enc_message)
                    .decrypt_with(&provider, &unlocked_private_keys)
                    .and_then(|decrypted_id| decrypted_id.as_utf8_string());
                Some(clear.unwrap_or_default())
            })
            .unwrap_or_default();

        let sender = enc_sender
            .and_then(|enc_message| {
                let clear = EncryptedWalletTransactionID::from(enc_message)
                    .decrypt_with(&provider, &unlocked_private_keys)
                    .and_then(|decrypted_id| decrypted_id.as_utf8_string());
                Some(clear.unwrap_or_default())
            })
            .unwrap_or_default();

        let body = enc_body
            .and_then(|enc_message| {
                let clear = EncryptedWalletTransactionID::from(enc_message)
                    .decrypt_with(&provider, &unlocked_private_keys)
                    .and_then(|decrypted_id| decrypted_id.as_utf8_string());
                Some(clear.unwrap_or_default())
            })
            .unwrap_or_default();

        Ok(FrbSenderBody {
            to_list,
            sender,
            body,
        })
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn encrypt_messages_with_keys(
        private_keys: Vec<String>,
        message: String,
        user_keys: Option<Vec<ProtonUserKey>>,
        addr_keys: Option<Vec<ProtonAddressKey>>,
        user_key_password: Option<String>,
    ) -> Result<String, BridgeError> {
        let message = WalletMessage::new_from_str(&message);
        let provider = new_pgp_provider();
        let mut encryptor_keys = PublicKeys::default();
        for private_key in private_keys {
            encryptor_keys.add_armored_key(&provider, &ArmoredPrivateKey(private_key))?
        }
        let signer = if let (Some(user_keys), Some(addr_keys), Some(user_key_password)) =
            (user_keys, addr_keys, user_key_password)
        {
            let user_key_secret = KeySecret::new(user_key_password.into_bytes());
            let crypto_user_keys = UserKeysWrap::new(user_keys).into();
            let crypto_addr_keys = AddressKeysWrap::new(addr_keys.into()).into();
            let locked_private_keys =
                LockedPrivateKeys::from_keys(crypto_user_keys, crypto_addr_keys);
            let unlocked_private_keys =
                locked_private_keys.unlock_with(&provider, &user_key_secret);
            Some(unlocked_private_keys)
        } else {
            None
        };
        let encrypted_label = message.encrypt_with(&provider, &encryptor_keys, signer.as_ref())?;
        Ok(encrypted_label.as_armored()?)
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn encrypt_messages_with_userkey(
        user_key: ProtonUserKey,
        message: String,
    ) -> Result<String, BridgeError> {
        let message = WalletMessage::new_from_str(&message);
        let provider = new_pgp_provider();
        let mut encryptor_keys = PublicKeys::default();
        let locked_address_keys = AddressKeys(UserKeysWrap::new(vec![user_key]).into());
        encryptor_keys.add_address_keys(&provider, &locked_address_keys)?;
        let encrypted_label = message.encrypt_with(&provider, &encryptor_keys, None)?;
        Ok(encrypted_label.as_armored()?)
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn decrypt_wallet_key(
        wallet_key: ApiWalletKey,
        user_key: ProtonUserKey,
        user_key_passphrase: String,
    ) -> Result<FrbUnlockedWalletKey, BridgeError> {
        let locked_keys = LockedPrivateKeys::from_primary(UserKeyWrap::new(user_key).into());
        let user_key_secret = KeySecret::new(user_key_passphrase.into_bytes());
        let provider = new_pgp_provider();
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &user_key_secret);
        let locked_wallet_key = LockedWalletKey::from(wallet_key);
        let unlocked = locked_wallet_key.unlock_with(&provider, &unlocked_user_keys.user_keys)?;
        Ok(FrbUnlockedWalletKey::new(unlocked))
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn decrypt_wallet_key_legacy(
        encrypted_mnemonic_text: String,
        user_keys: Vec<ProtonUserKey>,
        user_key_password: String,
    ) -> Result<String, BridgeError> {
        let encrypted_mnemonic_legacy =
            EncryptedWalletMnemonicLegacy::new_from_base64(&encrypted_mnemonic_text)?;
        // userkeys
        let crypto_user_keys = UserKeysWrap::new(user_keys).into();
        let locked_private_keys = LockedPrivateKeys::from_user_keys(crypto_user_keys);
        let user_key_secret = KeySecret::new(user_key_password.into_bytes());

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &user_key_secret);

        // encrypted_mnemonic
        let encrypted_mnemonic =
            encrypted_mnemonic_legacy.decrypt_with(&provider, &unlocked_private_keys)?;

        Ok(encrypted_mnemonic.to_base64())
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn encrypt_wallet_key(
        wallet_key: FrbUnlockedWalletKey,
        user_key: ProtonUserKey,
        user_key_passphrase: String,
    ) -> Result<FrbLockedWalletKey, BridgeError> {
        let locked_keys = LockedPrivateKeys::from_primary(UserKeyWrap::new(user_key).into());
        let user_key_secret = KeySecret::new(user_key_passphrase.into_bytes());
        let provider = new_pgp_provider();
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &user_key_secret);
        let first_key = unlocked_user_keys
            .user_keys
            .first()
            .ok_or(FeaturesError::NoUnlockedUserKeyFound)?;
        let locked_wallet_key = wallet_key.inner.lock_with(&provider, &first_key)?;
        Ok(FrbLockedWalletKey::new(locked_wallet_key))
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn verify_signature(
        // verifier. This is the public key of the signer.
        //  when pass in the private key it will auto parse public key from it.
        verifier: Vec<String>,
        message: String,
        signature: String,
        context: String,
    ) -> Result<bool, BridgeError> {
        let provider = new_pgp_provider();
        let bitcoin_addr = WalletBTCAddress::new_from_str(&message);
        let mut pub_keys = PublicKeys::default();
        let armored_keys: Vec<ArmoredPrivateKey> =
            verifier.into_iter().map(ArmoredPrivateKey::from).collect();
        pub_keys.add_armored_keys(&provider, &armored_keys)?;

        Ok(bitcoin_addr.verify(&provider, &pub_keys, &signature, &context)?)
    }

    #[frb]
    /// Dart async + Rust sync ** handled by Frb thread pool
    pub fn sign(
        user_keys: Vec<ProtonUserKey>,
        addr_keys: ProtonAddressKey,
        user_key_password: String,
        message: String,
        context: String,
    ) -> Result<String, BridgeError> {
        let provider = new_pgp_provider();
        let user_key_secret = KeySecret::new(user_key_password.into_bytes());

        let crypto_user_keys = UserKeysWrap::new(user_keys).into();
        let crypto_addr_keys = vec![AddressKeyWrap::new(addr_keys).into()];
        let locked_private_keys = LockedPrivateKeys::from_keys(crypto_user_keys, crypto_addr_keys);

        let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &user_key_secret);

        let Some(unlocked_address_key) = unlocked_private_keys.addr_keys.first() else {
            return Err(BridgeError::Generic(
                "No unlocked address key found".to_string(),
            ));
        };
        let signing_context = provider.new_signing_context(context.to_owned(), true);
        let signature = provider
            .new_signer()
            .with_signing_key(unlocked_address_key.as_ref())
            .with_signing_context(&signing_context)
            .sign_detached(message, DataEncoding::Armor)?;

        Ok(str::from_utf8(&signature)?.to_string())
    }

    #[frb(sync)]
    pub fn get_hmac_hashed_string(
        base64_secure_key: &str,
        transaction_id: &str,
    ) -> Result<String, BridgeError> {
        let wallet_key = WalletKeyProvider::restore_base64(base64_secure_key)?;
        let transaction_id = WalletTransactionID::new_from_str(transaction_id);
        Ok(transaction_id.hmac_hash_with(&wallet_key)?)
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        api::proton_wallet::crypto::wallet_key_helper::FrbWalletKeyHelper,
        mocks::user_keys::tests::{
            get_test_user_1_locked_proton_user_key, get_test_user_1_locked_user_key,
            get_test_user_1_locked_user_key_secret, get_test_user_2_locked_proton_address_key,
            get_test_user_2_locked_proton_user_key, get_test_user_2_locked_user_key,
        },
    };

    use super::FrbTransitionLayer;

    #[test]
    fn test_verify_signature() {
        let user_keys = vec![get_test_user_2_locked_proton_user_key()];
        let addr_key = get_test_user_2_locked_proton_address_key();
        let user_key_password = "password".to_string();

        let message = "你好世界！This is a plaintext message!".to_string();
        let context = "wallet.bitcoin-address".to_string();

        let signature = FrbTransitionLayer::sign(
            user_keys,
            addr_key.clone(),
            user_key_password,
            message.clone(),
            context.clone(),
        )
        .unwrap();

        println!("{}", signature);

        let is_ok = FrbTransitionLayer::verify_signature(
            vec![addr_key.private_key.unwrap()],
            message,
            signature,
            context,
        )
        .unwrap();

        assert!(is_ok);
    }

    #[test]
    fn test_decrypt_messages() {
        let user_keys = vec![get_test_user_2_locked_proton_user_key()];
        let addr_keys = vec![get_test_user_2_locked_proton_address_key()];
        let user_key_password = "password".to_string();
        let enc_to_list = None;
        let enc_sender = None;
        let enc_body = None;

        let decrypted_message = FrbTransitionLayer::decrypt_messages(
            user_keys,
            addr_keys,
            user_key_password,
            enc_to_list,
            enc_sender,
            enc_body,
        )
        .unwrap();

        assert!(decrypted_message.to_list.is_empty());
        assert!(decrypted_message.sender.is_empty());
        assert!(decrypted_message.body.is_empty());
    }

    #[test]
    fn test_encrypt_messages_with_keys() {
        let private_keys = vec![
            get_test_user_1_locked_user_key()
                .0
                .first()
                .unwrap()
                .private_key
                .to_string(),
            get_test_user_2_locked_user_key().private_key.to_string(),
        ];

        let message = "This is a test message!!!";

        let encrypted_message = FrbTransitionLayer::encrypt_messages_with_keys(
            private_keys,
            message.to_string(),
            None,
            None,
            None,
        )
        .unwrap();
        println!("{}", encrypted_message);
        assert!(!encrypted_message.is_empty());

        let user_keys = vec![get_test_user_2_locked_proton_user_key()];
        let addr_keys = vec![];
        let user_key_password = "password".to_string();
        let enc_to_list = None;
        let enc_sender = None;
        let enc_body = Some(encrypted_message);
        let out = FrbTransitionLayer::decrypt_messages(
            user_keys,
            addr_keys,
            user_key_password,
            enc_to_list.clone(),
            enc_sender.clone(),
            enc_body.clone(),
        )
        .unwrap();
        println!("{}", out.body);
        assert_eq!(out.body, message);

        let user_keys = vec![get_test_user_1_locked_proton_user_key()];
        let addr_keys = vec![];
        let user_key_password =
            String::from_utf8(get_test_user_1_locked_user_key_secret().as_bytes().to_vec())
                .unwrap();
        let out = FrbTransitionLayer::decrypt_messages(
            user_keys,
            addr_keys,
            user_key_password,
            enc_to_list,
            enc_sender,
            enc_body,
        )
        .unwrap();
        println!("{}", out.body);
        assert_eq!(out.body, message);
    }

    #[test]
    fn test_hash_hmac() {
        let hashed_txid = FrbTransitionLayer::get_hmac_hashed_string(
            "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=",
            "6bbfc06ef911e4b2fffe1150fa8f3729b3ee52c78ef21093b5ae45544ff690fa",
        )
        .unwrap();
        assert_eq!(hashed_txid, "O4f/ePTaBh8tNsiDaJRqQfBov6/+UU2FenCKcK14MGM=");
    }
}
