# Brume — Progress Tracker

Living checklist. Update the status of a task **as soon as it changes**.
Legend: `[ ]` todo · `[~]` in progress · `[x]` done.

- **Current phase:** P1 — Control-plane & data (not started)
- **Last completed:** P0 — Foundations
- **Last updated:** 2026-06-22

---

## P0 — Foundations `[x]`
- [x] Go module + project layout
- [x] Control-plane skeleton (`chi`) with `/healthz` `/readyz` `/version` `/metrics`
- [x] Config loader (+ sslip.io domain fallback)
- [x] Postgres connection layer (`store`)
- [x] Initial schema + migrations (teams/projects/apps/processes/environments/addons/releases/deployments)
- [x] Unit tests (config + server)
- [x] GitHub Actions CI (tidy/vet/test -race/build)
- [x] Dev env (docker-compose Postgres, Makefile)
- [x] Docs (README, ARCHITECTURE, ROADMAP) + installer skeleton
- [x] Verified: build/vet/test green; binary boots; migration up/down on Postgres 16

## P1 — Control-plane & data `[ ]`
- [ ] Auth: signup/login, session/JWT, password hashing
- [ ] `sqlc` setup + typed queries
- [ ] CRUD: teams, team members
- [ ] CRUD: projects
- [ ] CRUD: apps + processes (web/worker/cron)
- [ ] CRUD: environments
- [ ] `client-go` integration + kubeconfig wiring
- [ ] Namespace-per-environment provisioning + `ResourceQuota`
- [ ] Tests: API CRUD + namespace creation against ephemeral k3d
- [ ] Self-review (`/code-review`, `/security-review`) + CI green

## P2 — Build pipeline `[ ]`
- [ ] Git clone of app repo (branch)
- [ ] Kaniko build Job from Dockerfile
- [ ] Push to in-cluster registry (tag = commit SHA)
- [ ] Build log streaming
- [ ] Trivy image vulnerability scan
- [ ] Tests + self-review

## P3 — Resilient runtime `[ ]`
- [ ] Per-process Deployment/Service/Ingress generation
- [ ] Per-env env vars + secrets injection (encrypted at rest)
- [ ] Domains + TLS via cert-manager
- [ ] Probes (liveness/readiness/startup), PDB, topology spread
- [ ] Zero-downtime rollout + automatic rollback
- [ ] Release/migration pre-deploy hook
- [ ] Longhorn distributed storage for volumes
- [ ] Tests (survives pod & node loss) + self-review

## P4 — Managed addons `[ ]`
- [ ] One-click Postgres / MySQL / Redis per environment
- [ ] Auto connection-string injection
- [ ] Addon backups + restore
- [ ] Tests + self-review

## P5 — Auto-scaling `[ ]`
- [ ] Per-process HPA (CPU/RAM)
- [ ] Configurable min/max replicas + resource requests/limits
- [ ] Tests (scale-out under load) + self-review

## P6 — Observability & alerting `[ ]`
- [ ] Loki log aggregation + live UI streaming
- [ ] Prometheus per-app metrics surfaced
- [ ] Alertmanager default rules + email/webhook/Slack
- [ ] Audit log (actor + action + timestamp)
- [ ] Tests + self-review

## P7 — Git-push & automation `[ ]`
- [ ] Webhooks (GitHub/GitLab) → auto build+deploy
- [ ] Cron jobs runtime
- [ ] Worker process runtime
- [ ] Tests + self-review

## P8 — Dashboard `[ ]`
- [ ] Web UI (`templ`+HTMX): projects/apps/environments/processes
- [ ] Deploy, env/secrets, domains, addons
- [ ] Logs, metrics, alerts, audit views
- [ ] Tests + self-review

## P9 — Security & multi-tenant hardening `[ ]`
- [ ] SSO/OIDC + 2FA
- [ ] API tokens + granular RBAC
- [ ] Kyverno admission control (block privileged/hostPath)
- [ ] NetworkPolicies + rate limiting + secrets scanning
- [ ] Tests + self-review

## P10 — Billing & cost `[ ]`
- [ ] Metering CPU/RAM/storage per app/client
- [ ] Plans/tiers + spend limits
- [ ] Per-client cost dashboard
- [ ] Tests + self-review

## P11 — Backups & DR `[ ]`
- [ ] Client + addon data backups with tested restore
- [ ] Control-plane Postgres snapshot/restore
- [ ] Cluster-restore runbook
- [ ] Tests + self-review

## P12 — CLI & config-as-code `[ ]`
- [ ] `brume` CLI (deploy/logs/exec/run/scale)
- [ ] `brume.yaml` manifest support
- [ ] Tests + self-review

## P13 — Multi-node & platform ops `[ ]`
- [ ] Node-join flow
- [ ] HA control-plane
- [ ] Zero-downtime platform upgrades
- [ ] Complete `install.sh`
- [ ] Tests (app survives adding a 2nd node) + self-review

---

## Tier 3 — Differentiators (backlog)
- [ ] Preview environments per PR
- [ ] Canary / blue-green deploys + traffic splitting
- [ ] Distributed tracing (OpenTelemetry + Tempo)
- [ ] Public status page + synthetic monitoring
- [ ] Non-HTTP services (TCP/gRPC/WebSocket)
- [ ] Scale-to-zero (KEDA)
- [ ] Cluster autoscaling
