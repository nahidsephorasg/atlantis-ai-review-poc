# Production — Strict Review Mode

- **ALL resource deletions are ❌ Critical** — must be explicitly justified
- **ALL security group changes require manual verification**
- Require `prevent_destroy = true` on stateful resources (RDS, S3, DynamoDB)
- Instance/task sizing increases require justification
- `desired_count = 0` is ❌ Critical — likely accidental
- Zero tolerance for missing required tags
- Flag any change to networking (subnets, route tables, NAT gateways)
