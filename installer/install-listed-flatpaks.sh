#!/usr/bin/bash
# Resolve a Flatpak list against a remote, then install every listed ref.
# Missing, unpublished, or unmatched IDs fail the build. Network and install
# failures also fail the build. This script does not skip refs.
set -euo pipefail

system_flag=()
remote="flathub"
list_file=""

usage() {
    echo "Usage: $0 [--system] [--remote NAME] LIST_FILE" >&2
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --system)
            system_flag=(--system)
            shift
            ;;
        --remote)
            [[ $# -ge 2 ]] || usage
            remote="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            list_file="$1"
            shift
            break
            ;;
    esac
done

[[ -n "${list_file}" && -f "${list_file}" ]] || {
    echo "Flatpak list file not found: ${list_file:-<missing>}" >&2
    exit 1
}

flatpak remote-add --if-not-exists "${system_flag[@]}" \
    "${remote}" "https://dl.flathub.org/repo/flathub.flatpakrepo"

to_install=()
missing=()
query_failures=0

while IFS= read -r raw || [[ -n "${raw}" ]]; do
    ref="${raw%%#*}"
    ref="${ref#"${ref%%[![:space:]]*}"}"
    ref="${ref%"${ref##*[![:space:]]}"}"
    [[ -z "${ref}" ]] && continue

    probe_err=""
    probe_rc=0
    set +e
    probe_err="$(flatpak remote-info "${system_flag[@]}" "${remote}" "${ref}" 2>&1 >/dev/null)"
    probe_rc=$?
    set -e
    if [[ "${probe_rc}" -eq 0 ]]; then
        to_install+=("${ref}")
        continue
    fi

    if grep -qiE 'Nothing matches|No remote refs found|not found' <<<"${probe_err}"; then
        echo "ERROR: Flatpak ref '${ref}' does not exist on remote '${remote}'" >&2
        echo "${probe_err}" >&2
        missing+=("${ref}")
        continue
    fi

    echo "ERROR: failed to query Flatpak ref '${ref}' on remote '${remote}':" >&2
    echo "${probe_err}" >&2
    query_failures=$((query_failures + 1))
done < "${list_file}"

if [[ ${#missing[@]} -gt 0 || "${query_failures}" -ne 0 ]]; then
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "ERROR: ${#missing[@]} Flatpak ref(s) from ${list_file} are unavailable on ${remote}:" >&2
        printf '  %s\n' "${missing[@]}" >&2
    fi
    exit 1
fi

if [[ ${#to_install[@]} -eq 0 ]]; then
    echo "No Flatpaks to install from ${list_file}"
    exit 0
fi

echo "Installing ${#to_install[@]} Flatpak ref(s) from ${remote}"
flatpak install -y --noninteractive "${system_flag[@]}" "${remote}" "${to_install[@]}"
