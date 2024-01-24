use muon::auth::SimpleAuthStore;
use muon::request::{JsonRequest, Request, Response};
use muon::session::{RequestExt, Session};
use muon::types::auth::{AuthInfoReq, AuthInfoRes};
use muon::AppSpec;
use http;

use crate::bdk::error::Error;
use crate::proton_api::types::AuthInfo;

pub async fn fetch_auth_info(user_name: String) -> Result<AuthInfo, Error> {
    let app = AppSpec::default();
    let auth = SimpleAuthStore::new("atlas");
    let session = Session::new(auth, app)?;

    let req = AuthInfoReq {
        Username: user_name,
    };

    let res: Result<AuthInfoRes, Error> = JsonRequest::new(http::Method::POST, "/auth/v4/info")
        .body(req)
        .map_err(|err| Error::Generic(err.to_string()))?
        .bind(session)
        .map_err(|err| Error::Generic(err.to_string()))?
        .send()
        .await
        .map_err(|err| Error::Generic(err.to_string()))?
        .body()
        .map_err(|err| Error::Generic(err.to_string()));

    Ok(res?.into())
}


// #[tokio::main]
// async fn main() -> Result<(), Box<dyn std::error::Error>> {
//     env_logger::init();

//     let app = AppSpec::default();
//     let auth = SimpleAuthStore::new("atlas");
//     let session = Session::new(auth, app)?;

//     let res = JsonRequest::new(http::Method::GET, "/tests/ping")
//         .bind(&session)?
//         .send()
//         .await?;

//     assert!(res.status().is_success());

//     Ok(())
// }

