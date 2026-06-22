# Brume — Roadmap (MVP → production)

Each phase ends with a verifiable deliverable and green CI. "Full IA": every
phase is self-reviewed (`/code-review`, `/security-review`) and covered by
automated tests (unit + integration against an ephemeral k3d cluster + an E2E
smoke deploy).

The roadmap folds in the prioritised feature analysis (Tier 1 = blocking for
real client apps, Tier 2 = needed to sell to clients, Tier 3 = differentiators).

## Phases

| Phase | Scope | Deliverable |
|---|---|---|
| **P0 — Foundations** ✅ | Go scaffolding, full data model (teams/projects/apps/**processes**/**environments**/**addons**), migrations, config, health/metrics endpoints, CI, dev env, docs, installer skeleton | Binary builds, boots, `make test` green |
| **P1 — Control-plane & data** | Auth (sessions/JWT), CRUD for teams/projects/apps/**processes**/**environments**, `sqlc` queries, `client-go`, **namespace-per-environment** + ResourceQuota | API CRUD tested; namespaces created in k3d |
| **P2 — Build pipeline** | Git clone + Kaniko Job + push to in-cluster registry + build log streaming + **image vulnerability scan (Trivy)** | A repo with a Dockerfile yields a scanned image |
| **P3 — Resilient runtime** | Per-process Deployment/Service/Ingress, per-env env/secrets, domains + TLS (cert-manager), probes, PDB, topology spread, zero-downtime rollout + **auto-rollback**, **release/migration hook**, **distributed storage (Longhorn)** for volumes | App reachable over HTTPS, survives a pod & node loss |
| **P4 — Managed addons (Tier 1 #1)** | One-click **Postgres / MySQL / Redis** per environment, auto connection-string injection, addon backups + restore | App provisions a DB and connects to it |
| **P5 — Auto-scaling** | Per-process **HPA** (CPU/RAM), configurable min/max replicas, resource requests/limits | A process scales out under load in an integration test |
| **P6 — Observability & alerting** | Loki log aggregation + live UI streaming, Prometheus per-app metrics, **Alertmanager** default rules + email/webhook/Slack, **audit log** (who did what) | CrashLoop on a test app raises an alert; actions are audited |
| **P7 — Git-push & automation** | **Webhooks (GitHub/GitLab) → auto build+deploy**, **cron jobs**, **worker** process runtime | `git push` triggers a deploy; a cron runs on schedule |
| **P8 — Dashboard** | Web UI (`templ`+HTMX): projects, apps, environments, processes, deploy, env/secrets, domains, addons, logs, metrics, alerts, audit | Full deploy journey without touching the API by hand |
| **P9 — Security & multi-tenant hardening** | **SSO/OIDC + 2FA**, **API tokens**, granular RBAC, **Kyverno admission control**, NetworkPolicies, rate limiting, secrets scanning | A tenant cannot escape its namespace; SSO login works |
| **P10 — Billing & cost** | Metering CPU/RAM/storage **per app/client**, plans/tiers, spend limits, **per-client cost dashboard** | Usage is metered and shown per client |
| **P11 — Backups & DR** | Client data + addon backups with **tested restore**, control-plane Postgres snapshot/restore, documented cluster-restore runbook | A simulated data loss is recovered from backup |
| **P12 — CLI & config-as-code** | `brume` CLI (`deploy`/`logs`/`exec`/`run`/`scale`), **`brume.yaml`** manifest committed in the repo | Deploy + tail logs + shell into a container from the CLI |
| **P13 — Multi-node & platform ops** | Node-join flow, **HA control-plane**, zero-downtime platform upgrades, complete `install.sh` | App survives adding a 2nd node; one-command install |

## Tier 3 — Differentiators (backlog, post-MVP)

- **Preview environments per PR** (ephemeral) — strong sales argument.
- **Canary / blue-green deploys** + traffic splitting.
- **Distributed tracing** (OpenTelemetry + Tempo) on top of metrics/logs.
- **Public status page** per client + synthetic uptime monitoring.
- **Non-HTTP services** (TCP / gRPC / WebSocket) at the ingress.
- **Scale-to-zero** (KEDA) for idle apps → cost savings.
- **Cluster autoscaling** (auto-add nodes) — straightforward on cloud, hard on bare-metal.

## Out of scope for MVP (later v2 candidates)

Nixpacks/buildpack auto-detection, prebuilt-image deploys, Terraform/Pulumi
provider, marketplace of addons.
