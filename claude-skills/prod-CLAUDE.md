# Production Environment — Strict Review Mode

> Claude reads this file when reviewing plans in the `live/prod/` directory.
> These rules are merged with the root CLAUDE.md and override where applicable.

## Review Strictness: MAXIMUM

- **ALL resource deletions are ❌ Critical** — must be explicitly justified
- **ALL security group changes require manual verification** — flag for security team review
- **ANY IAM policy change is ❌ Critical** — must be reviewed and approved by security team
- Require `prevent_destroy = true` on ALL stateful resources (RDS, S3, EFS, DynamoDB, ElastiCache)
- Instance/task sizing changes require explicit justification in the PR description
- **Zero tolerance** for resources without required tags
- Flag any change to database connection strings, endpoints, or credentials
- Flag any change to DNS records or certificate configurations
- Flag removal of CloudWatch alarms or monitoring configurations
