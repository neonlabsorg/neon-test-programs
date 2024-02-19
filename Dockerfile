FROM solanalabs/rust:1.73.0 AS builder
RUN rustup toolchain install nightly
RUN rustup component add clippy --toolchain nightly
WORKDIR /opt
RUN sh -c "$(curl -sSfL https://release.solana.com/beta/install)" && \
    /root/.local/share/solana/install/active_release/bin/sdk/sbf/scripts/install.sh
ENV PATH=/root/.local/share/solana/install/active_release/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN rustup update

COPY . /opt

WORKDIR /opt
RUN cd ./test-invoke-program && cargo build-bpf --bpf-out-dir=/opt/deploy/test_invoke_program/

RUN cd counter && cargo build-bpf --bpf-out-dir=/opt/deploy/counter/
RUN cd transfer-sol/program && cargo build-bpf  --bpf-out-dir=/opt/deploy/transfer_sol/
RUN cd cross-program-invocation && cargo build-bpf --bpf-out-dir=/opt/deploy/cross_program_invocation/
RUN cd transfer-tokens && cargo build-bpf --bpf-out-dir=/opt/deploy/transfer_tokens/
COPY counter/counter-keypair.json /opt/deploy/counter/
COPY transfer-sol/program/transfer_sol-keypair.json /opt/deploy/transfer_sol/
COPY transfer-tokens/transfer_tokens-keypair.json /opt/deploy/transfer_tokens/

FROM ubuntu:20.04

COPY --from=builder /opt/test-invoke-program/neon-test-invoke-program.sh /opt/deploy/test_invoke_program/
COPY --from=builder /root/.local/share/solana/install/active_release/bin/solana /opt/solana/bin/
COPY --from=builder /root/.local/share/solana/install/active_release/bin/solana-keygen /opt/solana/bin/
COPY --from=builder /opt/deploy /opt/deploy
