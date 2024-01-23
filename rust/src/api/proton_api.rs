use muon::auth::SimpleAuthStore;
use muon::request::{JsonRequest, Request, Response};
use muon::session::{RequestExt, Session};
use muon::types::auth::{AuthInfoReq, AuthInfoRes};
use muon::AppSpec;
use http;


pub fn add_four(left: usize, right: usize) -> usize {
    let app = AppSpec::default();
    let auth = SimpleAuthStore::new("atlas");
    let session = Session::new(auth, app);

    let req = AuthInfoReq {
        Username: "yanfeng.zhang@proton.ch".into(),
    };
    left + right
}

// use crate::error::Error;

// #[flutter_rust_bridge::frb(async)]
// async fn fetch_auth_info() -> Result<AuthInfoRes, Error> {

//     let app = AppSpec::default();
//     let auth = SimpleAuthStore::new("atlas");
//     let session = Session::new(auth, app)?;

//     let req = AuthInfoReq {
//         Username: "yanfeng.zhang@proton.ch".into(),
//     };

//     let res: AuthInfoRes = JsonRequest::new(http::Method::POST, "/auth/v4/info")
//         .body(req)?
//         .bind(session)?
//         .send()
//         .await?
//         .body()?;
    
//     Ok(res)
// }

// #[tokio::main]
// async fn main() -> Result<(), Box<dyn std::error::Error>> {
//     env_logger::init();

//     let app = AppSpec::default();
//     let auth = SimpleAuthStore::new("atlas");
//     let session = Session::new(auth, app)?;

//     let req = AuthInfoReq {
//         Username: "username".into(),
//     };

//     let res: AuthInfoRes = JsonRequest::new(http::Method::POST, "/auth/v4/info")
//         .body(req)?
//         .bind(session)?
//         .send()
//         .await?
//         .body()?;

//     assert!(!res.Modulus.is_empty());

//     Ok(())
// }


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

