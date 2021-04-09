FROM golang:1.16

LABEL version=1.0

ARG PROTOBUF_VERSION=3.15.6
ARG GRPC_GATEWAY_VERSION=1.9.0
ARG PROTOC_GEN_GO_VERSION=1.2.0
ARG GOLANGCI_LINT_VERSION=1.16.0
ARG GOBINDATA_VERSION=3.1.1

ARG TMP_WORKDIR='/tmp/protoc'

WORKDIR $TMP_WORKDIR

RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    git

RUN wget -q 'https://github.com/protocolbuffers/protobuf/releases/download/v3.15.6/protoc-3.15.6-linux-x86_32.zip' && \
    unzip "$(find $TMP_WORKDIR -name *.zip)" && \
    cp -r "$TMP_WORKDIR/bin/protoc" /usr/bin/ && \
    cp -r "$TMP_WORKDIR/include/google" /usr/include/

# Set workdir cause its go env GOPATH
WORKDIR /go

RUN echo "installing protobuf plugin for Go v${PROTOC_GEN_GO_VERSION}" && \
    go get github.com/golang/protobuf/protoc-gen-go@v${PROTOC_GEN_GO_VERSION} && \
    echo "installing grpc-gateway v${GRPC_GATEWAY_VERSION}" && \
    go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v${GRPC_GATEWAY_VERSION} && \
    go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v${GRPC_GATEWAY_VERSION}

#RUN echo "installing golangci-lint v${GOLANGCI_LINT_VERSION}" && \
#    go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCI_LINT_VERSION}

RUN echo "installing go-bindata v${GOBINDATA_VERSION}" && \
    go get -u -v github.com/go-bindata/go-bindata/go-bindata@v${GOBINDATA_VERSION}

RUN apt clean autoclean && \
    apt autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
