#!/bin/bash
# Vendors Eden (a maintained post-DMCA Switch emulator fork - see git.eden-emu.dev,
# not github.com/eden-emulator, which was DMCA'd Feb 2026), as its own prebuilt
# aarch64 clang-PGO AppImage, same approach pocknix-os uses (their eden-bin
# PKGBUILD vendors this exact asset unmodified rather than extracting it - it's
# a sharun/dwarfs-packed AppImage, not a plain squashfs, so it isn't meant to be
# unpacked at build time; its own AppRun handles mounting at launch).
set -euxo pipefail
cd "$(dirname "$0")"; REPO=$PWD
source ./BASE.env
source ../toolchain.env

mkdir -p out; rm -f out/*
podman run --rm -e VERSION="${VERSION}" -e SRC_URL="${SRC_URL}" \
    -v "${REPO}:/work:Z" -w /work --platform linux/aarch64 "${BUILDER_IMAGE}" bash -euxc '
        dnf -y install curl tar zstd
        mkdir -p /tmp/stage/eden
        curl -fsSL -o /tmp/stage/eden/Eden.AppImage "${SRC_URL}"
        chmod 755 /tmp/stage/eden/Eden.AppImage
        tar --owner=0 --group=0 -cf - -C /tmp/stage eden \
            | zstd -f -19 -T0 -o "/work/out/armada-eden-${VERSION}.tar.zst"
    '
( cd out && sha256sum "armada-eden-${VERSION}.tar.zst" > "armada-eden-${VERSION}.tar.zst.sha256" )
ls -lh out/
