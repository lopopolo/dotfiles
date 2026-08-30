# GitHub Actions Runner Images Automation

The GitHub Actions runner images automation is a scheduled repository
maintenance role for keeping workflow runner labels aligned with GitHub-hosted
runner image support status. It should catch image migrations, deprecations,
brownouts, and retirements early enough that CI continues to exercise maintained
operating-system targets.

The automation must read `docs/automations/README.md`, this document, and the
repository's agent instructions before running. Human feedback on its inbox
items, pull requests, comments, reviews, failed validation, or missed changes
should update this runbook before the same class of issue repeats.
Automation-authored pull request comments must start with the stable prefix
`Codex automation note:`. Treat comments with that prefix as automation state,
not human feedback for this learning loop.

## Schedule

Run once per week. GitHub runner image changes are normally announced with lead
time, so a weekly cadence is sufficient.

## Scope

Review GitHub Actions workflow files under `.github/workflows/`, with emphasis
on `runs-on` labels and runner-image-sensitive assumptions.

The audit and CI workflows use explicit `ubuntu-24.04` runners, while the
repository-label workflow uses `ubuntu-latest`. Preserve that distinction:
developer-environment and policy checks require a reproducible Linux baseline,
whereas label synchronization intentionally follows GitHub's moving default.

Do not update pinned GitHub Actions versions. Dependabot owns action dependency
updates. Do not update job or service container images unless a runner-image
change makes a narrowly related compatibility adjustment necessary; the
repository's dependency process owns those images.

## Sources

Use authoritative current sources rather than memory. At minimum, inspect:

- the `actions/runner-images` README for available labels;
- open `actions/runner-images` issues carrying the `Announcement` label;
- GitHub-hosted runner documentation when label semantics, hardware, or software
  availability are unclear; and
- recent CI runs in this repository when a label or image-sensitive assumption
  appears questionable.

Include concrete dates and source links for migrations, deprecations, brownouts,
and retirements in the inbox summary and any pull request.

## Decision Rules

Preserve the intent of each job. An explicit label is a compatibility decision;
`*-latest` is a deliberate choice to follow GitHub's moving default. Do not
mechanically convert one style to the other.

When a new image becomes generally available, add or migrate coverage before a
previous image's brownouts begin. Remove a deprecated image before retirement
unless the repository documents a compatibility reason to retain it. Do not add
preview or beta images merely because they exist.

If a proposed label change alters a job matrix or its generated check names,
inspect required status-check contexts in the repository rulesets. Keep those
contexts aligned with the workflow jobs.

## Changes

If no repository change is needed, do not create a branch, commit, push, or pull
request. Open an inbox item with the labels checked, support state, source
links, and the next relevant dates.

If a change is needed, keep the diff scoped to runner-image maintenance and
create one commit and one pull request. Resolve the repository dynamically for
ruleset inspection:

```sh
repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
gh ruleset list --repo "$repo"
gh api "repos/$repo/rulesets/<ruleset-id>" \
  --jq '.rules[] | select(.type == "required_status_checks").parameters.required_status_checks[].context'
```

Ruleset edits are repository configuration changes, not git changes. Mention
every required-check context inspected or updated in the pull request and inbox
summary. If permissions prevent an update, open the pull request and lead the
inbox item with the exact manual ruleset change required.

Pull requests must use the `A-build`, `C-automation`, and `codex` labels. Do not
enable auto-merge when a label is in preview, a change drops an operating-system
family without replacement, relevant recent CI is failing, or authoritative
announcements are ambiguous. Auto-merge is acceptable for low-risk mechanical
updates with passing validation.

## Validation and Summary

Always run `git diff --check`. Run `actionlint` against changed workflows when
it is available; otherwise record that it was unavailable.

For documentation or workflow changes, also run:

```sh
mise exec -- make fmt-check
mise exec -- make lint
```

Open an inbox item after every run summarizing:

- runner labels reviewed and their current GitHub support state;
- source links and upcoming migration, brownout, or retirement dates;
- changes made or why no change was needed;
- required-check contexts inspected or updated;
- validation run and any skipped checks; and
- pull request and auto-merge status, if a pull request was opened.
