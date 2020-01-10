FROM rust:latest

# RUN cargo install mdbook --no-default-features --features output --vers "^0.3.5"
RUN cargo install mdbook --vers "^0.3.5"

EXPOSE 3000

WORKDIR /mdbook

CMD ["mdbook", "serve", "--hostname", "0.0.0.0"]
