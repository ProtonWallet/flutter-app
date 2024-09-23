// use async_trait::async_trait;
// use std::error::Error;

// // Define the state struct
// #[derive(Clone, Debug, Default)]
// struct ProtonRecoveryState {
//     is_loading: bool,
//     error: String,
//     is_recovery_enabled: bool,
//     mnemonic: String,
//     require_auth_model: RequireAuthModel,
// }

// // Define the required model
// #[derive(Clone, Debug, Default)]
// struct RequireAuthModel {
//     require_auth: bool,
//     twofa_status: u8,
// }

// // Define events for the ProtonRecoveryBloc
// enum ProtonRecoveryEvent {
//     LoadingRecovery,
//     TestRecovery,
//     EnableRecovery(RecoverySteps),
//     DisableRecovery(RecoverySteps),
// }

// #[derive(Clone)]
// enum RecoverySteps {
//     Start,
//     Auth,
// }

// // Define traits for Proton API Clients
// #[async_trait]
// trait ProtonUsersClient {
//     async fn get_user_info(&self) -> Result<UserInfo, Box<dyn Error>>;
//     async fn get_auth_info(&self) -> Result<AuthInfo, Box<dyn Error>>;
//     async fn unlock_password_change(
//         &self,
//         proofs: SrpClientProofs,
//     ) -> Result<String, Box<dyn Error>>;
//     async fn lock_sensitive_settings(&self) -> Result<i32, Box<dyn Error>>;
// }

// #[async_trait]
// trait ProtonSettingsClient {
//     async fn set_mnemonic_settings(
//         &self,
//         req: UpdateMnemonicSettingsRequestBody,
//     ) -> Result<i32, Box<dyn Error>>;
//     async fn reactive_mnemonic_settings(
//         &self,
//         req: UpdateMnemonicSettingsRequestBody,
//     ) -> Result<i32, Box<dyn Error>>;
//     async fn disable_mnemonic_settings(
//         &self,
//         proofs: SrpClientProofs,
//     ) -> Result<i32, Box<dyn Error>>;
// }

// Define struct for ProtonRecoveryBloc
struct ProtonRecovery {
    // user_manager: UserManager,
    // proton_users_api: Box<dyn ProtonUsersClient>,
    // proton_settings_api: Box<dyn ProtonSettingsClient>,
    // state: ProtonRecoveryState,
}

impl ProtonRecovery {
    fn new() -> Self {
        ProtonRecovery {
            // user_manager: UserManager,
            // proton_users_api: Box::new(ProtonUsersApi),
            // proton_settings_api: Box::new(ProtonSettingsApi),
            // state: ProtonRecoveryState::default(),
        }
    }
}

impl ProtonRecovery {
    async fn loading_recovery(&mut self) -> Result<(), Box<dyn Error>> {
        self.state.is_loading = true;
        self.state.error.clear();

        let user_info = self.proton_users_api.get_user_info().await?;
        let is_recovery_enabled = user_info.mnemonic_status == 3;

        self.state.is_loading = false;
        self.state.is_recovery_enabled = is_recovery_enabled;
        Ok(())
    }

    //     pub async fn handle_event(&mut self, event: ProtonRecoveryEvent) -> Result<(), Box<dyn Error>> {
    //         match event {
    //             ProtonRecoveryEvent::LoadingRecovery => self.loading_recovery().await,
    //             ProtonRecoveryEvent::TestRecovery => self.test_recovery().await,
    //             ProtonRecoveryEvent::EnableRecovery(step) => self.enable_recovery(step).await,
    //             ProtonRecoveryEvent::DisableRecovery(step) => self.disable_recovery(step).await,
    //         }
    //     }

    //     async fn test_recovery(&mut self) -> Result<(), Box<dyn Error>> {
    //         self.state.is_loading = true;
    //         self.state.error.clear();
    //         self.state.mnemonic =
    //             "banner tag desk cart mirror horse name minimum hen sport sadness evidence".to_string();

    //         let user_info = self.proton_users_api.get_user_info().await?;
    //         let is_recovery_enabled = user_info.mnemonic_status == 3;

    //         self.state.is_loading = false;
    //         self.state.is_recovery_enabled = is_recovery_enabled;
    //         Ok(())
    //     }

    //     async fn enable_recovery(&mut self, step: RecoverySteps) -> Result<(), Box<dyn Error>> {
    //         self.state.is_loading = true;
    //         self.state.error.clear();

    //         let user_info = self.proton_users_api.get_user_info().await?;
    //         match step {
    //             RecoverySteps::Start => {
    //                 let auth_info = self.proton_users_api.get_auth_info().await?;
    //                 let two_fa_enable = auth_info.twofa.enabled;

    //                 let auth_step = RequireAuthModel {
    //                     require_auth: true,
    //                     twofa_status: two_fa_enable,
    //                 };
    //                 self.state.require_auth_model = auth_step;
    //             }
    //             RecoverySteps::Auth => {
    //                 // Handle the authentication steps...
    //                 // Generate SRP client proof and other relevant logic
    //             }
    //         }

    //         Ok(())
    //     }

    //     async fn disable_recovery(&mut self, step: RecoverySteps) -> Result<(), Box<dyn Error>> {
    //         self.state.is_loading = true;
    //         self.state.error.clear();

    //         match step {
    //             RecoverySteps::Start => {
    //                 let auth_info = self.proton_users_api.get_auth_info().await?;
    //                 let two_fa_enable = auth_info.twofa.enabled;

    //                 let auth_step = RequireAuthModel {
    //                     require_auth: true,
    //                     twofa_status: two_fa_enable,
    //                 };
    //                 self.state.require_auth_model = auth_step;
    //             }
    //             RecoverySteps::Auth => {
    //                 // Handle disabling logic using SRP proofs
    //             }
    //         }

    //         Ok(())
    //     }
    // }

    // // Define necessary structs for the API response types
    // struct UserInfo {
    //     mnemonic_status: i32,
    //     keys: Vec<ProtonUserKey>,
    // }

    // struct AuthInfo {
    //     twofa: TwoFaStatus,
    //     version: String,
    //     salt: String,
    //     modulus: String,
    //     server_ephemeral: String,
    // }

    // struct TwoFaStatus {
    //     enabled: u8,
    // }

    // struct ProtonUserKey {
    //     id: String,
    //     private_key: String,
    // }

    // struct SrpClientProofs {
    //     client_ephemeral: String,
    //     client_proof: String,
    //     srp_session: String,
    // }

    // struct UpdateMnemonicSettingsRequestBody {
    //     mnemonic_user_keys: Vec<MnemonicUserKey>,
    //     mnemonic_salt: String,
    //     mnemonic_auth: MnemonicAuth,
    // }

    // struct MnemonicUserKey {
    //     id: String,
    //     private_key: String,
    // }

    // struct MnemonicAuth {
    //     modulus_id: String,
    //     salt: String,
    //     version: String,
    //     verifier: String,
    // }

    // struct UserManager;

    // impl UserManager {
    //     async fn get_primary_key(&self) -> Result<ProtonUserKey, Box<dyn Error>> {
    //         Ok(ProtonUserKey {
    //             id: "key_id".to_string(),
    //             private_key: "private_key".to_string(),
    //         })
    //     }
}
