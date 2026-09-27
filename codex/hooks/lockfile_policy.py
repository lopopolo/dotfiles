#!/usr/bin/env python3
"""Block direct Codex edits to generated lockfiles.

This hook is deliberately narrow. It does not track sessions, inspect dirty git
state, or decide whether package-manager commands are allowed. It only denies
direct manual edit attempts that target lockfiles.
"""

from __future__ import annotations

import dataclasses
import json
import os
import re
import shlex
import sys
from pathlib import Path
from typing import Any


LOCKFILE_NAMES = frozenset(
    {
        ".terraform.lock.hcl",
        "bun.lock",
        "bun.lockb",
        "Cargo.lock",
        "composer.lock",
        "Gemfile.lock",
        "go.sum",
        "mise.lock",
        "npm-shrinkwrap.json",
        "package-lock.json",
        "Pipfile.lock",
        "pnpm-lock.yaml",
        "poetry.lock",
        "uv.lock",
        "yarn.lock",
    }
)

PATH_FIELD_NAMES = frozenset(
    {
        "dest",
        "destination",
        "file",
        "file_path",
        "filename",
        "path",
        "target",
    }
)

PATCH_PATH_RE = re.compile(
    r"^\*\*\* (?:Add File|Update File|Delete File|Move to): (?P<path>.+)$"
)

LOCKFILE_TOKEN_RE = re.compile(
    r"(?<![A-Za-z0-9_.-])("
    + "|".join(re.escape(name) for name in sorted(LOCKFILE_NAMES, key=len, reverse=True))
    + r")(?![A-Za-z0-9_.-])"
)

SHELL_SEPARATORS = frozenset({";", "&", "&&", "|", "||"})
SHELL_REDIRECTS = frozenset({">", ">>", "<>"})
DIRECT_WRITE_COMMANDS = frozenset(
    {"apply_patch", "cp", "install", "mv", "rm", "tee", "touch", "truncate"}
)
EDITOR_COMMANDS = frozenset({"ed", "emacs", "ex", "nvim", "vim"})
SCRIPT_EVAL_COMMANDS = frozenset({"node", "python", "python3", "ruby"})
SCRIPT_EVAL_FLAGS = frozenset({"-c", "-e"})
GIT_DIRECT_WRITE_SUBCOMMANDS = frozenset({"checkout", "restore"})
ENV_ASSIGNMENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=.*$")

SHELL_PUNCTUATION = ";&|<>()"


@dataclasses.dataclass(frozen=True)
class ParsedShellCommand:
    tokens: list[str]
    parse_error: str | None = None


def main() -> int:
    payload = read_payload()
    tool_name = str(payload.get("tool_name") or "")
    tool_input = payload.get("tool_input")

    if tool_name == "apply_patch" or any(looks_like_patch(text) for text in strings(tool_input)):
        lockfiles = sorted(lockfile_patch_paths(tool_input))
        if lockfiles:
            deny(
                "Direct patch edits to lockfiles are blocked. Run the owning "
                f"toolchain instead. Touched: {', '.join(lockfiles)}"
            )
        return 0

    lockfile_paths = sorted(lockfile_path_fields(tool_input))
    if tool_name in {"Edit", "MultiEdit", "Write"} and lockfile_paths:
        deny(
            "Direct file edits to lockfiles are blocked. Run the owning "
            f"toolchain instead. Touched: {', '.join(lockfile_paths)}"
        )

    command = shell_command(tool_input)
    if command and shell_command_directly_writes_lockfile(command):
        deny(
            "Direct shell edits to lockfiles are blocked. Run the owning "
            f"toolchain instead. Mentioned: {', '.join(sorted(lockfile_tokens(command)))}"
        )

    return 0


def read_payload() -> dict[str, Any]:
    raw = sys.stdin.read()
    if not raw.strip():
        return {}

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as exc:
        print(f"lockfile hook received invalid JSON: {exc}", file=sys.stderr)
        raise SystemExit(2)

    if isinstance(payload, dict):
        return payload

    return {}


def strings(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]

    if isinstance(value, dict):
        out: list[str] = []
        for item in value.values():
            out.extend(strings(item))
        return out

    if isinstance(value, list):
        out: list[str] = []
        for item in value:
            out.extend(strings(item))
        return out

    return []


def looks_like_patch(text: str) -> bool:
    return "*** Begin Patch" in text and "*** End Patch" in text


def lockfile_patch_paths(tool_input: Any) -> set[str]:
    paths: set[str] = set()
    for text in strings(tool_input):
        if not looks_like_patch(text):
            continue
        for line in text.splitlines():
            match = PATCH_PATH_RE.match(line)
            if match:
                path = match.group("path").strip()
                if is_lockfile_path(path):
                    paths.add(path)
    return paths


def lockfile_path_fields(value: Any) -> set[str]:
    paths: set[str] = set()

    if isinstance(value, dict):
        for key, item in value.items():
            if isinstance(item, str) and key in PATH_FIELD_NAMES and is_lockfile_path(item):
                paths.add(item)
            else:
                paths.update(lockfile_path_fields(item))
    elif isinstance(value, list):
        for item in value:
            paths.update(lockfile_path_fields(item))

    return paths


def shell_command(tool_input: Any) -> str:
    if isinstance(tool_input, dict):
        for key in ("command", "cmd"):
            value = tool_input.get(key)
            if isinstance(value, str):
                return value

    return ""


def shell_command_directly_writes_lockfile(command: str) -> bool:
    if not lockfile_tokens(command):
        return False

    parsed = parse_shell_command(command)
    if parsed.parse_error is not None:
        return False

    if redirects_to_lockfile(parsed.tokens):
        return True

    return any(command_segment_directly_writes_lockfile(segment) for segment in shell_segments(parsed.tokens))


def parse_shell_command(command: str) -> ParsedShellCommand:
    lexer = shlex.shlex(command, posix=True, punctuation_chars=SHELL_PUNCTUATION)
    lexer.whitespace_split = True
    lexer.commenters = ""

    try:
        return ParsedShellCommand(tokens=list(lexer))
    except ValueError as exc:
        return ParsedShellCommand(tokens=[], parse_error=str(exc))


def redirects_to_lockfile(tokens: list[str]) -> bool:
    for index, token in enumerate(tokens):
        if token in SHELL_REDIRECTS and index + 1 < len(tokens) and is_lockfile_path(tokens[index + 1]):
            return True

        if token.startswith(">") and is_lockfile_path(token.lstrip(">")):
            return True

    return False


def shell_segments(tokens: list[str]) -> list[list[str]]:
    segments: list[list[str]] = [[]]
    for token in tokens:
        if token in SHELL_SEPARATORS:
            if segments[-1]:
                segments.append([])
            continue
        segments[-1].append(token)
    return [segment for segment in segments if segment]


def command_segment_directly_writes_lockfile(segment: list[str]) -> bool:
    if not any(is_lockfile_path(token) or lockfile_tokens(token) for token in segment):
        return False

    argv = normalize_shell_argv(segment)
    if not argv:
        return False

    command = Path(argv[0]).name

    if command in DIRECT_WRITE_COMMANDS or command in EDITOR_COMMANDS:
        return True

    if command in {"sed", "gsed"}:
        return any(token == "-i" or token.startswith("-i") for token in argv[1:])

    if command == "perl":
        return any(token == "-pi" or token.startswith("-pi") or token.startswith("-i") for token in argv[1:])

    if command in SCRIPT_EVAL_COMMANDS:
        return any(token in SCRIPT_EVAL_FLAGS for token in argv[1:])

    if command == "git" and len(argv) > 1:
        return argv[1] in GIT_DIRECT_WRITE_SUBCOMMANDS

    return False


def normalize_shell_argv(segment: list[str]) -> list[str]:
    argv = list(segment)

    while argv and ENV_ASSIGNMENT_RE.match(argv[0]):
        argv.pop(0)

    if argv and Path(argv[0]).name == "env":
        argv.pop(0)
        while argv:
            if argv[0] == "--":
                argv.pop(0)
                break
            if argv[0].startswith("-") or ENV_ASSIGNMENT_RE.match(argv[0]):
                argv.pop(0)
                continue
            break

    if argv and Path(argv[0]).name == "sudo":
        argv.pop(0)
        while argv and argv[0].startswith("-"):
            option = argv.pop(0)
            if option in {"-u", "-g", "-h"} and argv:
                argv.pop(0)

    if argv and Path(argv[0]).name in {"command", "builtin"}:
        argv.pop(0)

    return argv


def lockfile_tokens(text: str) -> set[str]:
    return {match.group(1) for match in LOCKFILE_TOKEN_RE.finditer(text)}


def is_lockfile_path(path: str) -> bool:
    return Path(path).name in LOCKFILE_NAMES


def deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    raise SystemExit(0)


if __name__ == "__main__":
    os.environ.pop("PYTHONINSPECT", None)
    raise SystemExit(main())
