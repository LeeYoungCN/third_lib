#!/usr/bin/bash
SCRIPT_DIR="$(
    cd "$(dirname "$0")" || exit 1
    pwd
)"
ROOT_DIR="$(
    cd "${SCRIPT_DIR}/.." || exit 1
    pwd
)"

readonly SCRIPT_DIR
readonly ROOT_DIR

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common_func.sh"

cd "${ROOT_DIR}" || exit 1

readonly BUILDCACHE_ROOT_DIR="${ROOT_DIR}/out/build"
readonly INSTALL_ROOT_DIR="${ROOT_DIR}/release"
readonly TOOLCHAIN_FILE_DIR="${ROOT_DIR}/cmake/toolchain_files"

arg_enable_clean=1
arg_clean_type="all"

arg_enable_build=1
arg_target="all"

arg_enable_configure=1
arg_preset=""

arg_enable_install=1
arg_component="all"

arg_enable_gtest=1
arg_gtest_case="all"

arg_enable_ctest=1
arg_ctest_case="all"

arg_enable_list_param=1

preset_array=("")

cmake_source_dir="${ROOT_DIR}"
cmake_build_dir=""
cmake_test_runtime=""
cmake_install_dir=""
cmake_build_type=""
cmake_toolchain_file=""
cmake_generator=""
cmake_preset=""
cmake_build_target=""
cmake_install_component=""
cmake_configure_param_cfg=""
ARCHITECTURE="x64"
env_param_file=""

g_is_init_param=1

function print_help() {
    echo "$(basename "$0") [options]"
    echo "Options:"
    echo "    -c, --clean[=<clean-type>]         Clean build cache. Default clean all."
    echo "                                       List all clean type: --clean=list"
    echo ""
    echo "    -p, --problem[=<problem-pefix>]    Set problem to build. Default build all problems."
    echo "                                       Build all problems: --problem(default) or --problem=all"
    echo "                                       List all problems:  --problem=list"
    echo ""
    echo "    -s, --preset[=<preset-name>]       CMake configure preset."
    echo "                                       Windows: win_clang_debug(default), win_clang_release, win_mingw_debug, win_mingw_release"
    echo "                                       Linux:   linux_clang_debug(default), linux_clang_releas, linux_gnu_debug, linux_gnu_release"
    echo "                                       Darwin:  darwin_clang_debug(default), darwin_clang_releas"
    echo ""
    echo "        --configure                    Run CMake configure by preset and problems."
    echo ""
    echo "        --build[=<target-name>]        Run CMake build. Default build all targets."
    echo "                                       Build all targets:    --build(default) or --build=all"
    echo "                                       List all target name: --build=list"
    echo ""
    echo "        --install[=<component>]        Run CMake install. Default install all."
    echo "                                       Install all components: --install(default) or --install=all"
    echo "                                       List all component: --install=list"
    echo ""
    echo "        --gtest[=<gtest-case>]         Run all gtest test case:      --gtest"
    echo "                                       Run target gtest test case:   --gtestr=<gtest-case>."
    echo "                                       List all gtest case list:     --gtest=list."
    echo ""
    echo "        --ctest[=<ctest-case>]         Rerun ctest case TEST_ALL:    --ctest or --ctest=all"
    echo "                                       Run target ctest case:        --ctest=<ctest-case>"
    echo "                                       Run last failed ctest case:   --ctest=rerun"
    echo "                                       List all gtest case:          --ctest=list"
    echo ""
    echo "        --list                         List cmake configure param."
    echo ""
    echo "        --help                         Get help info."
}

function clean_env() {
    local build_dir="${BUILDCACHE_ROOT_DIR}/${arg_preset}"
    local install_dir="${INSTALL_ROOT_DIR}/${arg_preset}"

    case "${arg_clean_type}" in
    all)
        rm_dir "${build_dir}"
        rm_dir "${install_dir}"
        ;;
    build)
        rm_dir "${build_dir}"
        ;;
    install)
        rm_dir "${install_dir}"
        ;;
    list)
        echo "all(default), build, install"
        ;;
    *)
        print_log "Invalid clean type: [${arg_clean_type}]"
        ;;
    esac
}

function list_cmake_configure_param_in_dir() {
    local RED='\033[0;31m'
    local GREEN='\033[32m'
    local BLUE='\033[34m'
    local NC='\033[0m'

    local build_dir="${1}"
    local configure_param_cfg="${build_dir}/cmake_configure.conf"
    if [ ! -e "${configure_param_cfg}" ]; then
        print_log "${configure_param_cfg} not exist." error
        return 1
    fi
    echo "----- ${build_dir} -----"
    while IFS= read -r line; do
        local key="${line%%=*}"
        local val="${line#*=}"
        local white_space="                              "
        echo -e "${BLUE}${key}:${white_space:${#key}}${val}${NC}"
    done <"${configure_param_cfg}"
}

function list_cmake_configure_param() {
    if [ -n "${arg_preset}" ]; then
        list_cmake_configure_param_in_dir "${cmake_build_dir}"
    else
        find "${BUILDCACHE_ROOT_DIR}" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -print0 |
            while IFS= read -r -d '' dir; do
                list_cmake_configure_param_in_dir "${dir}"
            done
    fi
}

function init_cmake_preset() {
    os=$(uname -s)
    if echo "${os}" | grep -q "MINGW"; then
        os="Windows"
    fi

    case ${os} in
    Windows)
        cmake_preset="win_clang_debug"
        preset_array=("win_mingw_debug" "win_mingw_release" "win_clang_debug" "win_clang_release" "msvc_x64_debug" "msvc_x64_release")
        ;;
    Linux)
        cmake_preset="linux_clang_debug"
        preset_array=("linux_gnu_debug" "linux_gnu_release" "linux_clang_debug" "linux_clang_release")
        ;;
    Darwin)
        cmake_preset="darwin_clang_debug"
        preset_array=("darwin_clang_debug" "darwin_clang_release")
        ;;
    *)
        print_log "os: ${os} error!"
        exit 1
        ;;
    esac

    if [ -n "${arg_preset}" ] && [ "${arg_preset}" != "all" ]; then
        cmake_preset="${arg_preset}"
    fi
    cmake_build_dir="${BUILDCACHE_ROOT_DIR}/${cmake_preset}"
}

function init_cmake_configure_param() {
    case "${os}" in
    Windows)
        case "${cmake_preset}" in
        win_mingw_debug)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/win_mingw.cmake"
            cmake_generator="MinGW Makefiles"
            cmake_build_type="Debug"
            ;;
        win_mingw_release)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/win_mingw.cmake"
            cmake_generator="MinGW Makefiles"
            cmake_build_type="Release"
            ;;
        win_clang_debug)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/win_clang.cmake"
            cmake_generator="Ninja"
            cmake_build_type="Debug"
            ;;
        win_clang_release)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/win_clang.cmake"
            cmake_generator="Ninja"
            cmake_build_type="Release"
            ;;
        msvc_x64_debug)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/win_msvc.cmake"
            cmake_generator="Ninja"
            cmake_build_type="Debug"
            env_param_file="${SCRIPT_DIR}/load_msvc_env.sh"
            ;;
        msvc_x64_release)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/win_msvc.cmake"
            cmake_generator="Ninja"
            cmake_build_type="Release"
            env_param_file="${SCRIPT_DIR}/load_msvc_env.sh"
            ;;
        *)
            print_log "Preset: ${arg_preset} error!" error
            exit 1
            ;;
        esac
        ;;
    Linux)
        case "${cmake_preset}" in
        linux_gnu_debug)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/linux_gnu.cmake"
            cmake_generator="Unix Makefiles"
            cmake_build_type="Debug"
            ;;
        linux_gnu_release)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/linux_gnu.cmake"
            cmake_generator="Unix Makefiles"
            cmake_build_type="Release"
            ;;
        linux_clang_debug)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/linux_clang.cmake"
            cmake_generator="Unix Makefiles"
            cmake_build_type="Debug"
            ;;
        linux_clang_release)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/linux_clang.cmake"
            cmake_generator="Unix Makefiles"
            cmake_build_type="Release"
            ;;
        *)
            print_log "Preset: ${arg_preset} error!" error
            exit 1
            ;;
        esac
        ;;
    Darwin)
        case "${cmake_preset}" in
        darwin_clang_debug)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/drawin_clang.cmake"
            cmake_generator="Unix Makefiles"
            cmake_build_type="Debug"
            ;;
        darwin_clang_release)
            cmake_toolchain_file="${TOOLCHAIN_FILE_DIR}/drawin_clang.cmake"
            cmake_generator="Unix Makefiles"
            cmake_build_type="Release"
            ;;
        *)
            print_log "Preset: ${arg_preset} error!" error
            exit 1
            ;;
        esac
        ;;
    *)
        print_log "os: ${os} error!"
        exit 1
        ;;
    esac

    cmake_install_dir="${INSTALL_ROOT_DIR}/${cmake_preset}"

    if [ -n "${env_param_file}" ]; then
        # shellcheck disable=SC1090
        source "${env_param_file}"
    fi
    g_is_init_param=0
    print_log "Init CMake configure param success." info
}

function init_cmake_env() {
    if [ ${g_is_init_param} -eq 0 ]; then
        return 0
    fi

    if [ ! -d "${cmake_build_dir}" ]; then
        print_log "[${cmake_preset}] CMake not configure." error
        exit 1
    fi
    cmake_configure_param_cfg="${cmake_build_dir}/cmake_configure.conf"

    if [ -e "${cmake_configure_param_cfg}" ]; then
        # shellcheck disable=SC1090
        source "${cmake_configure_param_cfg}"
        g_is_init_param=0
    else
        print_log "${cmake_configure_param_cfg} not exist." error
    fi
    if [ -n "${env_param_file}" ]; then
        # shellcheck disable=SC1090
        source "${env_param_file}"
    fi
}

function cmake_configure() {
    rm_dir "${cmake_build_dir}"
    init_cmake_configure_param

    if cmake \
        -S "${cmake_source_dir}" \
        -B "${cmake_build_dir}" \
        -G "${cmake_generator}" \
        -DCMAKE_TOOLCHAIN_FILE="${cmake_toolchain_file}" \
        -DCMAKE_BUILD_TYPE="${cmake_build_type}" \
        -DCMAKE_INSTALL_PREFIX="${cmake_install_dir}" \
        -DCMAKE_PRESET="${cmake_preset}" \
        -DENV_PARAM_FILE="${env_param_file}"; then
        print_log "[${cmake_preset}] CMake configuration success." info
    else
        print_log "[${cmake_preset}] CMake configuration failed." error
        exit 1
    fi
}

function cmake_build() {
    init_cmake_env

    readonly cmake_build_target="${arg_target}"
    case "${cmake_build_target}" in
    list)
        cmake --build "${cmake_build_dir}" --target "help"
        ;;
    *)
        if cmake --build "${cmake_build_dir}" --target "${cmake_build_target}" -j4; then
            print_log "[${cmake_preset}] CMake build success." info
        else
            print_log "[${cmake_preset}] CMake build failed." error
            exit 1
        fi
        ;;
    esac
}

function cmake_install() {
    init_cmake_env

    readonly cmake_install_component=${arg_component}

    case ${cmake_install_component} in
    list)
        cmake --build "${cmake_build_dir}" --target "list_install_components" -j4
        return 0
        ;;
    all)
        if cmake --install "${cmake_build_dir}"; then
            print_log "[${cmake_preset}] CMake install all success." info
        else
            print_log "[${cmake_preset}] CMake install all failed." error
            exit 1
        fi
        ;;
    *)
        if cmake --install "${cmake_build_dir}" --component "${cmake_install_component}"; then
            print_log "CMake install component [${cmake_install_component}] success." info
        else
            print_log "CMake install component [${cmake_install_component}] failed." error
            exit 1
        fi
        ;;
    esac
}

function run_gtest() {
    init_cmake_env
    cmake_test_runtime="${cmake_build_dir}/bin/leetcode_test"
    if [ ! -e "${cmake_test_runtime}" ]; then
        print_log "Test runtime [${cmake_test_runtime}] not exist!" error
        exit 1
    fi

    case "${arg_gtest_case}" in
    list)
        "${cmake_test_runtime}" --gtest_list_tests
        ;;
    all)
        "${cmake_test_runtime}"
        ;;
    *)
        "${cmake_test_runtime}" --gtest_filter="${arg_gtest_case}"
        ;;
    esac
}

function run_ctest() {
    init_cmake_env
    cmake_test_runtime="${cmake_build_dir}/bin/leetcode_test"
    if [ ! -e "${cmake_test_runtime}" ]; then
        print_log "Test runtime [${cmake_test_runtime}] not exist!" error
        exit 1
    fi

    if [ -z "${arg_ctest_case}" ]; then
        ctest --output-on-failure --test-dir "${cmake_build_dir}" -R "TEST_ALL"
        return 0
    fi

    case "${arg_ctest_case}" in
    list)
        ctest --test-dir "${cmake_build_dir}" -N
        ;;
    rerun)
        ctest --rerun-failed --output-on-failure --test-dir "${cmake_build_dir}"
        ;;
    all)
        ctest --output-on-failure --test-dir "${cmake_build_dir}" -R "TEST_ALL"
        ;;
    *)
        ctest --output-on-failure --test-dir "${cmake_build_dir}" -R "${arg_ctest_case}"
        ;;
    esac
}

function list_problem_prefix() {
    local problem_list_file="${ROOT_DIR}/problem_list.md"
    cat "${problem_list_file}"
}

function main() {
    if ! ARGS=$(
        getopt -o c::p:s: \
            --long clean::,install::,preset:,configure,build::,gtest::,ctest::,help,list \
            -n "$0" -- "$@"
    ); then
        print_log "getopt failed." error
        exit 1
    fi

    eval set -- "$ARGS"

    while true; do
        case "$1" in
        -c | --clean)
            arg_enable_clean=0
            if [ -n "${2}" ]; then
                arg_clean_type="${2}"
            fi
            shift 2
            ;;
        -s | --preset)
            arg_preset="${2}"
            shift 2
            ;;
        --configure)
            arg_enable_configure=0
            shift 1
            ;;
        --build)
            arg_enable_build=0
            if [ -n "${2}" ]; then
                arg_target="${2}"
            fi
            shift 2
            ;;
        --install)
            arg_enable_install=0
            if [ -n "${2}" ]; then
                arg_component="${2}"
            fi
            shift 2
            ;;
        -t | --gtest)
            arg_enable_gtest=0
            if [ -n "${2}" ]; then
                arg_gtest_case="${2}"
            fi
            shift 2
            ;;
        --ctest)
            arg_enable_ctest=0
            if [ -n "${2}" ]; then
                arg_ctest_case="${2}"
            fi
            shift 2
            ;;
        --list)
            arg_enable_list_param=0
            shift 1
            ;;
        --help)
            print_help
            exit 0
            ;;
        --)
            shift 1
            break
            ;;
        *)
            print_log "Invalid getopt param [${1}]." error
            exit 1
            ;;
        esac
    done

    readonly arg_enable_clean
    readonly arg_clean_type

    readonly arg_enable_configure
    readonly arg_preset

    readonly arg_enable_build
    readonly arg_target

    readonly arg_enable_install
    readonly arg_component

    readonly arg_enable_gtest
    readonly arg_gtest_case

    readonly arg_enable_ctest
    readonly arg_ctest_case

    init_cmake_preset

    if [ "${arg_preset}" == "list" ]; then
        echo "${preset_array[@]}"
        exit 0
    fi

    if [ ${arg_enable_clean} -eq 0 ]; then
        clean_env
        exit 0
    fi

    if [ ${arg_enable_list_param} -eq 0 ]; then
        list_cmake_configure_param
    fi

    if [ ${arg_enable_configure} -eq 0 ]; then
        cmake_configure
    fi

    if [ ${arg_enable_build} -eq 0 ]; then
        cmake_build
    fi

    if [ ${arg_enable_install} -eq 0 ]; then
        cmake_install
    fi

    if [ ${arg_enable_gtest} -eq 0 ]; then
        run_gtest
    fi

    if [ ${arg_enable_ctest} -eq 0 ]; then
        run_ctest
    fi
}

main "$@"
