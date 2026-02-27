# Development Environment — Lenient Review Mode

> Claude reads this file when reviewing plans in the `live/dev/` directory.
> These rules are merged with the root CLAUDE.md and relax certain checks.

## Review Strictness: LOW

- Skip cost warnings for instance sizing — dev is for experimentation
- Skip tagging warnings (nice to have, not critical)
- Resource deletions are informational only
- Focus review on:
  - Security issues that could affect other environments
  - Unintended deletions of shared resources
  - Changes that look like they were meant for a different environment
