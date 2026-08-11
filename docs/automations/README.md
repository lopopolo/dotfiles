# Automation Conventions

Automations should keep machine-authored output distinguishable from human
feedback so later runs learn from the right signals.

Automation-authored pull request comments must start with the stable prefix
`Codex automation note:`. Treat comments with that prefix as automation state,
not human feedback for an automation learning loop.

Document each scheduled or repeatable automation in this directory and keep its
prompt small. The prompt should identify the role and tell the automation to
read and follow its repository runbook.

Current runbooks:

- [Dependency Sweep]

[Dependency Sweep]: ./dependency-sweep.md
