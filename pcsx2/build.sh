#!/bin/bash
# Vendors yaps2 (github.com/yaps2/yaps2), an ARM64-focused fork of PCSX2, from
# its own prebuilt nightly release - not built from source here, same as
# ROCKNIX's own yaps2-sa package (they don't build it in-tree either, given
# the Qt6/LLVM/LTO toolchain this needs). Its binary carries RUNPATH
# $ORIGIN/../lib, so the extracted usr/{bin,lib,plugins,share} tree is
# self-contained - no LD_LIBRARY_PATH needed at install time.
set -euxo pipefail
cd "$(dirname "$0")"; REPO=$PWD
source ./BASE.env
source ../toolchain.env

mkdir -p out; rm -f out/*
podman run --rm -e VERSION="${VERSION}" -e SRC_URL="${SRC_URL}" \
    -v "${REPO}:/work:Z" -w /work --platform linux/aarch64 "${BUILDER_IMAGE}" bash -euxc '
        dnf -y install curl tar zstd findutils
        curl -fsSL -o /tmp/pcsx2-src.tar.zst "${SRC_URL}"
        mkdir -p /tmp/extract
        tar -I zstd -xf /tmp/pcsx2-src.tar.zst -C /tmp/extract
        SRC_DIR=$(find /tmp/extract -mindepth 1 -maxdepth 1 -type d | head -1)
        mkdir -p /tmp/stage/pcsx2
        cp -a "${SRC_DIR}/usr/." /tmp/stage/pcsx2/
        tar --owner=0 --group=0 -cf - -C /tmp/stage pcsx2 \
            | zstd -f -19 -T0 -o "/work/out/armada-pcsx2-${VERSION}.tar.zst"
    '
( cd out && sha256sum "armada-pcsx2-${VERSION}.tar.zst" > "armada-pcsx2-${VERSION}.tar.zst.sha256" )
ls -lh out/
