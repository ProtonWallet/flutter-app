#[cfg(test)]
mod test {
    use andromeda_api::{
        core::ApiClient, tests::utils::test_spec, ApiConfig, ProtonWalletApiClient,
    };
    use chrono::Local;
    use futures::future::join_all;
    use std::sync::Arc;

    async fn test_job(
        job_id: u32,
        client: &andromeda_api::exchange_rate::ExchangeRateClient,
    ) -> chrono::DateTime<Local> {
        let now = Local::now();
        let formatted_time = now.format("%H:%M:%S").to_string();
        println!("Job {}, start at {}", job_id, formatted_time);

        let _ = client
            .get_exchange_rate(andromeda_api::settings::FiatCurrencySymbol::USD, None)
            .await;

        let now = Local::now();
        let formatted_time = now.format("%H:%M:%S").to_string();
        println!("Job {}, end at {}", job_id, formatted_time);
        return now;
    }

    #[tokio::test]
    async fn test_parallel_requests_prod() {
        let n_jobs = 20;

        let config = ApiConfig {
            spec: test_spec(),
            url_prefix: None,
            env: Some("prod".to_string()),
            store: None,
            auth: None,
        };
        let api = ProtonWalletApiClient::from_config(config).unwrap();
        // We don't need to login since request still response in 401 without login
        let api_client = Arc::new(api);

        let client = andromeda_api::exchange_rate::ExchangeRateClient::new(api_client);

        let jobs_should_run_in_parallel: Vec<_> = (0..n_jobs)
            .map(|job_id| test_job(job_id, &client))
            .collect();

        println!("Following job should run in parallel in production env");
        let results = join_all(jobs_should_run_in_parallel).await;
        let mut is_inorder = true;
        let _ = for window in results.windows(2) {
            if window[0] > window[1] {
                is_inorder = false;
                break;
            }
        };

        assert!(
            !is_inorder,
            "Response are in order (i.e. request are in single thread): {:?}",
            results
        );
    }
}
