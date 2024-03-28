FROM --platform=$BUILDPLATFORM golang:1.21 as builder

# Convert TARGETPLATFORM to GOARCH format
# https://github.com/tonistiigi/xx
COPY --from=tonistiigi/xx:golang / /

ARG TARGETPLATFORM

RUN apt update && apt install -y --no-install-recommends \
        musl-dev \
        git \
        gcc \
        && rm -rf /var/lib/apt/lists/* && apt -y autoremove

ADD . /src

WORKDIR /src

ENV GO111MODULE=on

RUN cd cmd/gost && go env && go build

FROM debian:latest

# add iptables for tun/tap
RUN apt update && apt install -y --no-install-recommends \
        iptables \
        && rm -rf /var/lib/apt/lists/* && apt -y autoremove

WORKDIR /bin/

COPY --from=builder /src/cmd/gost/gost .

ENTRYPOINT ["/bin/gost"]
