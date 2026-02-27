# Development — Lenient Review Mode

- Skip cost warnings for instance sizing
- Skip tagging warnings (nice to have, not critical)
- Resource deletions are ⚠️ Warning (not critical)
- Focus on:
  - Security issues that could affect other environments
  - Unintended deletions of shared resources
  - Changes that look like they were meant for prod
