#!/usr/bin/env bash
# Install the pinned Linux x64 mise archive after SHA-256 verification.

set -Eeuo pipefail
IFS=$'\n\t'

SETUP_MISE_SCRATCH=
SETUP_MISE_ARCHIVE=

cleanup() {
  if [[ -n $SETUP_MISE_ARCHIVE ]]; then
    rm -f -- "$SETUP_MISE_ARCHIVE"
  fi
  if [[ -n $SETUP_MISE_SCRATCH ]]; then
    rmdir -- "$SETUP_MISE_SCRATCH"
  fi
}

main() {
  local -r version=${MISE_VERSION:?MISE_VERSION is required}
  local -r checksum=${MISE_SHA256:?MISE_SHA256 is required}
  local -r runner_os=${RUNNER_OS:?RUNNER_OS is required}
  local -r runner_arch=${RUNNER_ARCH:?RUNNER_ARCH is required}
  local -r runner_temp=${RUNNER_TEMP:?RUNNER_TEMP is required}
  local -r github_output=${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}
  local archive install_root scratch

  if [[ $runner_os != Linux || $runner_arch != X64 ]]; then
    echo "setup-mise supports only Linux X64 runners, got $runner_os $runner_arch" >&2
    return 1
  fi

  archive="mise-v${version}-linux-x64.tar.xz"
  readonly archive
  install_root="$runner_temp/mise-$version"
  readonly install_root
  scratch=$(mktemp -d "$runner_temp/setup-mise.XXXXXX")
  readonly scratch
  SETUP_MISE_SCRATCH=$scratch
  readonly SETUP_MISE_SCRATCH
  SETUP_MISE_ARCHIVE="$scratch/$archive"
  readonly SETUP_MISE_ARCHIVE
  trap cleanup EXIT

  curl --fail --location --silent --show-error \
    --output "$SETUP_MISE_ARCHIVE" \
    "https://github.com/jdx/mise/releases/download/v${version}/${archive}"
  printf '%s  %s\n' "$checksum" "$SETUP_MISE_ARCHIVE" | sha256sum --check

  mkdir -p "$install_root"
  tar --extract --xz --file "$SETUP_MISE_ARCHIVE" \
    --directory "$install_root" --strip-components=1

  "$install_root/bin/mise" --version
  printf 'executable=%s\n' "$install_root/bin/mise" >> "$github_output"
}

main "$@"
