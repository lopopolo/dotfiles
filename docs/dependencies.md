# Dependency and Supply Chain Posture

Every external input needs one canonical owner and a reproducible update path.
This repository prefers platform tools and repository-owned shell for small,
stable behavior, and takes dependencies when an upstream owns a format, runtime,
application, or sufficiently complex maintenance surface.

## Ownership Boundaries

Dependencies belong to one of four surfaces:

- Homebrew Bundle owns durable macOS applications, fonts, system utilities,
  native libraries, and Mac App Store install intent recorded in
  `homebrew-packages/Brewfile.duke`.
- mise owns language runtimes and repository-local command-line tooling declared
  in `mise.toml`.
- pnpm owns Node.js dependencies and their transitive graph through
  `package.json` and `pnpm-lock.yaml`.
- GitHub Actions owns CI integrations, with every external action pinned to an
  immutable commit.

Do not install language runtimes or version-sensitive development tools through
Homebrew when mise can own them. Do not copy editor extension state into the
Brewfile; VS Code Settings Sync owns that state.

## Pins and Lockfiles

Direct tool and package dependencies are exact pins. Do not use mutable
selectors such as `latest`, `lts`, branches, or broad version ranges for durable
repository tooling.

`mise.toml` is the canonical version source for Node.js, uv, shellcheck, and
shfmt. `mise.lock` records their Linux x64 and Apple Silicon macOS artifacts and
checksums. After changing a mise pin, run:

```shell
mise lock --platform linux-x64,macos-arm64
```

Review every changed URL, checksum, and provenance field. GitHub Actions must
resolve versions from `mise.toml` or install a locked subset with the repo-owned
mise actions; workflow YAML must not duplicate those versions.

Mise itself is the unavoidable bootstrap exception. The exact mise version and
official Linux x64 archive checksum live together in
`.github/actions/setup-mise/action.yaml`. Update and verify both values in the
same change.

Corepack selects pnpm from the exact `packageManager` entry in `package.json`.
pnpm owns `pnpm-lock.yaml`; do not hand-edit the lockfile.

## Homebrew

The Duke Brewfile records desired top-level formulae and casks, not transitive
formula dependencies. Its `mas` declarations snapshot Mac App Store applications
that should be restored after signing in. Regeneration deliberately excludes npm
packages and VS Code extensions.

Use `brew bundle check` to validate desired state and `brew bundle cleanup`
without `--force` to review drift. Package upgrades are rolling workstation
maintenance rather than reproducible repository inputs, so the Brewfile records
names rather than versions.

## Container Appliance Exception

The yt-dlp appliance deliberately tracks a mutable `latest` image because site
extractor freshness is part of its function. This is an explicit exception to
immutable input policy: it runs interactively, is disposable, mounts only the
chosen download directory, and prunes superseded dangling image data after a
successful refresh.

The image remains a third-party supply-chain boundary. Revisit this exception if
the wrapper gains credentials, background execution, broader host mounts, or a
stable automated digest-update path.

## Update Policy

Dependabot owns GitHub Actions and npm dependency pull requests with a seven-day
cooldown. The dependency sweep runbook owns pins that Dependabot cannot update
reliably, including mise tools, the mise bootstrap checksum, the mise lockfile,
Homebrew package intent, and the yt-dlp appliance exception.

Dependency changes must preserve a single canonical version source and pass the
repository formatting, lint, lockfile, and workflow checks.
