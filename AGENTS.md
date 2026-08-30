# Repository Instructions

## GitHub labels

`.github/labels.toml` is the complete desired set of repository labels. There is
no label synchronization workflow. When changing the manifest or finding label
drift, reconcile the current GitHub repository with an authenticated `gh` CLI:

- create labels that are declared but missing;
- update mismatched colors and descriptions;
- rename labels in place so historical issue and pull request associations are
  preserved;
- delete labels that are not declared; and
- fetch the remote labels again and verify exact parity before finishing.
