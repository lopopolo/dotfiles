#!/usr/bin/env bash
# Merge the repo-managed Codex runtime defaults into the local config.

set -Eeuo pipefail
IFS=$'\n\t'
umask 077

CODEX_CONFIG_TEMP=

cleanup() {
  if [[ -n $CODEX_CONFIG_TEMP ]]; then
    rm -f -- "$CODEX_CONFIG_TEMP"
  fi
}

config_value() {
  local source wanted_key wanted_section

  source=$1
  wanted_key=$2
  wanted_section=$3
  readonly source wanted_key wanted_section

  awk -v wanted_key="$wanted_key" -v wanted_section="$wanted_section" '
    /^[[:space:]]*\[/ {
      section = $0
      sub(/^[[:space:]]*\[/, "", section)
      sub(/\][[:space:]]*(#.*)?$/, "", section)
    }

    section == wanted_section && $1 == wanted_key {
      sub(/^[^=]*=[[:space:]]*/, "")
      sub(/[[:space:]]+#.*$/, "")
      print
      exit
    }
  ' "$source"
}

merge_config() {
  local source target approval_policy approvals_reviewer sandbox_mode web_search
  local network_access

  source=$1
  target=$2
  approval_policy=$(config_value "$source" approval_policy "")
  approvals_reviewer=$(config_value "$source" approvals_reviewer "")
  sandbox_mode=$(config_value "$source" sandbox_mode "")
  web_search=$(config_value "$source" web_search "")
  network_access=$(config_value \
    "$source" network_access sandbox_workspace_write)
  readonly source target approval_policy approvals_reviewer sandbox_mode web_search
  readonly network_access

  awk \
    -v approval_policy="$approval_policy" \
    -v approvals_reviewer="$approvals_reviewer" \
    -v sandbox_mode="$sandbox_mode" \
    -v web_search="$web_search" \
    -v network_access="$network_access" '
      function is_header(line) {
        return line ~ /^[[:space:]]*\[/
      }

      function is_managed_hook_header(line) {
        return line ~ /^[[:space:]]*\[\[hooks\.PreToolUse(\.hooks)?\]\][[:space:]]*(#.*)?$/
      }

      function header_name(line, name) {
        name = line
        sub(/^[[:space:]]*\[/, "", name)
        sub(/\][[:space:]]*(#.*)?$/, "", name)
        return name
      }

      function write_missing_root_settings() {
        if (!has_approval_policy) {
          print "approval_policy = " approval_policy
        }
        if (!has_approvals_reviewer) {
          print "approvals_reviewer = " approvals_reviewer
        }
        if (!has_sandbox_mode) {
          print "sandbox_mode = " sandbox_mode
        }
        if (!has_web_search) {
          print "web_search = " web_search
        }
      }

      { lines[NR] = $0 }

      END {
        section = ""
        for (i = 1; i <= NR; i++) {
          line = lines[i]
          if (is_header(line)) {
            section = header_name(line)
            if (section == "sandbox_workspace_write") {
              has_sandbox_workspace_write = 1
            }
            continue
          }

          if (section == "" && line ~ /^[[:space:]]*approval_policy[[:space:]]*=/) {
            has_approval_policy = 1
          } else if (section == "" && line ~ /^[[:space:]]*approvals_reviewer[[:space:]]*=/) {
            has_approvals_reviewer = 1
          } else if (section == "" && line ~ /^[[:space:]]*sandbox_mode[[:space:]]*=/) {
            has_sandbox_mode = 1
          } else if (section == "" && line ~ /^[[:space:]]*web_search[[:space:]]*=/) {
            has_web_search = 1
          } else if (section == "sandbox_workspace_write" && line ~ /^[[:space:]]*network_access[[:space:]]*=/) {
            has_network_access = 1
          }
        }

        section = ""
        wrote_root_settings = 0
        skipping_managed_hooks = 0
        for (i = 1; i <= NR; i++) {
          line = lines[i]
          if (is_managed_hook_header(line)) {
            skipping_managed_hooks = 1
            continue
          }
          if (skipping_managed_hooks) {
            if (!is_header(line)) {
              continue
            }
            skipping_managed_hooks = 0
          }
          if (is_header(line)) {
            if (!wrote_root_settings) {
              write_missing_root_settings()
              wrote_root_settings = 1
            }
            section = header_name(line)
            print line
            if (section == "sandbox_workspace_write" && !has_network_access) {
              print "network_access = " network_access
              has_network_access = 1
            }
            continue
          }

          if (section == "features" && line ~ /^[[:space:]]*view_image_tool[[:space:]]*=/) {
            continue
          }
          if (section == "" && line ~ /^[[:space:]]*approval_policy[[:space:]]*=/) {
            print "approval_policy = " approval_policy
            continue
          }
          if (section == "" && line ~ /^[[:space:]]*approvals_reviewer[[:space:]]*=/) {
            print "approvals_reviewer = " approvals_reviewer
            continue
          }
          if (section == "" && line ~ /^[[:space:]]*sandbox_mode[[:space:]]*=/) {
            print "sandbox_mode = " sandbox_mode
            continue
          }
          if (section == "" && line ~ /^[[:space:]]*web_search[[:space:]]*=/) {
            print "web_search = " web_search
            continue
          }
          if (section == "sandbox_workspace_write" && line ~ /^[[:space:]]*network_access[[:space:]]*=/) {
            if (!wrote_network_access) {
              print "network_access = " network_access
              wrote_network_access = 1
            }
            continue
          }

          print line
        }

        if (!wrote_root_settings) {
          write_missing_root_settings()
        }
        if (!has_sandbox_workspace_write) {
          print ""
          print "[sandbox_workspace_write]"
          print "network_access = " network_access
        }
      }
    ' "$target" > "$CODEX_CONFIG_TEMP"
}

install_managed_file() {
  local source target backup current_link install_temp

  source=$1
  target=$2
  mkdir -p -- "$(dirname "$target")"

  if [[ -L $target ]]; then
    current_link=$(readlink "$target")
    if [[ $current_link != "$source" ]]; then
      echo "install-codex-config: refusing to replace symlink: $target" >&2
      return 1
    fi

    rm -- "$target"
  fi

  if [[ -e $target ]]; then
    if cmp -s -- "$source" "$target"; then
      return 0
    fi

    backup="$target.pre-dotfiles"
    if [[ -e $backup || -L $backup ]]; then
      echo "install-codex-config: local file differs and backup exists: $backup" >&2
      return 1
    fi
    mv -- "$target" "$backup"
  fi

  install_temp=$(mktemp "$target.XXXXXX")
  if ! cp -p -- "$source" "$install_temp"; then
    rm -f -- "$install_temp"
    return 1
  fi
  mv -f -- "$install_temp" "$target"
}

main() {
  local dotfiles_root config_dir source target

  dotfiles_root=$(git rev-parse --show-toplevel)
  readonly dotfiles_root
  config_dir="$HOME/.codex"
  source="$dotfiles_root/codex/config.toml"
  target="$config_dir/config.toml"

  if [[ ! -f $source ]]; then
    echo "install-codex-config: missing source: $source" >&2
    return 1
  fi

  mkdir -p -- "$config_dir"
  if [[ -L $target ]]; then
    echo "install-codex-config: refusing to replace symlink: $target" >&2
    return 1
  fi

  install_managed_file \
    "$dotfiles_root/codex/rules/default.rules" \
    "$config_dir/rules/default.rules"
  install_managed_file \
    "$dotfiles_root/codex/hooks/lockfile_policy.py" \
    "$config_dir/hooks/lockfile_policy.py"
  install_managed_file \
    "$dotfiles_root/codex/hooks.json" \
    "$config_dir/hooks.json"

  CODEX_CONFIG_TEMP=$(mktemp "$config_dir/config.toml.XXXXXX")
  trap cleanup EXIT

  if [[ -f $target ]]; then
    merge_config "$source" "$target"
  else
    cp -- "$source" "$CODEX_CONFIG_TEMP"
  fi

  chmod 600 "$CODEX_CONFIG_TEMP"
  mv -f -- "$CODEX_CONFIG_TEMP" "$target"
  CODEX_CONFIG_TEMP=
}

main "$@"
