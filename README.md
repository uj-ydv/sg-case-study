# Internal AI Application Platform — Architecture & IaC Scaffold

This repository is a design scaffold for an internal AI application on Azure, covering App Service, APIM, Application Gateway, Storage Account, Cosmos DB, Key Vault, AI Foundry, Azure Machine Learning, and Container Registry. It assumes an existing Azure Landing Zone, Microsoft Entra ID tenant, hub-and-spoke network, enterprise CI/CD toolchain, and enterprise logging/monitoring, and builds on top of those foundational services rather than provisioning them.

---

## Networking Approach

User traffic enters via the Application Gateway (WAF) in the spoke, routes to APIM, and forwards to the App Service. The App Service, AI, and Data components communicate exclusively over the Microsoft backbone via Private Endpoints.

One spoke VNet is provisioned per environment, peered to the existing hub VNet. The hub provides DNS resolution and firewall egress; it does not carry application traffic. Subnet layouts are identical across Dev, UAT, and Prod, with differing CIDR ranges:

| Subnet | Purpose | Associated Resources |
| :--- | :--- | :--- |
| `snet-agw` | Ingress WAF Traffic | Application Gateway |
| `snet-apim` | API Gateway & Governance | API Management (APIM) |
| `snet-appsvc` | Outbound VNet Integration | App Service Plan |
| `snet-pe-data` | Private Endpoints Isolation | Storage, Cosmos DB, Key Vault, ACR, AI Foundry, Azure ML |

---

## Security Approach

Every service-to-service connection follows a strict zero-trust baseline: system-assigned managed identity, explicit RBAC role assignments, and private endpoint isolation. No connection strings, plain keys, or Key Vault access policies are utilized.

| Consumer Identity | Target Resource | Granted RBAC Role | Purpose / Access Scope |
| :--- | :--- | :--- | :--- |
| **App Service** | Key Vault | `Key Vault Secrets User` | Reading application runtime secrets |
| **App Service** | Storage Account | `Storage Blob Data Contributor` | Blob storage read/write data access |
| **App Service** | Cosmos DB | `Cosmos DB Built-in Data Contributor` | Data plane document CRUD operations |
| **App Service** | Container Registry | `AcrPull` | Container image pulling/pushing |
| **AI Foundry** | Key Vault, Storage, ACR | `Key Vault Secrets User`, `Storage Blob Data Contributor`, `AcrPull` | Workspace backend system dependencies |
| **Azure Machine Learning** | Key Vault, Storage, ACR | `Key Vault Secrets User`, `Storage Blob Data Contributor`, `AcrPull`, `AcrPush` | Workspace backend system dependencies |
| **APIM** | Key Vault | `Key Vault Secrets User` | Fetching custom TLS certificates |

---

## CI/CD Approach

While the scenario references GitHub Actions, this design utilizes **Azure DevOps (ADO) Pipelines**, aligning with established enterprise practices.

### Pipeline Architecture: Path-Triggered Environment Isolation
Rather than a single monolithic pipeline, each environment (`Dev`, `UAT`, `Prod`) utilizes a **dedicated pipeline file** triggered strictly by path changes within its respective environment directory (`infra/environments/<env>/*`) and shared modules (`infra/modules/*`).

| Pipeline Level | Trigger Paths | Authentication Model | Execution Behavior |
| :--- | :--- | :--- | :--- |
| **Dev Pipeline** | `environments/dev/**`, `modules/**` | `sc-sgaip-dev` (OIDC) | Auto-plan on PR, Auto-apply on merge to `main` |
| **UAT Pipeline** | `environments/uat/**`, `modules/**` | `sc-sgaip-uat` (OIDC) | Auto-plan on PR, Manual approval gate before apply |
| **Prod Pipeline** | `environments/prod/**`, `modules/**` | `sc-sgaip-prod` (OIDC) | Auto-plan on PR, Governance & approval gate before apply |
* **Strict Branch Protection (`main`):** The `main` branch is locked against direct commits. All changes must be submitted via Pull Requests (PRs). Direct pushes are disabled via branch policies.
* **Branch Naming Standard:** Promote a naming convention for source control branches (e.g., `feature/YYYYMMDD-feature-name`) all lower case only.
* **Authentication via Workload Identity:** Azure Resource Manager (ARM) Service Connections utilize Workload Identity Federation (OIDC) rather than client secrets, eliminating long-lived credentials. Each environment uses its own dedicated Service Principal and Service Connection.
* **PR Validation (Plan):** Opening a Pull Request against `main` triggers the environment validation pipeline to run `terraform fmt`, `terraform validate`, and `terraform plan`.
* **Automated Apply on Merge:** Merging to `main` executes `terraform plan` --> Approval Stage -->  `terraform apply`.

```yaml
# Pipeline configuration for infra/environments/prod/azure-pipelines.yml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - infra/environments/prod/**
      - infra/modules/**
    exclude:
      - README.md

pr:
  branches:
    include:
      - main
  paths:
    include:
      - infra/environments/prod/**
      - infra/modules/**
    exclude:
      - README.md
```

---


## Key design trade-offs

1. System-assigned vs shared user-assigned managed identity. Chose system-assigned, one identity per resource. This keeps blast radius small; there is no risk of a reused identity accumulating permissions across multiple resources over time. The cost is lifecycle coupling: if a resource is replaced (a forced Terraform recreate), its identity and every RBAC grant tied to it are destroyed and have to be reapplied.
2. Subnet ownership within Central Platform Repo: This keeps CIDR planning and NSG rules consistent in one place, but it means every consumer module's deployment depends on networking applying first
3. Private endpoint file structure: per-module vs shared abstraction. Chose per-module: each module that needs one (key-vault, storage, cosmosdb, container-registry, app-service, ai-foundry, machine-learning) owns its own private-endpoint.tf. While evaluating structures for this exercise, I opted to isolate the private endpoint. This keeps main.tf focused on the core resource while benefit is that anyone auditing "what has a private endpoint" can just look for private-endpoint.tf across the module tree.
4. Directory-per-environment vs Terragrunt. Chose directory-per-environment: separate root modules for dev, uat, prod, each with its own state and provider block. Terragrunt would keep this DRY with generated backend/provider blocks, but it adds a wrapper tool which doesn't fit a lightweight exercise. Accepted the duplication across the three environment folders as the cost.

---

## Assumptions and Known Risks

#### Assumptions:

- One Azure subscription per environment (Dev, UAT, Prod), consistent with the existing Landing Zone
- The hub already provides firewall/NVA egress and centralised DNS; spokes forward DNS to the hub
- AI Foundry and Azure Machine Learning sit in the same spoke as the application, not a separate shared AI spoke, on the basis that this is a single internal application rather than shared platform infrastructure
- No external or B2C users; all auth is via Entra ID (App Service Easy Auth or APIM validate-jwt)
- Cosmos DB is single-region initially, not multi-region

#### Known risks:

- This is a design scaffold, not a validated deployment; modules define the intended resources and interfaces but have not been run through a clean terraform plan/apply cycle end to end
- Role assignments are designed to be created inline within each consumer module, scoped to the backend resource IDs. However, in this lightweight scaffold, the complete IAM bindings are conceptual and not fully coded.


---

## Repository Structure

```text
infra/
├── environments/
│   ├── dev/
│   ├── uat/
│   └── prod/
├── modules/
│   ├── ai-foundry/
│   ├── apim/
│   ├── app-gateway/
│   ├── app-service/
│   ├── container-registry/
│   ├── cosmosdb/
│   ├── key-vault/
│   ├── machine-learning/
│   ├── networking/
│   └── storage/
└── README.md
```

---

## Naming Conventions

| Resource Type | Dev Naming Standard | Prod Naming Standard |
| :--- | :--- | :--- |
| **Resource Group** | `sgaip-dev-rg` | `sgaip-prod-rg` |
| **Key Vault** | `sgaip-dev-kv-{suffix}` | `sgaip-prod-kv-{suffix}` |
| **Storage Account** | `sgaipdevst{suffix}` | `sgaipprodst{suffix}` |
| **Container Registry** | `sgaipdevacr{suffix}` | `sgaipprodacr{suffix}` |
| **API Management** | `sgaip-dev-apim-{suffix}` | `sgaip-prod-apim-{suffix}` |
| **Application Gateway** | `sgaip-dev-agw` | `sgaip-prod-agw` |