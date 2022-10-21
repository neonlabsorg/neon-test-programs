FROM solanalabs/rust:1.61.0 AS builder
RUN rustup toolchain install nightly
RUN rustup component add clippy --toolchain nightly
WORKDIR /opt
RUN sh -c "$(curl -sSfL https://release.solana.com/stable/install)" && \
    /root/.local/share/solana/install/active_release/bin/sdk/bpf/scripts/install.sh
ENV PATH=/root/.local/share/solana/install/active_release/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY . /opt
WORKDIR /opt
RUN cargo +nightly clippy &&  cargo build-bpf

FROM ubuntu:20.04

WORKDIR /opt

COPY --from=builder /opt/neon-test-invoke-program-keypair.json /opt
COPY --from=builder /opt/target/deploy/neon-test-invoke-program.so /opt
COPY --from=builder /opt/neon-test-invoke-program.sh /opt
