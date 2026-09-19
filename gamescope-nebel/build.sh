#!/bin/bash
# gamescope-nebel: Nebel OS gamescope (Ga1dz1/nebel-gamescope) - the tree
# already carries the dual-output/dual-desktop work integrated, so unlike the
# stock gamescope package we build from the git tree and only apply the
# Fedora build-adaptation patches (cstdint, system wlroots, system stb/glm).
set -euxo pipefail
cd "$(dirname "$0")"; REPO=$PWD
source ./BASE.env
source ../toolchain.env

mkdir -p out; rm -f out/*

# Stage the source tarball exactly like a release tarball: the pinned commit,
# submodules included, git metadata stripped, top dir named for %setup.
rm -rf src-stage "gamescope-${VERSION}"
CLONE_URL="${GIT_REPO}"
if [[ -n "${GH_GAMESCOPE_PULL:-}" ]]; then
    CLONE_URL="https://x-access-token:${GH_GAMESCOPE_PULL}@github.com/Ga1dz1/nebel-gamescope"
fi
git clone --recursive "${CLONE_URL}" src-stage
git -C src-stage checkout "${GIT_REF}"
git -C src-stage submodule update --init --recursive
rm -rf src-stage/.git src-stage/.github
find src-stage -name .git -type d -prune -exec rm -rf {} +
mv src-stage "gamescope-${VERSION}"
tar czf "gamescope-${VERSION}.tar.gz" "gamescope-${VERSION}"
rm -rf "gamescope-${VERSION}"

podman run --rm -e VERSION="${VERSION}" -e ARMADA_MARCH="${ARMADA_MARCH}" -v "${REPO}:/work:Z" -w /work --platform linux/aarch64 "${BUILDER_IMAGE}" bash -euxc '
    dnf -y install --skip-unavailable \
        rpm-build rpmdevtools dnf-plugins-core spectool catch-devel \
        cmake gcc gcc-c++ git-core meson ninja-build \
        glm-devel google-benchmark-devel libXcursor-devel libXmu-devel \
        hwdata-devel libavif-devel libcap-devel libdecor-devel \
        libdisplay-info-devel libdrm-devel libei-devel libeis-devel libliftoff-devel \
        pipewire-devel systemd-devel luajit-devel openvr-devel \
        SDL2-devel vulkan-loader-devel wayland-protocols-devel \
        wayland-devel wlroots0.18-devel libX11-devel libXcomposite-devel \
        libXdamage-devel libXext-devel libXfixes-devel libxkbcommon-devel \
        libXrender-devel libXres-devel libXtst-devel libXxf86vm-devel \
        spirv-headers-devel stb_image-devel stb_image-static \
        stb_image_resize-devel stb_image_resize-static \
        stb_image_write-devel stb_image_write-static glslang
    rpmdev-setuptree
    cat >/etc/rpm/macros.armada <<EOF
%_buildhost armada-builder
%packager Armada
%vendor Armada
EOF
    cp gamescope.spec ~/rpmbuild/SPECS/
    sed -i "s/^Version:.*/Version:        ${VERSION}/" ~/rpmbuild/SPECS/gamescope.spec
    sed -i "/^%build$/i %global build_cflags %{build_cflags} ${ARMADA_MARCH}" ~/rpmbuild/SPECS/gamescope.spec
    sed -i "/^%build$/i %global build_cxxflags %{build_cxxflags} ${ARMADA_MARCH}" ~/rpmbuild/SPECS/gamescope.spec
    # Source0 is pre-staged by the host (the nebel-gamescope tree); spectool
    # only needs to fetch the remaining remote sources (reshade, vkroots).
    cp "gamescope-${VERSION}.tar.gz" stb.pc 0001-cstdint.patch ~/rpmbuild/SOURCES/
    spectool -g -R ~/rpmbuild/SPECS/gamescope.spec
    rpmbuild -bb ~/rpmbuild/SPECS/gamescope.spec
    cp ~/rpmbuild/RPMS/aarch64/*.rpm /work/out/
'
