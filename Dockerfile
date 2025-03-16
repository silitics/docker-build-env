# spell:ignore debian rustup tlsv rustflags crossbuild

FROM debian:bookworm

RUN apt-get update -y \
    && apt-get install -y \
        bison \
        crossbuild-essential-amd64 \
        crossbuild-essential-arm64 \
        curl \
        flex \
        gawk \
        python3 \
        wget \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

ARG RUST_VERSION=1.85
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=${RUST_VERSION}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain ${RUST_VERSION}
RUN rustup target add x86_64-unknown-linux-musl
RUN rustup target add aarch64-unknown-linux-musl

ENV AR_x86_64_unknown_linux_musl=x86_64-linux-gnu-ar \
    CC_x86_64_unknown_linux_musl=x86_64-linux-gnu-gcc \
    CXX_x86_64_unknown_linux_musl=x86_64-linux-gnu-g++ \
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-Clink-self-contained=yes -Clinker=rust-lld"

ENV AR_aarch64_unknown_linux_musl=aarch64-linux-gnu-ar \
    CC_aarch64_unknown_linux_musl=aarch64-linux-gnu-gcc \
    CXX_aarch64_unknown_linux_musl=aarch64-linux-gnu-g++ \
    CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-Clink-self-contained=yes -Clinker=rust-lld"

ENV NVM_DIR="/usr/local/nvm" \
    NODE_VERSION="22.14.0"

ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"

RUN mkdir -p "${NVM_DIR}" && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

RUN . "${NVM_DIR}/nvm.sh" \
    && nvm install "${NODE_VERSION}" \
    && node -v

RUN npm install -g pnpm@latest

ENV PNPM_HOME="/pnpm"
