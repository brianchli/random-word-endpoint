use axum::{Router, routing::get};
use random_word::Lang;

#[derive(serde::Serialize)]
struct RandomWord {
    word: &'static str,
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route( "/", get(|| async {
            "/rand-word"
        }))
        .route( "/rand-word", get(|| async {
            axum::extract::Json(RandomWord {
                word: random_word::get(Lang::En),
            })
        }),
    );
    let port = 49152;
    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{port}"))
        .await
        .unwrap_or_else(|_| panic!("unable to bind to port {port}; time to die!"));
    println!("serving at http://localhost:{port}");
    axum::serve(listener, app)
        .await
        .expect("failed to serve; time to die!");
}
