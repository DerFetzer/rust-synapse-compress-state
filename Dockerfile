# Create the build container to compile the hello world program
FROM rust:1.57.0-buster as builder
RUN apt-get update && apt-get install -y cmake musl-tools libssl-dev && rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /rust-synapse-compress-state/
COPY . .

RUN cargo build --target=x86_64-unknown-linux-musl --release

WORKDIR /rust-synapse-compress-state/synapse_auto_compressor
RUN cargo build --target=x86_64-unknown-linux-musl --release

# Create the execution container by copying the compiled binarieg to it
FROM scratch
WORKDIR /rust-synapse-compress-state
COPY --from=builder /rust-synapse-compress-state/target/x86_64-unknown-linux-musl/release/synapse_compress_state /rust-synapse-compress-state/synapse_compress_state
COPY --from=builder /rust-synapse-compress-state/target/x86_64-unknown-linux-musl/release/synapse_auto_compressor /rust-synapse-compress-state/synapse_auto_compressor
ENTRYPOINT ["./synapse_auto_compressor"]