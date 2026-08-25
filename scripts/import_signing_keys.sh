#!/usr/bin/env bash
# Import the OpenPGP keys used by upstream projects this workstation consumes.

set -Eeuo pipefail
IFS=$'\n\t'

readonly MISE_RELEASE_KEY_FINGERPRINT=24853EC9F655CE80B48E6C3A8B81C9D17413A06D
readonly ARTICHOKE_RELEASE_KEY_FINGERPRINT=C9838F104021F59EE6F6BCBEB199D0347FDA14A4
readonly RUST_SECURITY_KEY_FINGERPRINT=5769C88BF5DD3D14A234A7ACEFB9860AE7520DAC
readonly LOCAL_CERTIFICATION_KEY_FINGERPRINT=B54B7B3FA506699945AF2E6E46047D739B6AE0B1
readonly GITHUB_WEB_FLOW_KEY_FINGERPRINT=968479A1AFF927E37D1A566BB5690EEEBB952194
readonly -a GITHUB_WEB_FLOW_KEY_FINGERPRINTS=(
  5DE3E0509C47EA3CF04A42D34AEE18F83AFDEB23
  "$GITHUB_WEB_FLOW_KEY_FINGERPRINT"
)
readonly -a NODE_RELEASE_KEY_FINGERPRINTS=(
  5BE8A3F6C8A5C01D106C0AD820B1A390B168D356
  DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7
  CC68F5A3106FF448322E48ED27F5E38D5B0A215F
  8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600
  890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4
  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C
  108F52B48DB57BB0CC439B2997B01419BD92F80A
  655F3B5C1FB3FA8D1A0CA6BDE4A7D232B936D2FD
  A363A499291CBBC940DD62E41F10027AF002F8B0
)
readonly -a LLVM_RELEASE_KEY_FINGERPRINTS=(
  D574BD5D1D0E98895E3BF90044F2485E45D59042
  474E22316ABF4785A88C6E8EA2C794A986419D8A
  B6C8F98282B944E3B0D5C2530FC3042E345AD05D
  0FB96824606D15FDD54C3D092FFC629D3F563BDC
  71046D1E9C6656BDD61171873E83BABF4A4F9E85
  FFB3368980F3E6BB5737145A316C56D064CACBA5
)
SIGNING_KEYS_SCRATCH=

cleanup() {
  if [[ -n $SIGNING_KEYS_SCRATCH ]]; then
    rm -rf -- "$SIGNING_KEYS_SCRATCH"
  fi
}

primary_fingerprints() {
  gpg --batch --show-keys --with-colons --fingerprint "$1" |
    awk -F: '$1 == "pub" { want = 1; next }
      want && $1 == "fpr" { print $10; want = 0 }'
}

import_key_file() {
  local key_file=$1
  shift

  verify_key_file "$key_file" "$@"
  gpg --batch --import "$key_file"
  local fingerprint
  for fingerprint in "$@"; do
    locally_certify_key "$fingerprint"
  done
}

verify_key_file() {
  local actual_fingerprints expected_fingerprints key_file=$1
  shift

  actual_fingerprints=$(primary_fingerprints "$key_file" | LC_ALL=C sort)
  expected_fingerprints=$(printf '%s\n' "$@" | LC_ALL=C sort)
  if [[ $actual_fingerprints != "$expected_fingerprints" ]]; then
    echo "signing-keys: unexpected fingerprint in $key_file" >&2
    echo "expected:" >&2
    echo "$expected_fingerprints" >&2
    echo "actual:" >&2
    echo "$actual_fingerprints" >&2
    return 1
  fi

}

locally_certify_key() {
  local inactive_reason validity

  validity=$(
    gpg --batch --with-colons --list-keys "$1" |
      awk -F: '$1 == "pub" { print $2; exit }'
  )
  case $validity in
    e) inactive_reason=expired ;;
    r) inactive_reason=revoked ;;
    d) inactive_reason=disabled ;;
  esac
  if [[ -n ${inactive_reason:-} ]]; then
    echo "signing-keys: skipping local certification of $inactive_reason key: $1"
    return
  fi

  gpg --batch --yes \
    --local-user "$LOCAL_CERTIFICATION_KEY_FINGERPRINT" \
    --quick-lsign-key "$1"
}

require_local_certification_key() {
  local fingerprint

  fingerprint=$(
    gpg --batch --with-colons \
      --fingerprint --list-secret-keys "$LOCAL_CERTIFICATION_KEY_FINGERPRINT" |
      awk -F: '$1 == "sec" { want = 1; next }
        want && $1 == "fpr" { print $10; exit }'
  )
  if [[ $fingerprint != "$LOCAL_CERTIFICATION_KEY_FINGERPRINT" ]]; then
    echo "signing-keys: local certification key is unavailable" >&2
    return 1
  fi
}

require_commands() {
  local command
  for command in awk curl gpg sort; do
    if ! command -v "$command" > /dev/null; then
      echo "signing-keys: required command is missing: $command" >&2
      return 1
    fi
  done
}

download_and_import_key() {
  local expected_fingerprint=$1 filename=$2 url=$3 key_file

  key_file="$SIGNING_KEYS_SCRATCH/$filename"
  curl --fail --location --proto '=https' --silent --show-error \
    --output "$key_file" "$url"
  import_key_file "$key_file" "$expected_fingerprint"
}

import_mise_release_key() {
  local fingerprint

  gpg --batch --keyserver hkps://keys.openpgp.org \
    --recv-keys "$MISE_RELEASE_KEY_FINGERPRINT"
  fingerprint=$(
    gpg --batch --with-colons --fingerprint "$MISE_RELEASE_KEY_FINGERPRINT" |
      awk -F: '$1 == "pub" { want = 1; next }
        want && $1 == "fpr" { print $10; exit }'
  )
  if [[ $fingerprint != "$MISE_RELEASE_KEY_FINGERPRINT" ]]; then
    echo "signing-keys: mise release key fingerprint verification failed" >&2
    return 1
  fi
  locally_certify_key "$MISE_RELEASE_KEY_FINGERPRINT"
}

import_github_web_flow_keys() {
  local github_keys="$SIGNING_KEYS_SCRATCH/github-web-flow.gpg"

  curl --fail --location --proto '=https' --silent --show-error \
    --output "$github_keys" https://github.com/web-flow.gpg
  verify_key_file "$github_keys" "${GITHUB_WEB_FLOW_KEY_FINGERPRINTS[@]}"
  gpg --batch --import "$github_keys"
  locally_certify_key "$GITHUB_WEB_FLOW_KEY_FINGERPRINT"
}

import_artichoke_release_key() {
  download_and_import_key \
    "$ARTICHOKE_RELEASE_KEY_FINGERPRINT" artichoke-ci.gpg \
    https://github.com/artichoke-ci.gpg
}

import_node_release_keys() {
  local fingerprint
  for fingerprint in "${NODE_RELEASE_KEY_FINGERPRINTS[@]}"; do
    download_and_import_key "$fingerprint" "node-$fingerprint.asc" \
      "https://raw.githubusercontent.com/nodejs/release-keys/main/keys/$fingerprint.asc"
  done
}

import_rust_security_key() {
  download_and_import_key \
    "$RUST_SECURITY_KEY_FINGERPRINT" rust-security.asc \
    https://www.rust-lang.org/static/keys/rust-security-team-key.gpg.ascii
}

import_llvm_release_keys() {
  local llvm_keys="$SIGNING_KEYS_SCRATCH/llvm-release-keys.asc"

  curl --fail --location --proto '=https' --silent --show-error \
    --output "$llvm_keys" \
    https://releases.llvm.org/release-keys.asc
  import_key_file "$llvm_keys" "${LLVM_RELEASE_KEY_FINGERPRINTS[@]}"
}

main() {
  local project

  require_commands

  SIGNING_KEYS_SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/signing-keys.XXXXXX")
  readonly SIGNING_KEYS_SCRATCH
  trap cleanup EXIT
  require_local_certification_key

  if (($# == 0)); then
    set -- mise github artichoke node rust llvm
  fi

  for project in "$@"; do
    case $project in
      mise) import_mise_release_key ;;
      github) import_github_web_flow_keys ;;
      artichoke) import_artichoke_release_key ;;
      node) import_node_release_keys ;;
      rust) import_rust_security_key ;;
      llvm) import_llvm_release_keys ;;
      *)
        echo "signing-keys: unknown key set: $project" >&2
        return 1
        ;;
    esac
  done

  printf 'signing-keys: verified and refreshed; locally certified active keys:'
  printf ' %s' "$@"
  printf '\n'
}

main "$@"
