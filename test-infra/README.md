# Test Infrastructure for AI Code Review

This example provides a realistic Terraform + Terragrunt setup to test the Claude Code AI review integration with Atlantis.

## Structure

```
test-infra/
├── CLAUDE.md                          # AI reviewer skill file (root)
├── atlantis.yaml                      # Atlantis project config
├── terragrunt.hcl                     # Root Terragrunt config
├── modules/
│   ├── vpc/main.tf                    # VPC module
│   ├── security-group/main.tf         # Security group module
│   └── ecs-service/main.tf            # ECS Fargate service module
└── live/
    ├── dev/
    │   ├── CLAUDE.md                  # Lenient review rules for dev
    │   └── ap-southeast-1/
    │       ├── vpc/terragrunt.hcl
    │       ├── sg/terragrunt.hcl
    │       └── ecs-api/terragrunt.hcl
    └── prod/
        ├── CLAUDE.md                  # Strict review rules for prod
        └── ap-southeast-1/
            ├── vpc/terragrunt.hcl
            ├── sg/terragrunt.hcl
            └── ecs-api/terragrunt.hcl
```

## Test Scenarios

### Scenario 1: CPU/Memory Increase (Cost Impact)

**What to change:** Edit `live/prod/ap-southeast-1/ecs-api/terragrunt.hcl`
```diff
- cpu    = 512
- memory = 1024
+ cpu    = 1024
+ memory = 2048
```

**Expected AI review findings:**
- ⚠️ Cost warning — doubling Fargate compute in prod
- ✅ Change appears intentional

---

### Scenario 2: Accidental Scale to Zero

**What to change:** Edit `live/prod/ap-southeast-1/ecs-api/terragrunt.hcl`
```diff
- desired_count = 3
+ desired_count = 0
```

**Expected AI review findings:**
- ❌ Critical — setting `desired_count = 0` in production will take the service offline
- Likely accidental (common copy-paste from dev config)

---

### Scenario 3: Unintended Security Group Deletion

**How to simulate:** This happens when someone manually adds an SG rule in the AWS console (e.g., allowing port 3306 for database debugging), but doesn't add it to the Terraform code. When `terraform plan` runs, it shows the manual rule being destroyed.

**What the plan output would show:**
```
  - aws_security_group_rule.manual_allow_db will be destroyed
    - cidr_blocks = ["10.20.1.0/24"]
    - from_port   = 3306
    - protocol    = "tcp"
    - type        = "ingress"
```

**Expected AI review findings:**
- ❌ Critical — unintended deletion of a manually-added MySQL access rule
- Recommendation: Import the rule or add it to the SG config

---

### Scenario 4: Missing Required Tags

**What to change:** Edit `live/prod/ap-southeast-1/ecs-api/terragrunt.hcl` — remove tags:
```diff
  tags = {
    Service    = "api"
-   Team       = "platform"
-   CostCenter = "CC-1234"
  }
```

**Expected AI review findings:**
- ⚠️ Warning — missing required tags: `Team`, `CostCenter`
- In prod CLAUDE.md, this is treated as critical

---

### Scenario 5: Open Security Group (Security Risk)

**What to change:** Edit `live/prod/ap-southeast-1/sg/terragrunt.hcl` — add wide-open rule:
```hcl
  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.20.0.0/16"]
      description = "Allow HTTPS from VPC"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]         # <-- WIDE OPEN
      description = "Temporary debug access"
    }
  ]
```

**Expected AI review findings:**
- ❌ Critical — `0.0.0.0/0` ingress on all ports in production
- Recommendation: Restrict to specific CIDRs and ports

---

## How to Test Locally

### 1. Build the Atlantis AI Review Image

```bash
cd /path/to/atlantis
docker build -f Dockerfile.ai-review -t atlantis-ai-review:latest .
```

### 2. Test the Review Script Manually

```bash
# Run the container with mock env vars
docker run --rm -it \
  -e ANTHROPIC_API_KEY=your-key-here \
  -e GH_TOKEN=your-github-token \
  -e PLANFILE=/tmp/mock-plan \
  -e DIR=/test-infra/live/prod/ap-southeast-1/ecs-api \
  -e WORKSPACE=default \
  -e REPO_REL_DIR=live/prod/ap-southeast-1/ecs-api \
  -e BASE_REPO_OWNER=your-org \
  -e BASE_REPO_NAME=your-repo \
  -e PULL_NUM=1 \
  -e PULL_AUTHOR=test-user \
  -e HEAD_BRANCH_NAME=feat/update-cpu \
  -e BASE_BRANCH_NAME=main \
  -e HEAD_COMMIT=abc1234 \
  -e PROJECT_NAME=prod-ecs-api \
  atlantis-ai-review:latest \
  /bin/bash
```

### 3. End-to-End Test with Atlantis

1. Push this `test-infra/` folder to a GitHub repo
2. Configure Atlantis with `--repo-config=repos.yaml`
3. Create a PR with one of the test scenario changes above
4. Comment `atlantis plan` on the PR
5. Verify:
   - Plan comment appears normally
   - AI review comment appears as a separate comment
   - Review correctly identifies the issues for the scenario

## Notes

- The Terragrunt config uses a **local backend** (`state/` directory) for testing simplicity
- No real AWS resources are created unless you have valid AWS credentials configured
- The `CLAUDE.md` files at different levels demonstrate hierarchical review rules
- `live/prod/CLAUDE.md` enforces stricter review than `live/dev/CLAUDE.md`
