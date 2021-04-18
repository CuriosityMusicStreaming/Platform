#!/usr/bin/env bash

set -o errexit

# Freeze versions
PROTOBUF_VERSION=3.13.0
GRPC_GATEWAY_VERSION=1.14.8
PROTOC_GEN_GO_VERSION=1.4.2
GOLANGCI_LINT_VERSION=1.31.0
GOBINDATA_VERSION=3.1.2

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

install_build_tools() {
    apt-get -qq install -y make git gnupg
}

install_protobuf_compiler() {
    apt-get -qq install -y unzip

    WORKDIR=$(mktemp -d)
    echo "downloading protobuf v${PROTOBUF_VERSION}"
    curl --silent --location https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip --output "$WORKDIR/protoc.zip"
    mkdir -p "$WORKDIR/protoc"
    unzip "$WORKDIR/protoc.zip" -d "$WORKDIR/protoc" >/dev/null
    fix_read_permissions "$WORKDIR/protoc"
    cp --recursive "$WORKDIR/protoc/bin/protoc" /usr/bin/
    cp --recursive "$WORKDIR/protoc/include/google" /usr/include/
    rm -rf "$WORKDIR"
    chmod +x /usr/bin/protoc
}

install_go_proto_tools() {
    # We use protoc-get-go to generate GRPC API
    echo "installing protobuf plugin for Go v${PROTOC_GEN_GO_VERSION}"
    go get github.com/golang/protobuf/protoc-gen-go@v${PROTOC_GEN_GO_VERSION}

    # We use grpc-gateway to generate fallback REST API over GRPC API
    echo "installing grpc-gateway v${GRPC_GATEWAY_VERSION}"
    go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v${GRPC_GATEWAY_VERSION}
    go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v${GRPC_GATEWAY_VERSION}

    # Move grpc-gateway source code to predictable path in /go/src.
    local SRC=/go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway\@v${GRPC_GATEWAY_VERSION}
    local DEST=/go/src/github.com/grpc-ecosystem/grpc-gateway
    mkdir -m 777 -p "$DEST"
    cp --recursive "$SRC/." "$DEST"
}

install_go_linter() {
    echo "installing golangci-lint v${GOLANGCI_LINT_VERSION}"
    go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCI_LINT_VERSION}
}

install_go_codegen_tools() {
    echo "installing go-bindata v${GOBINDATA_VERSION}"
    go get -u -v github.com/go-bindata/go-bindata/go-bindata@v${GOBINDATA_VERSION}
}

fix_read_permissions() {
    # All users will have permissions to read files and open directories
    local DIR=$1
    chmod -R u+r,g+r,a+r "$DIR"
    find "$DIR" -type d -exec chmod u+x,g+x,a+x {} \;
}

fix_write_permissions() {
    # All users will have permissions to write files
    local DIR=$1
    chmod -R u+w,g+w,a+w "$DIR"
}

function cleanup_docker_image() {
    # See also https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
    apt-get -qq clean
    truncate -s 0 /var/log/*log
}

apt-get -qq update
install_build_tools
install_protobuf_compiler
install_go_proto_tools
install_go_linter
install_go_codegen_tools

fix_read_permissions "/go"
fix_write_permissions "/go/pkg"
fix_write_permissions "/go/src"
cleanup_docker_image

# Remove this script
rm $(readlink -f $0)
