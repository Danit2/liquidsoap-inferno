FROM rust:1-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    build-essential \
    pkg-config \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --recursive https://github.com/teodly/inferno.git .

RUN cargo build --release -p alsa_pcm_inferno

RUN mkdir -p /out && \
    cp target/release/libasound_module_pcm_inferno.so /out/libasound_module_pcm_inferno.so


FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    liquidsoap \
    ffmpeg \
    alsa-utils \
    libasound2 \
    tini \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/libasound_module_pcm_inferno.so \
    /usr/lib/x86_64-linux-gnu/alsa-lib/libasound_module_pcm_inferno.so

COPY entrypoint.sh /entrypoint.sh
COPY stream.liq /stream.liq

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
