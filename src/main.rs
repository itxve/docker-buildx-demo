use actix_web::{error, get, web, App, HttpResponse, HttpServer, Responder};
use anyhow::Result;
use serde_json::json;

#[get("/")]
async fn index() -> impl Responder {
    HttpResponse::Ok().body("ok!")
}

#[actix_web::main]
async fn main() -> Result<()> {
    println!("start server...");
    let _ = HttpServer::new(move || {
        let json_config = web::JsonConfig::default()
            .limit(4096)
            .error_handler(|err, _req| {
                let error = json!({
                    "code": 1000,
                    "msg": err.to_string(),
                    "data": ""
                });
                error::InternalError::from_response(err, HttpResponse::Ok().json(error)).into()
            });
        App::new().app_data(json_config).service(index)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await;
    Ok(())
}
