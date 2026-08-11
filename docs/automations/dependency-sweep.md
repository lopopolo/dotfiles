# Dependency Sweep Automation

The dependency sweep is the repeatable maintenance role for pins that Dependabot
does not reliably update. It keeps workstation bootstrap inputs and repository
tooling reproducible, reviewable, and aligned with [`docs/dependencies.md`].

The automation must read the dependency posture before changing pins. Human
feedback on its pull requests, comments, failed validation, or follow-up tasks
should update this runbook before the same class of change is repeated.

[`docs/dependencies.md`]: ../dependencies.md

## Dependabot First

Review open Dependabot pull requests before scanning hand-maintained pins. A
mechanical, low-risk update with passing checks may use auto-merge. Leave higher
risk updates for human review and explain any non-obvious risk.

If Dependabot changes merge, update the working branch from `trunk` before
creating an automation-owned dependency change.

## Scope

The sweep owns:

- exact Node.js, uv, shellcheck, and shfmt versions in `mise.toml`;
- Linux x64 and Apple Silicon macOS artifacts in `mise.lock`;
- the mise bootstrap version and official archive checksum in
  `.github/actions/setup-mise/action.yaml`;
- the pnpm `packageManager` pin and transitive lockfile refreshes;
- Homebrew formula and cask intent, including deprecated or disabled packages;
- mutable or versioned inputs used by the yt-dlp container appliance; and
- other hand-maintained tool or download pins discovered in the repository.

Dependabot remains the primary owner for external GitHub Actions and direct npm
dependency updates.

## Tooling Pins

Treat `mise.toml` as the only canonical version source for tools declared there.
Do not copy those versions into workflow YAML. First-party setup actions receive
versions from `.github/actions/mise-tool-versions`; tools without a useful setup
action are installed from `mise.lock` through `.github/actions/mise-install`.

After changing a mise tool pin, run:

```shell
mise lock --platform linux-x64,macos-arm64
mise install --locked
```

Review every lockfile URL, checksum, and provenance field. Update the exact mise
bootstrap version and checksum together from the official release and checksum
manifest; mise cannot verify its own installation before it exists.

Do not use floating selectors such as `latest`, `lts`, ranges, branches, or
major-only versions for repository tooling.

## Homebrew Review

Compare installed top-level packages with `homebrew-packages/Brewfile.duke`. Use
`brew bundle cleanup` without `--force` to inspect drift. Do not remove packages
or casks unless their ownership and replacement are clear.

Check declared packages for deprecation or disablement. Keep Homebrew focused on
native system tools and applications; move language-scoped tools to mise.

## Pull Requests

Keep updates small enough to attribute failures to one dependency surface.
Include old and new versions, authoritative release notes, lockfile changes,
checks performed, and any retained exception. Do not combine dependency refresh
with unrelated configuration work.

Automation-authored comments must begin with `Codex automation note:`.

## Validation

Run the checks relevant to every changed surface:

```shell
mise exec -- make fmt-check
mise exec -- make lint
mise install --locked
brew bundle check --file=homebrew-packages/Brewfile.duke
```

When GitHub Actions change, also review the pinned action SHAs and run the
repository workflow security audit.
