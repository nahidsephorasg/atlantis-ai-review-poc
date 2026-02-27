# Staging Environment — Moderate Review Mode

> Claude reads this file when reviewing plans in the `live/staging/` directory.
> These rules are merged with the root CLAUDE.md.

## Review Strictness: MODERATE

- Resource deletions are ⚠️ Warning (not critical, but flag them)
- Security group changes still require review
- IAM policy changes are ⚠️ Warning
- Cost warnings are informational only
- Tagging is recommended but not critical
- Focus on security and unintended side effects
