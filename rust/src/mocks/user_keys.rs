#[cfg(test)]
pub mod tests {

    pub const TEST_PRIVATE_SIGN_VERIFY: &str = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: Keybase OpenPGP v2.0.76\nComment: https://keybase.io/crypto\n\n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\n81hM+A==\n=tMIn\n-----END PGP PRIVATE KEY BLOCK-----\n";

    pub const TEST_USER_2_KEY: &str = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZXrEuBYJKwYBBAHaRw8BAQdAd3SP+S82mvNYec99IYXXy02QlEtWOwCX\nG+VRoWMTJgT+CQMIAuL1Bl1uoZBgAAAAAAAAAAAAAAAAAAAAAP8Kb+34nsOQ\njVlCUF4Rco6I2xectxdUsuCm6X+Emq+S+8JsPw/rwVxAmClvKJaeWIfZIV/u\nyc07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp\nbF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZXrEuAQLCQcICZD98eusToQD\nawMVCAoEFgACAQIZAQKbAwIeARYhBMZ9T6whFVji9dBihP3x66xOhANrAADW\n1QEA4TDQcWcCskhIbAyLj3eFN9oO4cAv01QnTYuW5p5LvMYA/AyngETI6OGC\n+/8UR3hKvmZMnThBMRfbzqg5B96KTIcBx4sEZXrEuBIKKwYBBAGXVQEFAQEH\nQCmW61ll1IgTcm8TuNuh92qEGoIzYrRs0fb6ivPBz7YJAwEIB/4JAwh2VqMV\n7EJ4WmAAAAAAAAAAAAAAAAAAAAAAjDFyvMguSeKDXNNvviwSK+nf7uqvbUNJ\nEEuxjr48kR2A6Cc4OavQJbAAHIVwUG8UQ+PYW/PvwngEGBYKACoFgmV6xLgJ\nkP3x66xOhANrApsMFiEExn1PrCEVWOL10GKE/fHrrE6EA2sAAIGYAQCzpA2U\nR18gbFL3k6xUaUaRHxZoxBZQ2crLRO1GhgxTxQEAhYFyb7k/0S4XwcDpSgJO\nYJWp7nLYBj9YSh4+qOa/5QM=\n-----END PGP PRIVATE KEY BLOCK-----\n";
    const TEST_USER_2_PASSWORD: &str = "password";
    use andromeda_api::{proton_users::ProtonUserKey, wallet::ApiWalletKey};
    use proton_crypto_account::{
        keys::{
            AddressKeys, ArmoredPrivateKey, EncryptedKeyToken, KeyFlag, KeyId, KeyTokenSignature,
            LockedKey, UserKeys,
        },
        proton_crypto::new_srp_provider,
        salts::{KeySalt, KeySecret, Salt, Salts},
    };

    use crate::proton_address::ProtonAddressKey;

    pub fn get_test_user_1_locked_user_key() -> UserKeys {
        let key = LockedKey {
            id: KeyId::from("aTdvCsWuv2V_YQQ5nLKsWPkHWMrlHfUxL9aTWakz6blhwI0q_j4MKnxO29xMQ4slCRvo3lFLE8ljb3kvMP2PQQ=="),
            version: 3,
            private_key: ArmoredPrivateKey::from("-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZie3jRYJKwYBBAHaRw8BAQdAAp+4PE1Sf5V95XrIY/P2dUNk1TOojoEG\nLuuOzULTa1v+CQMINYn0u3DCV01gjT+Noe2HzLxwP2hieZC1aoGCxSrLn0fs\nLeShqv2pCPZ+SdrjXB5s5Rq7OP5Kr/2gN+0KS0yLGdyirFZWe6m5T8j20UQ5\n0M07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp\nbF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZie3jQQLCQcICZA4nKgbRZBl\nGQMVCAoEFgACAQIZAQKbAwIeARYhBOZJEArPLqrMMxX8fzicqBtFkGUZAADk\n/AD+LA6NW1K+Z3IT66/DEtjH0cmw6HNqxkBdT7kaL2o5pAMA/j9b4JCurWk/\n62MBM4I9RwXzSo8lmgPiYwPp4d/xgEsMx4sEZie3jRIKKwYBBAGXVQEFAQEH\nQHvLC7RWIDsorX5ZmYwjZbUhbXnEcO2sYt8OFaIh5KtHAwEIB/4JAwhKivkG\nshycUGA6wZtPR2HqO6+jvvSlRau/g2eZnWqhnvB4iIYTcD+CPpcPnWrrNgTz\nAU+kQ5sVrP6OiKKHIkUvHT5+MwelTbcpievGx2zGwngEGBYKACoFgmYnt40J\nkDicqBtFkGUZApsMFiEE5kkQCs8uqswzFfx/OJyoG0WQZRkAAJ6BAQDv4nBl\nNnj0W7XiAjiwRmVrY/sdybelB6j01p7UrcVAxQEAtEmT2cSIScVdWH1j3H9l\n0gGE7amH+cm6CjXOA7+Uwwc=\n=RGJ0\n-----END PGP PRIVATE KEY BLOCK-----\n"),
            token: None,
            signature: None,
            activation: None,
            primary: true,
            active: true,
            flags: None,
            recovery_secret: None,
            recovery_secret_signature: None,
            address_forwarding_id: None,
        };
        UserKeys(vec![key])
    }

    pub fn get_test_user_1_locked_proton_user_key() -> ProtonUserKey {
        ProtonUserKey {
            ID: "G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ==".into(),
            Version: 3,
            PrivateKey: ArmoredPrivateKey::from("-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZie3jRYJKwYBBAHaRw8BAQdAAp+4PE1Sf5V95XrIY/P2dUNk1TOojoEG\nLuuOzULTa1v+CQMINYn0u3DCV01gjT+Noe2HzLxwP2hieZC1aoGCxSrLn0fs\nLeShqv2pCPZ+SdrjXB5s5Rq7OP5Kr/2gN+0KS0yLGdyirFZWe6m5T8j20UQ5\n0M07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp\nbF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZie3jQQLCQcICZA4nKgbRZBl\nGQMVCAoEFgACAQIZAQKbAwIeARYhBOZJEArPLqrMMxX8fzicqBtFkGUZAADk\n/AD+LA6NW1K+Z3IT66/DEtjH0cmw6HNqxkBdT7kaL2o5pAMA/j9b4JCurWk/\n62MBM4I9RwXzSo8lmgPiYwPp4d/xgEsMx4sEZie3jRIKKwYBBAGXVQEFAQEH\nQHvLC7RWIDsorX5ZmYwjZbUhbXnEcO2sYt8OFaIh5KtHAwEIB/4JAwhKivkG\nshycUGA6wZtPR2HqO6+jvvSlRau/g2eZnWqhnvB4iIYTcD+CPpcPnWrrNgTz\nAU+kQ5sVrP6OiKKHIkUvHT5+MwelTbcpievGx2zGwngEGBYKACoFgmYnt40J\nkDicqBtFkGUZApsMFiEE5kkQCs8uqswzFfx/OJyoG0WQZRkAAJ6BAQDv4nBl\nNnj0W7XiAjiwRmVrY/sdybelB6j01p7UrcVAxQEAtEmT2cSIScVdWH1j3H9l\n0gGE7amH+cm6CjXOA7+Uwwc=\n=RGJ0\n-----END PGP PRIVATE KEY BLOCK-----\n").to_string(),
            Token: None,
            Primary: 1,
            Active: 1,
            RecoverySecret: None,
            RecoverySecretSignature: None,
            Fingerprint: "".into(),
        }
    }

    pub fn get_test_user_1_locked_user_key_secret() -> KeySecret {
        let salt = Salt {
            id: KeyId::from("aTdvCsWuv2V_YQQ5nLKsWPkHWMrlHfUxL9aTWakz6blhwI0q_j4MKnxO29xMQ4slCRvo3lFLE8ljb3kvMP2PQQ=="),
            key_salt: Some(KeySalt::from("6bIzN4A8bOwmsiEuCPj74g==".to_owned())),
        };
        let salts = Salts::new(vec![salt]);
        let key_id=  KeyId::from(
            "aTdvCsWuv2V_YQQ5nLKsWPkHWMrlHfUxL9aTWakz6blhwI0q_j4MKnxO29xMQ4slCRvo3lFLE8ljb3kvMP2PQQ==",
        );
        let srp_provider = new_srp_provider();
        let key_secret = salts
            .salt_for_key(&srp_provider, &key_id, "password".as_bytes())
            .unwrap();
        key_secret
    }

    pub fn get_test_user_2_locked_user_keys() -> UserKeys {
        let key = get_test_user_2_locked_user_key();
        UserKeys(vec![key])
    }
    pub fn get_test_user_2_locked_user_key() -> LockedKey {
        LockedKey {
            id: KeyId::from("G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ=="),
            version: 3,
            private_key: ArmoredPrivateKey::from(TEST_USER_2_KEY),
            token: None,
            signature: None,
            activation: None,
            primary: true,
            active: true,
            flags: None,
            recovery_secret: None,
            recovery_secret_signature: None,
            address_forwarding_id: None,
        }
    }

    pub fn get_test_user_2_locked_proton_user_key() -> ProtonUserKey {
        ProtonUserKey {
            ID: "G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ==".into(),
            Version: 3,
            PrivateKey: TEST_USER_2_KEY.into(),
            Token: None,
            Primary: 1,
            Active: 1,
            RecoverySecret: None,
            RecoverySecretSignature: None,
            Fingerprint: "".into(),
        }
    }

    pub fn get_test_user_2_locked_user_key_secret() -> KeySecret {
        KeySecret::new(TEST_USER_2_PASSWORD.as_bytes().to_vec())
    }

    pub fn get_test_user_2_locked_proton_address_key() -> ProtonAddressKey {
        ProtonAddressKey {
            id: "ssbW3i5egXM4F-2uqNc2qACsxtKnuYaWMYJsso5IKTLQXLwEDFc_Hib0QaK6QODlGryyLhBH679-UkMkRBSz9w==".to_owned(),
            version: 3,
            public_key: String::default(),
            private_key: Some("-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZWRmVhYJKwYBBAHaRw8BAQdA5Y8bUHq5hTJBWZEa/mxOKJkOOd4h9CVo\n2vISFQLcccD+CQMI0hvANzTOSIJggUFyUgQsMpsQzh9uqDb7IbbFWLnI63C1\nm3lKZ4tICeQV4tVFRvHlVRNzJIuTGjFiFbYO1t5ZgcJJgiPEiL5kORqWMOBp\n680pbHVidXg0QHByb3Rvbi5ibGFjayA8bHVidXg0QHByb3Rvbi5ibGFjaz7C\njAQQFgoAPgWCZWRmVgQLCQcICZDvQqbsF76qjAMVCAoEFgACAQIZAQKbAwIe\nARYhBKcQ8sEYupYe38hwRu9CpuwXvqqMAAB5OQD/XyIK1r+JOFT3cYiBcaFx\niox1yFrsr4uTg8kL1fQPyuoBAIG92J1MoimhMPuYvvTmIvNrvWPZvutw+BF2\nhJvRYDYCx4sEZWRmVhIKKwYBBAGXVQEFAQEHQIaaQMB4FXy/xC3qgmlhtnvR\nWceanT3nlzFjIrS96RUmAwEIB/4JAwj8w5GKSR+H62BnDPr48nwPGpA+jvPg\nXG2m4wseURUjdhnVmnLNkC4gJH6wQRz4sqBPye2fHWp+loh+LEDyeBawvkbS\n/FQXNwP7NLSkn84dwngEGBYIACoFgmVkZlYJkO9CpuwXvqqMApsMFiEEpxDy\nwRi6lh7fyHBG70Km7Be+qowAAHeFAP91gCl/VD/zHEvYIpWEK672jkPUPDpP\nLl+erDsL2C10mgEA5fbBK09OVIjtYUJxiId1YYfn/4/ym92WNEAT20prLww=\n=Eckc\n-----END PGP PRIVATE KEY BLOCK-----\n".to_owned()),
            token: Some("-----BEGIN PGP MESSAGE-----\nVersion: ProtonMail\n\nwV4DcsIsGT18EWcSAQdARTz8SqnWI4HNr+g19xu794pnOQaV0u0GIKbmByr1\n7w8wkWeiYBLW0RmVRP6EPgYLWZoFagItzfCtQYd30RNAKFq33/fjYPDsIXsf\np42uiZ5Q0nEBJb2mMkj8HFEpNw+oeKQUx13OetooxcCald6kVnVQsxx9ZYJ/\np+tmXIoiQmdqSHmqfS6UyAJlyv3T6xqiU7ts5aUTDgS1siMr0UVw6rRLgFp6\npuf9bxNdGMlcmZlvxrMKH+TCodwOQJSXA0IoPDB9Qw==\n=qVb4\n-----END PGP MESSAGE-----\n".to_owned()),
            signature: Some("-----BEGIN PGP SIGNATURE-----\nVersion: ProtonMail\n\nwnUEABYKACcFgmV6xP0JkP3x66xOhANrFiEExn1PrCEVWOL10GKE/fHrrE6E\nA2sAACw3AQDJcE5rLsObFILcYBnMMtMIRgk1yJC89wUEmC7HsUUu3wD9FBPO\nasM3eXktszZDtVlk9Yfd+AIxLINr98z/wm1CrgY=\n=2skj\n-----END PGP SIGNATURE-----\n".to_owned()),
            primary: 1,
            active: 1,
            flags: 3_u32,
        }
    }

    pub fn get_test_user_2_locked_address_key() -> AddressKeys {
        AddressKeys::new(
            vec![LockedKey {
                id:KeyId::from("ssbW3i5egXM4F-2uqNc2qACsxtKnuYaWMYJsso5IKTLQXLwEDFc_Hib0QaK6QODlGryyLhBH679-UkMkRBSz9w=="),
                version:3,
                private_key: ArmoredPrivateKey::from("-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZWRmVhYJKwYBBAHaRw8BAQdA5Y8bUHq5hTJBWZEa/mxOKJkOOd4h9CVo\n2vISFQLcccD+CQMI0hvANzTOSIJggUFyUgQsMpsQzh9uqDb7IbbFWLnI63C1\nm3lKZ4tICeQV4tVFRvHlVRNzJIuTGjFiFbYO1t5ZgcJJgiPEiL5kORqWMOBp\n680pbHVidXg0QHByb3Rvbi5ibGFjayA8bHVidXg0QHByb3Rvbi5ibGFjaz7C\njAQQFgoAPgWCZWRmVgQLCQcICZDvQqbsF76qjAMVCAoEFgACAQIZAQKbAwIe\nARYhBKcQ8sEYupYe38hwRu9CpuwXvqqMAAB5OQD/XyIK1r+JOFT3cYiBcaFx\niox1yFrsr4uTg8kL1fQPyuoBAIG92J1MoimhMPuYvvTmIvNrvWPZvutw+BF2\nhJvRYDYCx4sEZWRmVhIKKwYBBAGXVQEFAQEHQIaaQMB4FXy/xC3qgmlhtnvR\nWceanT3nlzFjIrS96RUmAwEIB/4JAwj8w5GKSR+H62BnDPr48nwPGpA+jvPg\nXG2m4wseURUjdhnVmnLNkC4gJH6wQRz4sqBPye2fHWp+loh+LEDyeBawvkbS\n/FQXNwP7NLSkn84dwngEGBYIACoFgmVkZlYJkO9CpuwXvqqMApsMFiEEpxDy\nwRi6lh7fyHBG70Km7Be+qowAAHeFAP91gCl/VD/zHEvYIpWEK672jkPUPDpP\nLl+erDsL2C10mgEA5fbBK09OVIjtYUJxiId1YYfn/4/ym92WNEAT20prLww=\n=Eckc\n-----END PGP PRIVATE KEY BLOCK-----\n"),
                token:Some(EncryptedKeyToken::from("-----BEGIN PGP MESSAGE-----\nVersion: ProtonMail\n\nwV4DcsIsGT18EWcSAQdARTz8SqnWI4HNr+g19xu794pnOQaV0u0GIKbmByr1\n7w8wkWeiYBLW0RmVRP6EPgYLWZoFagItzfCtQYd30RNAKFq33/fjYPDsIXsf\np42uiZ5Q0nEBJb2mMkj8HFEpNw+oeKQUx13OetooxcCald6kVnVQsxx9ZYJ/\np+tmXIoiQmdqSHmqfS6UyAJlyv3T6xqiU7ts5aUTDgS1siMr0UVw6rRLgFp6\npuf9bxNdGMlcmZlvxrMKH+TCodwOQJSXA0IoPDB9Qw==\n=qVb4\n-----END PGP MESSAGE-----\n")),
                signature:Some(KeyTokenSignature::from("-----BEGIN PGP SIGNATURE-----\nVersion: ProtonMail\n\nwnUEABYKACcFgmV6xP0JkP3x66xOhANrFiEExn1PrCEVWOL10GKE/fHrrE6E\nA2sAACw3AQDJcE5rLsObFILcYBnMMtMIRgk1yJC89wUEmC7HsUUu3wD9FBPO\nasM3eXktszZDtVlk9Yfd+AIxLINr98z/wm1CrgY=\n=2skj\n-----END PGP SIGNATURE-----\n")),
                primary: true,
                active: true,
                flags:Some(KeyFlag::from(3_u32)),
                activation: None,
                recovery_secret: None,
                recovery_secret_signature: None,
                address_forwarding_id: None,
            }]
        )
    }

    pub fn get_test_user_3_locked_user_keys() -> UserKeys {
        let key = get_test_user_2_locked_user_key();
        UserKeys(vec![key])
    }
    pub fn get_test_user_3_locked_user_key() -> LockedKey {
        LockedKey {
            id: KeyId::from("G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ=="),
            version: 3,
            private_key: ArmoredPrivateKey::from("-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZcHI+hYJKwYBBAHaRw8BAQdAP95X+OxFf4BIZ6pVof0uGieuTrnlpxOn\n07kbnarFd9n+CQMIbH/7cYVS4IJg2yUdFVTAyfaM0gVEeMzGCM8+ZUPe6/qF\nAsMkTKFXYSvwwsjw/NwmCGxUGRlbOQilIHhrxRcgNnVZWM9vs+xlt1CUGRJL\nNM07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp\nbF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZcHI+gQLCQcICZC3N9EM+mvd\nVwMVCAoEFgACAQIZAQKbAwIeARYhBOkPJufu+pzcnwymRLc30Qz6a91XAAAL\n6wD9EMH2oS2Eud7JNoslh8xWac9bT15sUUmGBgwMSWxfyW8A/jb7ubVOBoQv\nl0FQpevuWScbCwsNXI97l7j623a+f54Px4sEZcHI+hIKKwYBBAGXVQEFAQEH\nQLEg5FwJpuFkUcZlNwrgUL8pqm6tQP5H03kHrlEaRUZpAwEIB/4JAwhObU5t\nfQYriWAIzA7e3ZNHBa4Q2LHwxZUz3ACTwua2SXZ5OxD0Io4jFkxiTuETIOnl\nLFQzHg+VVXcdEno56hjnsqHFFB7M94bsNjIImFoNwngEGBYKACoFgmXByPoJ\nkLc30Qz6a91XApsMFiEE6Q8m5+76nNyfDKZEtzfRDPpr3VcAAAQ2AQCQOIGC\nyNzZ8VU8OLu4uKi/U/uQBUcvW5z8W/QkfMiFCwEAm35gvMJB1ScmKCFJNI0t\nPguJGsxgNW6mwkszNjYfCQY=\n=xVXK\n-----END PGP PRIVATE KEY BLOCK-----\n"),
            token: None,
            signature: None,
            activation: None,
            primary: true,
            active: true,
            flags: None,
            recovery_secret: None,
            recovery_secret_signature: None,
            address_forwarding_id: None,
        }
    }

    pub fn get_test_user_3_locked_user_key_secret() -> KeySecret {
        KeySecret::new("4sFlJ8gesYLeYyS0cBFQ5biAZPIZyHe".as_bytes().to_vec())
    }

    pub fn mock_fake_proton_user_key() -> ProtonUserKey {
        ProtonUserKey {
            ID: "test_id".into(),
            Version: 3,
            PrivateKey: "private_key".into(),
            Token: Some("token".into()),
            Primary: 1,
            Active: 1,
            RecoverySecret: None,
            RecoverySecretSignature: None,
            Fingerprint: "private_key_fingerprint".into(),
        }
    }

    pub fn mock_fake_proton_user_key_2() -> ProtonUserKey {
        ProtonUserKey {
            ID: "test_id".into(),
            Version: 3,
            PrivateKey: "private_key_2".into(),
            Token: Some("token".into()),
            Primary: 0,
            Active: 1,
            RecoverySecret: None,
            RecoverySecretSignature: None,
            Fingerprint: "private_key_fingerprint".into(),
        }
    }

    pub fn mock_fake_proton_user_key_3() -> ProtonUserKey {
        ProtonUserKey {
            ID: "test_id_3".into(),
            Version: 3,
            PrivateKey: "private_key_3".into(),
            Token: Some("token".into()),
            Primary: 1,
            Active: 1,
            RecoverySecret: None,
            RecoverySecretSignature: None,
            Fingerprint: "private_key_fingerprint".into(),
        }
    }

    pub fn get_test_user_3_api_wallet_key() -> ApiWalletKey {
        let armored_encrypted_message = "-----BEGIN PGP MESSAGE-----\nComment: https://gopenpgp.org\nVersion: GopenPGP 2.7.5\n\nwV4D9Oug9vT13XESAQdAQkDaJMVbFk5TQ2XmK6qZU4rKVLV1DIccP11ljsbkqRgw\n/D/q1wGge0x3vPAAqjzRcMK7hyeIP9LCMfvjkBdS6o6E7CAROpAD7crqqHXtWt5W\n0lEBEPnoASMJSW9sPjmCzOz7OsDgXvTDefYrS8sp40y+4XVKs30m8q2oXIVYEZC6\nRK1A5P738mJ0y+chA2IOVWaLdOROM6O33lX+N8jfdsz5S+c=\n=yEP9\n-----END PGP MESSAGE-----\n";
        let armored_signature = "-----BEGIN PGP SIGNATURE-----\nVersion: GopenPGP 2.7.5\nComment: https://gopenpgp.org\n\nwpoEABYKAEwFAmbkDIkJELc30Qz6a91XFiEE6Q8m5+76nNyfDKZEtzfRDPpr3Vck\nlIAAAAAAEQAKY29udGV4dEBwcm90b24uY2h3YWxsZXQua2V5AAAgYAEApHBozjEK\nAoKM3rIdhWLbrHBq2lavIMwLNeqlXPG7zOsA/RZE9nMJNgRBq8EPa0LEtipE98LK\nq6m0IdhYgyQL3OkK\n=/dp1\n-----END PGP SIGNATURE-----\n";
        ApiWalletKey {
            WalletID: "wallet_id_user_3".to_owned(),
            UserKeyID: "user_key_id_user_3".to_owned(),
            WalletKey: armored_encrypted_message.to_string(),
            WalletKeySignature: armored_signature.to_string(),
        }
    }
    pub fn get_test_user_3_api_wallet_key_clear() -> Vec<u8> {
        let clear = [
            239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160,
            29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218,
        ];
        clear.to_vec()
    }
}
