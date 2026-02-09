#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOURCE_DIR="${1:-${ROOT_DIR}/ctf-collection/ctf_basic}"
OUTPUT_IMG="${2:-${ROOT_DIR}/ctf-basic.img}"
OUTPUT_DMG="${3:-${ROOT_DIR}/ctf-basic.dmg}"
GENEXT2FS_VERSION="${GENEXT2FS_VERSION:-1.4.2-0}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Source directory not found: ${SOURCE_DIR}" >&2
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "npm is required but not available." >&2
    exit 1
fi

if ! command -v cc >/dev/null 2>&1; then
    echo "C compiler (cc) is required but not available." >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required but not available." >&2
    exit 1
fi

source_kib="$(du -sk "${SOURCE_DIR}" | awk '{print $1}')"
image_blocks="$((source_kib + 4096))"
if (( image_blocks < 12288 )); then
    image_blocks=12288
fi
image_mib="$(( (image_blocks + 1023) / 1024 ))"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ctf-basic-build.XXXXXX")"
tmp_src="${tmp_dir}/src"
tmp_img="${tmp_dir}/ctf-basic.img"
genext2fs_dir="${tmp_dir}/genext2fs"

cleanup() {
    set +e
    rm -rf "${tmp_dir}"
}
trap cleanup EXIT

mkdir -p "${tmp_src}" "${genext2fs_dir}"

# Copy source tree and strip host-specific metadata files.
rsync -a --delete \
    --exclude='.DS_Store' \
    --exclude='._*' \
    "${SOURCE_DIR}/" "${tmp_src}/"

(
    cd "${genext2fs_dir}"
    npm pack "genext2fs@${GENEXT2FS_VERSION}" >/dev/null
    tar -xf genext2fs-*.tgz
    cd package
    cat > config.h <<'EOF'
#define VERSION "1.4.2"
#define STDC_HEADERS 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STDDEF_H 1
#define HAVE_STRING_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STRINGS_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_STDINT_H 1
#define HAVE_UNISTD_H 1
#define HAVE_DIRENT_H 1
#define HAVE_LIBGEN_H 1
#define HAVE_FCNTL_H 1
#define HAVE_GETOPT_H 1
#define HAVE_LIMITS_H 1
#define HAVE_GETLINE 1
#define HAVE_STRTOF 1
#define HAVE_STRUCT_STAT_ST_RDEV 1
#define HAVE_GETOPT_LONG 1
EOF
    cc -I. -std=gnu89 -O2 genext2fs.c -o genext2fs_local
    ./genext2fs_local -d "${tmp_src}" -b "${image_blocks}" "${tmp_img}"
)

mkdir -p "$(dirname "${OUTPUT_IMG}")"
mv "${tmp_img}" "${OUTPUT_IMG}"

if [[ -n "${OUTPUT_DMG}" ]]; then
    mkdir -p "$(dirname "${OUTPUT_DMG}")"
    cp "${OUTPUT_IMG}" "${OUTPUT_DMG}"
fi

chmod 0644 "${OUTPUT_IMG}"
if [[ -n "${OUTPUT_DMG}" ]]; then
    chmod 0644 "${OUTPUT_DMG}"
fi

sha256="$(shasum -a 256 "${OUTPUT_IMG}" | awk '{print $1}')"
echo "Built ${OUTPUT_IMG} (${image_mib} MiB, sha256: ${sha256})"
if [[ -n "${OUTPUT_DMG}" ]]; then
    echo "Copied ${OUTPUT_IMG} to ${OUTPUT_DMG}"
fi
