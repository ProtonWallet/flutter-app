#[cfg(test)]
pub mod tests {
    use crate::proton_wallet::db::model::proton_user_model::ProtonUserModel;

    pub fn build_test_proton_user_model() -> ProtonUserModel {
        ProtonUserModel {
            id: 0,
            user_id: "mock_user_id".to_string(),
            name: "mock_proton_user_name".to_string(),
            used_space: 6666,
            currency: "CHF".to_string(),
            credit: 168,
            create_time: 55688,
            max_space: 9999,
            max_upload: 1234,
            role: 10,
            private: 1,
            subscribed: 0,
            services: 12,
            delinquent: 0,
            organization_private_key: None,
            email: Some("test@example.com".to_string()),
            display_name: Some("Test User".to_string()),
        }
    }
}
