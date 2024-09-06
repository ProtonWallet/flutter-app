use log::info;
use proton_crypto::crypto::ArmorerSync;
use proton_crypto::crypto::PGPProviderSync;
use proton_crypto::new_srp_provider;
use proton_crypto::srp::SRPProvider;
use std::str;
pub struct Srp {}

impl Srp {
    pub fn test() {
        const TEST_SERVER_EPHEMERAL: &str = "l13IQSVFBEV0ZZREuRQ4ZgP6OpGiIfIjbSDYQG3Yp39FkT2B/k3n1ZhwqrAdy+qvPPFq/le0b7UDtayoX4aOTJihoRvifas8Hr3icd9nAHqd0TUBbkZkT6Iy6UpzmirCXQtEhvGQIdOLuwvy+vZWh24G2ahBM75dAqwkP961EJMh67/I5PA5hJdQZjdPT5luCyVa7BS1d9ZdmuR0/VCjUOdJbYjgtIH7BQoZs+KacjhUN8gybu+fsycvTK3eC+9mCN2Y6GdsuCMuR3pFB0RF9eKae7cA6RbJfF1bjm0nNfWLXzgKguKBOeF3GEAsnCgK68q82/pq9etiUDizUlUBcA==";
        const TEST_MODULUS_CLEAR_SIGN: &str = "-----BEGIN PGP SIGNED MESSAGE-----\nHash: SHA256\n\nW2z5HBi8RvsfYzZTS7qBaUxxPhsfHJFZpu3Kd6s1JafNrCCH9rfvPLrfuqocxWPgWDH2R8neK7PkNvjxto9TStuY5z7jAzWRvFWN9cQhAKkdWgy0JY6ywVn22+HFpF4cYesHrqFIKUPDMSSIlWjBVmEJZ/MusD44ZT29xcPrOqeZvwtCffKtGAIjLYPZIEbZKnDM1Dm3q2K/xS5h+xdhjnndhsrkwm9U9oyA2wxzSXFL+pdfj2fOdRwuR5nW0J2NFrq3kJjkRmpO/Genq1UW+TEknIWAb6VzJJJA244K/H8cnSx2+nSNZO3bbo6Ys228ruV9A8m6DhxmS+bihN3ttQ==\n-----BEGIN PGP SIGNATURE-----\nVersion: ProtonMail\nComment: https://protonmail.com\n\nwl4EARYIABAFAlwB1j0JEDUFhcTpUY8mAAD8CgEAnsFnF4cF0uSHKkXa1GIa\nGO86yMV4zDZEZcDSJo0fgr8A/AlupGN9EdHlsrZLmTA1vhIx+rOgxdEff28N\nkvNM7qIK\n=q6vu\n-----END PGP SIGNATURE-----";
        const TEST_SALT: &str = "yKlc5/CvObfoiw==";
        const TEST_PASSWORD: &str = "abc123";
        let srp_provider = new_srp_provider();
        // Just checks that no errors are thrown since the outputs are random.
        srp_provider
            .generate_client_proof(
                "jakubqa",
                TEST_PASSWORD,
                4,
                TEST_SALT,
                TEST_MODULUS_CLEAR_SIGN,
                TEST_SERVER_EPHEMERAL,
            )
            .unwrap();

        let provider = proton_crypto::new_pgp_provider();
        let data = "hello";
        let buff = provider
            .armorer()
            .unarmor(TEST_MODULUS_CLEAR_SIGN.as_bytes())
            .unwrap();

        let s = match String::from_utf8(buff) {
            Ok(v) => v,
            Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
        };

        info!("Srp test result: {}", s);
    }
}

#[cfg(test)]
mod test {

    #[tokio::test]
    #[ignore]
    async fn test_srp() {
        // Srp::test();
    }
}
