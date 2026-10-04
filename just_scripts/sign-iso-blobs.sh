#!/usr/bin/bash
# Sign ISO blobs with Cosign when SIGNING_SECRET is a valid PEM key.
# Missing or malformed keys skip signing so ISO upload still succeeds.
set -euo pipefail

ISO_UPLOAD_DIR="${ISO_UPLOAD_DIR:?ISO_UPLOAD_DIR is required}"
SIGNING_KEY="${SIGNING_KEY:-}"

if [[ -z "${SIGNING_KEY}" ]]; then
    echo "SIGNING_SECRET is not set; skipping ISO signatures."
    exit 0
fi

key_file="${RUNNER_TEMP:-/tmp}/cosign.key"
umask 077
printf '%s' "${SIGNING_KEY}" | tr -d '\r' | sed 's/\\n/\n/g' > "${key_file}"
if [[ -s "${key_file}" && -n "$(tail -c1 "${key_file}" || true)" ]]; then
    printf '\n' >> "${key_file}"
fi

if ! grep -qE '^-----BEGIN ([A-Z0-9-]+ )?PRIVATE KEY-----$' "${key_file}"; then
    echo "SIGNING_SECRET is not a Cosign PEM private key (invalid pem block); skipping ISO signatures."
    echo "To enable signatures, run: cosign generate-key-pair"
    echo "Then store the contents of cosign.key as the SIGNING_SECRET repository secret."
    rm -f "${key_file}"
    exit 0
fi

shopt -s nullglob
isos=("${ISO_UPLOAD_DIR}"/*.iso)
if [[ ${#isos[@]} -eq 0 ]]; then
    echo "No ISO files found in ${ISO_UPLOAD_DIR}"
    rm -f "${key_file}"
    exit 1
fi

for iso in "${isos[@]}"; do
    echo "Signing ${iso}"
    cosign sign-blob -y --key "${key_file}" "${iso}" --output-signature "${iso}.sig"
done

rm -f "${key_file}"
