#!/usr/bin/env bash

set -o errexit

# Freeze versions
PROTOBUF_VERSION=3.15.6
GRPC_GATEWAY_VERSION=1.9.0
PROTOC_GEN_GO_VERSION=1.2.0
GOLANGCI_LINT_VERSION=1.16.0
GOBINDATA_VERSION=3.1.1

export GO111MODULE=on

main() {
    check_go_compiler
    install_protobuf_compiler
    install_go_proto_tools
    install_go_linter
    install_go_codegen_tools
}

check_go_compiler() {
    go version 2>/dev/null || error_no_go_compiller
}

error_no_go_compiller() {
    echo 'error: no Go compiler found' 1>&2
    echo 'use "sudo snap install go --classic" to install go' 1>&2
    echo 'see also https://docs.snapcraft.io/installing-snap-on-debian' 1>&2
    exit 1
}

install_protobuf_compiler() {
    WORKDIR=$(mktemp -d)
    echo "downloading protobuf v${PROTOBUF_VERSION}"
    curl --silent --location https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip --output "$WORKDIR/protoc.zip"
    unzip "$WORKDIR/protoc.zip" -d "$WORKDIR/protoc" >/dev/null
    sudo_copy "$WORKDIR/protoc/bin/protoc" /usr/bin/
    sudo_copy "$WORKDIR/protoc/include/google" /usr/include/
    rm -rf "$WORKDIR"
}

install_go_proto_tools() {
    # We use protoc-get-go to generate GRPC API
    pushd "$(go env GOPATH)" >/dev/null
    echo "installing protobuf plugin for Go v${PROTOC_GEN_GO_VERSION}"
    go get github.com/golang/protobuf/protoc-gen-go@v${PROTOC_GEN_GO_VERSION}

    # We use grpc-gateway to generate fallback REST API over GRPC API
    echo "installing grpc-gateway v${GRPC_GATEWAY_VERSION}"
    go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v${GRPC_GATEWAY_VERSION}
    go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v${GRPC_GATEWAY_VERSION}
    popd >/dev/null
}

install_go_linter() {
    echo "installing golangci-lint v${GOLANGCI_LINT_VERSION}"
    pushd "$(go env GOPATH)" >/dev/null
    go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCI_LINT_VERSION}
    popd >/dev/null
}

install_go_codegen_tools() {
    echo "installing go-bindata v${GOBINDATA_VERSION}"
    pushd "$(go env GOPATH)" >/dev/null
    go get -u -v github.com/go-bindata/go-bindata/go-bindata@v${GOBINDATA_VERSION}
    popd >/dev/null
}

sudo_copy() {
    local SRC=$1
    local DEST=$2
    echo "copy \"$SRC\" to \"$DEST\""
    sudo cp -rf "$SRC" "$DEST"
    sudo chmod -R u+r,g+r,a+r "$DEST"
}

main