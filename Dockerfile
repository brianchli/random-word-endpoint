# https://itnext.io/a-practical-guide-to-containerize-your-rust-application-with-docker-77e8a391b4a8
FROM rust:slim-bullseye AS build

RUN rustup target add x86_64-unknown-linux-musl && \
    apt update && \
    apt install -y musl-tools musl-dev && \
    update-ca-certificates

COPY ./src ./src
COPY ./Cargo.lock .
COPY ./Cargo.toml .

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid 1001 \
    "web"

RUN cargo build --release

FROM rust:slim-bullseye

# necessary to copy user information into new instance
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

USER web:web

COPY --from=build --chown=web:web ./target/release/random-word-api /app/random-word-api

EXPOSE ${BACKEND_PORT}
ENTRYPOINT ["./app/random-word-api"]
