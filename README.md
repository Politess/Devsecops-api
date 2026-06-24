# DevSecOps API

A simple Node.js REST API with a production-grade DevSecOps pipeline deployed to AWS ECS Fargate.

Built as a portfolio project demonstrating security-first CI/CD practices.

---

## Pipeline overview

```
Push / PR
    │
    ├── secrets-scan   GitLeaks — scans all commits for leaked credentials
    ├── sast           Semgrep — static analysis (OWASP Top 10, Node.js rules)
    ├── sca            npm audit — known CVEs in dependencies
    │
    ├── test           Jest — unit tests with coverage report
    │
    ├── build          Docker multistage build (non-root, minimal Alpine image)
    │
    ├── image-scan     Trivy — CVE scan of the built image, results → GitHub Security tab
    ├── iac-scan       Checkov — Terraform misconfiguration checks
    │
    └── deploy (main only)
            OIDC auth to AWS (no static credentials)
            Push image → ECR
            terraform apply
            ECS service updated
```

---

## Security design decisions

| Decision | Why |
|---|---|
| OIDC instead of static AWS keys | Short-lived tokens; nothing to rotate or leak |
| Non-root Docker user | Limits blast radius if the container process is compromised |
| Multistage Docker build | devDependencies and test files never enter the production image |
| `image_tag_mutability = IMMUTABLE` on ECR | Every deployment is traceable to an exact commit |
| `readonlyRootFilesystem = true` on ECS task | Container can't write to disk at runtime |
| ECS tasks accept traffic from ALB only | Not directly exposed to the internet |
| Remote Terraform state with encryption + locking | Prevents state corruption and concurrent applies |
| Checkov skips are documented | Auditable — every accepted risk has a written justification |

---

## Infrastructure

- **VPC** — dedicated VPC with two public subnets across two AZs
- **ECS Fargate** — serverless container runtime, two tasks for availability
- **ECR** — private image registry with scan-on-push and lifecycle policy
- **ALB** — Application Load Balancer with health checks on `/health`
- **IAM** — least-privilege roles; GitHub Actions uses OIDC federated identity
- **CloudWatch** — centralised logs with 30-day retention

---

## Local development

```bash
# Run the API
npm install
npm start

# Run tests
npm test

# Build the Docker image
docker build -t devsecops-api .
docker run -p 3000:3000 devsecops-api
```

---

## Deploying from scratch

1. Create the Terraform state bucket and DynamoDB lock table manually:
   ```bash
   aws s3api create-bucket --bucket devsecops-api-tfstate --region eu-west-2 \
     --create-bucket-configuration LocationConstraint=eu-west-2
   aws s3api put-bucket-versioning --bucket devsecops-api-tfstate \
     --versioning-configuration Status=Enabled
   aws dynamodb create-table --table-name devsecops-api-tflock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST --region eu-west-2
   ```

2. Update `terraform/variables.tf` with your GitHub username.

3. Run `terraform apply` once locally to create the OIDC provider and IAM role.

4. Add the `AWS_ROLE_ARN` output value as a GitHub Actions secret.

5. Push to main — the pipeline handles everything from here.

---

## API endpoints

| Method | Path | Description |
|---|---|---|
| GET | /health | Health check (used by ECS) |
| GET | /items | List all items |
| GET | /items/:id | Get item by ID |
| POST | /items | Create new item |
