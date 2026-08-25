#!/usr/bin/env bash
# Install the latest official mise release from its signed installer.

set -Eeuo pipefail
IFS=$'\n\t'

readonly MISE_RELEASE_KEY_FINGERPRINT=24853EC9F655CE80B48E6C3A8B81C9D17413A06D
MISE_INSTALL_SCRATCH=

cleanup() {
  if [[ -n $MISE_INSTALL_SCRATCH ]]; then
    rm -rf -- "$MISE_INSTALL_SCRATCH"
  fi
}

main() {
  local command gpg_status install_path installer signed_installer

  for command in curl gpg grep; do
    if ! command -v "$command" > /dev/null; then
      echo "install-mise: required command is missing: $command" >&2
      return 1
    fi
  done

  install_path=${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}
  MISE_INSTALL_SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/install-mise.XXXXXX")
  readonly MISE_INSTALL_SCRATCH
  trap cleanup EXIT

  signed_installer="$MISE_INSTALL_SCRATCH/install.sh.sig"
  installer="$MISE_INSTALL_SCRATCH/install.sh"
  curl --fail --location --proto '=https' --silent --show-error \
    --output "$signed_installer" \
    https://mise.jdx.dev/install.sh.sig
  if ! gpg_status=$(gpg --batch --status-fd 1 \
    --output "$installer" --decrypt "$signed_installer"); then
    return 1
  fi
  if ! grep -qF \
    "[GNUPG:] VALIDSIG $MISE_RELEASE_KEY_FINGERPRINT " <<< "$gpg_status"; then
    echo "install-mise: installer was not signed by the mise release key" >&2
    return 1
  fi

  MISE_INSTALL_PATH="$install_path" \
    MISE_INSTALL_HELP=0 \
    MISE_INSTALL_SKIP_IF_EXISTS=1 \
    sh "$installer"
  "$install_path" --version
}

main "$@"
