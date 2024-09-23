#[cfg(test)]
pub mod tests {

    const TEST_USER_2_KEY: &str = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxYYEZXrEuBYJKwYBBAHaRw8BAQdAd3SP+S82mvNYec99IYXXy02QlEtWOwCX\nG+VRoWMTJgT+CQMIAuL1Bl1uoZBgAAAAAAAAAAAAAAAAAAAAAP8Kb+34nsOQ\njVlCUF4Rco6I2xectxdUsuCm6X+Emq+S+8JsPw/rwVxAmClvKJaeWIfZIV/u\nyc07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp\nbF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZXrEuAQLCQcICZD98eusToQD\nawMVCAoEFgACAQIZAQKbAwIeARYhBMZ9T6whFVji9dBihP3x66xOhANrAADW\n1QEA4TDQcWcCskhIbAyLj3eFN9oO4cAv01QnTYuW5p5LvMYA/AyngETI6OGC\n+/8UR3hKvmZMnThBMRfbzqg5B96KTIcBx4sEZXrEuBIKKwYBBAGXVQEFAQEH\nQCmW61ll1IgTcm8TuNuh92qEGoIzYrRs0fb6ivPBz7YJAwEIB/4JAwh2VqMV\n7EJ4WmAAAAAAAAAAAAAAAAAAAAAAjDFyvMguSeKDXNNvviwSK+nf7uqvbUNJ\nEEuxjr48kR2A6Cc4OavQJbAAHIVwUG8UQ+PYW/PvwngEGBYKACoFgmV6xLgJ\nkP3x66xOhANrApsMFiEExn1PrCEVWOL10GKE/fHrrE6EA2sAAIGYAQCzpA2U\nR18gbFL3k6xUaUaRHxZoxBZQ2crLRO1GhgxTxQEAhYFyb7k/0S4XwcDpSgJO\nYJWp7nLYBj9YSh4+qOa/5QM=\n-----END PGP PRIVATE KEY BLOCK-----\n";
    const TEST_USER_2_PASSWORD: &str = "password";
    use andromeda_api::proton_users::ProtonUserKey;
    use proton_crypto_account::{
        keys::{
            AddressKeys, ArmoredPrivateKey, EncryptedKeyToken, KeyFlag, KeyId, KeyTokenSignature,
            LockedKey, UserKeys,
        },
        proton_crypto::new_srp_provider,
        salts::{KeySalt, KeySecret, Salt, Salts},
    };

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

    pub fn get_test_user_2_locked_user_key_secret() -> KeySecret {
        KeySecret::new(TEST_USER_2_PASSWORD.as_bytes().to_vec())
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
}
