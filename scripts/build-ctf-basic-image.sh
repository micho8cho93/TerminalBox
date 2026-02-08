#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOURCE_DIR="${1:-${ROOT_DIR}/ctf-collection/ctf_basic}"
OUTPUT_IMG="${2:-${ROOT_DIR}/ctf-basic.img}"
OUTPUT_DMG="${3:-${ROOT_DIR}/ctf-basic.dmg}"
VOLUME_NAME="${CTF_VOLUME_NAME:-CTF_BASIC}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Source directory not found: ${SOURCE_DIR}" >&2
    exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
    echo "hdiutil is required but not available." >&2
    exit 1
fi

if [[ ! -x /sbin/newfs_msdos ]]; then
    echo "/sbin/newfs_msdos is required but not available." >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required but not available." >&2
    exit 1
fi

source_kib="$(du -sk "${SOURCE_DIR}" | awk '{print $1}')"
image_mib="$(( (source_kib + 4096 + 1023) / 1024 ))"
if (( image_mib < 12 )); then
    image_mib=12
fi

tmp_base="$(mktemp "${TMPDIR:-/tmp}/ctf-basic.XXXXXX")"
tmp_img="${tmp_base}.img"
rm -f "${tmp_base}"

raw_device=""
mounted_device=""

cleanup() {
    set +e
    if [[ -n "${mounted_device}" ]]; then
        hdiutil detach "${mounted_device}" >/dev/null 2>&1 || true
    fi
    if [[ -n "${raw_device}" ]]; then
        hdiutil detach "${raw_device}" >/dev/null 2>&1 || true
    fi
    rm -f "${tmp_img}"
}
trap cleanup EXIT

dd if=/dev/zero of="${tmp_img}" bs=1m count="${image_mib}" status=none

raw_device="$(hdiutil attach -nomount "${tmp_img}" | awk 'NR==1{print $1}')"
if [[ -z "${raw_device}" ]]; then
    echo "Failed to attach temporary image for formatting." >&2
    exit 1
fi

/sbin/newfs_msdos -F 16 -v "${VOLUME_NAME}" "${raw_device/disk/rdisk}" >/dev/null
hdiutil detach "${raw_device}" >/dev/null
raw_device=""

attach_output="$(hdiutil attach -readwrite -nobrowse "${tmp_img}")"
mounted_device="$(printf '%s\n' "${attach_output}" | awk 'NR==1{print $1}')"
mount_point="$(printf '%s\n' "${attach_output}" | awk -F '\t' 'NR==1{print $NF}' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

if [[ -z "${mounted_device}" || -z "${mount_point}" || ! -d "${mount_point}" ]]; then
    echo "Failed to mount temporary image after formatting." >&2
    exit 1
fi

# COPYFILE_DISABLE avoids AppleDouble (._*) sidecar files on non-HFS volumes.
COPYFILE_DISABLE=1 rsync -a --delete \
    --exclude='.DS_Store' \
    --exclude='._*' \
    "${SOURCE_DIR}/" "${mount_point}/"

# macOS may still synthesize AppleDouble files on FAT volumes; remove them.
find "${mount_point}" -type f \( -name '._*' -o -name '.DS_Store' \) -delete

hdiutil detach "${mounted_device}" >/dev/null
mounted_device=""

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
