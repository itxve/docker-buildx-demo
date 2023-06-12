# 编译
FROM --platform=$TARGETPLATFORM rust:1.70.0-alpine3.18 as builder

LABEL org.opencontainers.image.source=https://github.com/itxve/docker-buildx-demo
LABEL org.opencontainers.image.description="Buildx Demo"
LABEL org.opencontainers.image.licenses=MIT

WORKDIR /app

# 创建一个空项目
RUN USER=root cargo new api

#安装 upx
RUN apk add musl-dev upx

RUN echo -e "[source.crates-io]\nreplace-with = 'rsproxy'\n[source.rsproxy]\nregistry = 'https://rsproxy.cn/crates.io-index'\n[source.rsproxy-sparse]\nregistry = 'sparse+https://rsproxy.cn/index/'\n[registries.rsproxy]\nindex = 'https://rsproxy.cn/crates.io-index'\n[net]\ngit-fetch-with-cli = true" ~/.cargo/config

COPY Cargo.toml Cargo.lock /app/api/

WORKDIR /app/api/

# 预编译一次 
RUN cargo build --release

#复制项目文件
COPY src /app/api/src/

# (# update timestamps to force a new build)编译使用upx压缩
RUN touch /app/api/src/main.rs && RUST_BACKTRACE=1 cargo build --release


RUN upx /app/api/target/release/app-api

# 运行 scratch ,busybox
FROM --platform=$TARGETPLATFORM scratch as runtime

WORKDIR /app

COPY --from=builder /app/api/target/release/app-api /app/bin/

CMD ["/app/bin/app-api"]