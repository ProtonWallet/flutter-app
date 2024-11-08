use andromeda_api::{
    proton_settings::{
        MnemonicAuth, MnemonicUserKey, ProtonSettingsClientExt, UpdateMnemonicSettingsRequestBody,
    },
    proton_users::ProtonUsersClientExt,
};
use andromeda_bitcoin::mnemonic::Mnemonic;
use base64::{prelude::BASE64_STANDARD, Engine};
use proton_crypto::{generate_secure_random_bytes, new_pgp_provider};
use proton_crypto_account::keys::UserKeys;
use std::sync::Arc;

use super::{proton_settings::password_scope::PasswordScope, Result};
use crate::proton_wallet::{
    crypto::{private_key::LockedPrivateKeys, srp::SrpClient},
    features::error::FeaturesError,
    provider::{proton_auth::ProtonAuthProvider, user_keys::UserKeysProvider},
};

pub struct ProtonRecovery {
    /// providers
    pub(crate) auth_provider: Arc<dyn ProtonAuthProvider>,
    pub(crate) proton_user_keys_provider: Arc<dyn UserKeysProvider>,

    /// api dependency
    pub(crate) proton_settings_api: Arc<dyn ProtonSettingsClientExt>,
    pub(crate) proton_users_api: Arc<dyn ProtonUsersClientExt>,

    ///feature dependency
    pub(crate) password_scope_feature: Arc<dyn PasswordScope>,
}

impl ProtonRecovery {
    pub async fn recovery_status(&self) -> Result<u32> {
        let user_info = self.proton_users_api.get_user_info().await?;
        Ok(user_info.MnemonicStatus)
    }

    pub async fn two_fa_status(&self) -> Result<u8> {
        let auth_info = self.auth_provider.auth_info().await?;
        Ok(auth_info.two_fa.Enabled)
    }

    /// Enable Proton Recovery
    /// Notes: migrate it later
    /// let salt = KeySalt::generate()
    //  let new_hashed_password = salt.salted_key_passphrase(&srp_provider, recovery_password)?;
    //  MnemonicSalt: salt.into()
    pub async fn enable_recovery(&self, login_password: &str, twofa: &str) -> Result<Vec<String>> {
        // unlock password scope
        self.password_scope_feature
            .unlock_password_change(login_password, twofa)
            .await?;

        let salt_bytes: [u8; 16] = generate_secure_random_bytes();
        let random_entropy_bytes: [u8; 16] = generate_secure_random_bytes();
        let mnemonic = Mnemonic::new_with(&random_entropy_bytes)?;

        let mnemonic_words = mnemonic.as_words();
        let recovery_password = BASE64_STANDARD.encode(random_entropy_bytes);

        let new_hashed_password =
            SrpClient::compute_key_password_as_secret(recovery_password, salt_bytes.to_vec())?;

        let user_keys = self.proton_user_keys_provider.get_user_keys().await?;
        let passphrase = self
            .proton_user_keys_provider
            .get_user_key_passphrase()
            .await?;

        let provider = new_pgp_provider();
        let new_private_keys = LockedPrivateKeys::relock_user_key_with(
            &provider,
            UserKeys::new(user_keys),
            &passphrase,
            &new_hashed_password,
        )?;

        let mnemonic_user_keys: Vec<MnemonicUserKey> = new_private_keys
            .into_iter()
            .map(|relocked_key| MnemonicUserKey {
                ID: relocked_key.key_id.to_string(),
                PrivateKey: relocked_key.private_key.to_string(),
            })
            .collect();

        let auth_module: MnemonicAuth = self
            .auth_provider
            .generate_auth_module(login_password)
            .await?
            .into();

        // Prepare the request to update mnemonic settings
        let req = UpdateMnemonicSettingsRequestBody {
            MnemonicUserKeys: mnemonic_user_keys,
            MnemonicSalt: BASE64_STANDARD.encode(salt_bytes),
            MnemonicAuth: auth_module,
        };

        // Send request to enable recovery
        let recovery_code = self.proton_settings_api.set_mnemonic_settings(req).await?;
        log::info!("EnableRecovery response code: {}", recovery_code);

        // Lock sensitive settings after enabling recovery
        let lock_code = self.proton_users_api.lock_sensitive_settings().await?;
        log::info!("Lock sensitive settings response code: {}", lock_code);

        if lock_code != 1000 {
            return Err(FeaturesError::LockSensitiveSettings(lock_code));
        }
        Ok(mnemonic_words)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_1_locked_user_key, get_test_user_1_locked_user_key_secret,
        },
        proton_wallet::{
            features::proton_settings::password_scope::mock::MockPasswordScope,
            provider::{
                proton_auth::mock::MockProtonAuthProvider, proton_auth_model::AuthVerifier,
                user_keys::mock::MockUserKeysProvider,
            },
        },
    };
    use andromeda_api::{
        proton_users::{GetAuthInfoResponseBody, ProtonUser, TwoFA},
        tests::{
            proton_settings_mock::mock_utils::MockProtonSettingsClient,
            proton_users_mock::mock_utils::MockProtonUsersClient,
        },
    };
    use std::sync::Arc;

    #[tokio::test]
    async fn test_recovery_status() {
        let mut mock_user_api = MockProtonUsersClient::new();
        mock_user_api.expect_get_user_info().returning(|| {
            Ok(ProtonUser {
                MnemonicStatus: 1,
                ..Default::default()
            })
        });

        let recovery = ProtonRecovery {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            proton_user_keys_provider: Arc::new(MockUserKeysProvider::new()),
            proton_settings_api: Arc::new(MockProtonSettingsClient::new()),
            proton_users_api: Arc::new(mock_user_api),
            password_scope_feature: Arc::new(MockPasswordScope::new()),
        };

        let status = recovery.recovery_status().await.unwrap();
        assert_eq!(status, 1);
    }

    #[tokio::test]
    async fn test_two_fa_status() {
        let mut mock_auth_provider = MockProtonAuthProvider::new();
        mock_auth_provider.expect_auth_info().returning(|| {
            Ok(GetAuthInfoResponseBody {
                two_fa: TwoFA { Enabled: 1 },
                ..Default::default()
            })
        });

        let recovery = ProtonRecovery {
            auth_provider: Arc::new(mock_auth_provider),
            proton_user_keys_provider: Arc::new(MockUserKeysProvider::new()),
            proton_settings_api: Arc::new(MockProtonSettingsClient::new()),
            proton_users_api: Arc::new(MockProtonUsersClient::new()),
            password_scope_feature: Arc::new(MockPasswordScope::new()),
        };

        let status = recovery.two_fa_status().await.unwrap();
        assert_eq!(status, 1);
    }

    #[tokio::test]
    async fn test_enable_recovery_success() {
        let mut mock_password_scope = MockPasswordScope::new();
        mock_password_scope
            .expect_unlock_password_change()
            .returning(|_, _| Ok(()));

        let mut mock_auth_provider = MockProtonAuthProvider::new();
        mock_auth_provider
            .expect_generate_auth_module()
            .returning(|_| Ok(AuthVerifier::default()));

        let mut mock_settings_api = MockProtonSettingsClient::new();
        mock_settings_api
            .expect_set_mnemonic_settings()
            .returning(|_| Ok(1000));

        let mut mock_user_api = MockProtonUsersClient::new();
        mock_user_api
            .expect_lock_sensitive_settings()
            .returning(|| Ok(1000));

        let mut mock_user_keys_provider = MockUserKeysProvider::new();
        mock_user_keys_provider
            .expect_get_user_keys()
            .returning(|| Ok(get_test_user_1_locked_user_key().0));
        mock_user_keys_provider
            .expect_get_user_key_passphrase()
            .returning(|| Ok(get_test_user_1_locked_user_key_secret()));

        let recovery = ProtonRecovery {
            auth_provider: Arc::new(mock_auth_provider),
            proton_user_keys_provider: Arc::new(mock_user_keys_provider),
            proton_settings_api: Arc::new(mock_settings_api),
            proton_users_api: Arc::new(mock_user_api),
            password_scope_feature: Arc::new(mock_password_scope),
        };

        let mnemonic_words = recovery
            .enable_recovery("correct_password", "123456")
            .await
            .unwrap();

        assert!(!mnemonic_words.is_empty());
    }

    #[tokio::test]
    async fn test_enable_recovery_failure() {
        let mut mock_password_scope = MockPasswordScope::new();
        mock_password_scope
            .expect_unlock_password_change()
            .returning(|_, _| Err(FeaturesError::InvalidSrpServerProofs));

        let recovery = ProtonRecovery {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            proton_user_keys_provider: Arc::new(MockUserKeysProvider::new()),
            proton_settings_api: Arc::new(MockProtonSettingsClient::new()),
            proton_users_api: Arc::new(MockProtonUsersClient::new()),
            password_scope_feature: Arc::new(mock_password_scope),
        };

        let result = recovery.enable_recovery("wrong_password", "000000").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Invalid srp server proofs"
        );
    }
}
