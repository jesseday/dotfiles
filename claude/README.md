# Agent instruction files

This directory contains instruction files for configuring and guiding the
behavior of AI agents. Each file typically includes specific guidelines, rules,
or parameters that the agent should follow during its interactions.

## Setup

`setup.sh` symlinks `CLAUDE.md` to `~/.claude/CLAUDE.md`, which Claude Code
loads in every session regardless of project. Edits here take effect in new
sessions.

Don't also symlink it into individual projects: a project's own `CLAUDE.md` is
loaded on top of this one, so a copy there would load the same instructions
twice.
