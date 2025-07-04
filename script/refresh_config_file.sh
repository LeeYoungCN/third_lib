#!/usr/bin/bash
SCRIPT_DIR="$(
    cd "$(dirname "$0")" || exit 1
    pwd
)"

ROOT_DIR="$(
    cd "${SCRIPT_DIR}/.." || exit 1
    pwd
)"

CONFIG_FILE_DIR="${ROOT_DIR}/cmake/config"

INSTALL_ROOT_DIR="${ROOT_DIR}/release"

function refresh_config_file() {
    find "${INSTALL_ROOT_DIR}" -mindepth 1 -maxdepth 2 -type d -name 'cmake' -print0 |
        while IFS= read -r -d '' dir; do
            find "${dir}" -maxdepth 1 -type f -name '*.cmake' -print0 |
                while IFS= read -r -d '' file; do
                    file_name="$(basename "${file}")"
                    cp "${CONFIG_FILE_DIR}/${file_name}" "${file}"
                done
        done

}

refresh_config_file
