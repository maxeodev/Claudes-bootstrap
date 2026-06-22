# Brume — Architecture

Brume is a self-hosted Platform-as-a-Service built on top of k3s. This document
describes the components, the deployment flow, and how the three product pillars
(résilience, auto-scaling, observabilité/alerting) are realised.

## High-level components

```
                            ┌──────────────────────────────────────────┐
                            │                k3s cluster                 │
  ┌────────────┐  HTTPS     │  ┌─────────────┐   ┌────────────────────┐ │
  │  Operator  │───────────▶│  │ Brume       │   │ Traefik (ingress)  │ │
  │  / Client  │  dashboard │  │ control-    │   └─────────┬──────────┘ │
  └────────────┘  + API     │  │ plane (Go)  │             │            │
                            │  └─────┬───────┘   ┌─────────▼──────────┐ │
                            │        │           │  Tenant namespaces │ │
                            │        │ client-go │  (one per project) │ │
                            │        ▼           │  Deployments/Svc/  │ │
                            │  ┌───────────┐     │  Ingress/HPA/PDB   │ │
                            │  │ Postgres  │     └────────────────────┘ │
                            │  └───────────┘                            │
                            │  ┌───────────┐  ┌──────────────────────┐  │
                            │  │ Registry  │  │ Kaniko build Jobs    │  │
                            │  └───────────┘  └──────────────────────┘  │
                            │  Observability: Prometheus / Grafana /    │
                            │  Loki / Alertmanager / metrics-server     │
                            └──────────────────────────────────────────┘
```

### Control-plane (Go)

- HTTP API (`chi`) + server-rendered web UI (`templ` + HTMX), single binary.
- State in PostgreSQL (`pgx`, migrations via `golang-migrate`, typed queries via `sqlc`).
- Drives the cluster with `client-go`.
- **Stateless**: can run as N replicas behind a Service for HA.

### Tenancy & isolation

- One **team** per client; a **project** groups apps; each **environment**
  (production/staging/…) maps 1:1 to an isolated Kubernetes **namespace**.
- `ResourceQuota` caps CPU/RAM/storage per environment; `NetworkPolicy`
  isolates tenants from each other.
- RBAC: team owner / member (granular roles + SSO/OIDC + API tokens in P9).

### Environments & process model

- An **app** defines build config (repo, branch, Dockerfile) and one or more
  **processes**: `web` (gets an ingress), `worker` (long-running), `cron`
  (scheduled). Resilience/autoscaling knobs are set per process.
- Each app has multiple **environments**; env vars, secrets, domains, addons
  and deployments are scoped to an environment.
- `release_command` is an optional **pre-deploy hook** (e.g. DB migrations) run
  before traffic shifts to a new release.

### Managed addons

- Per-environment **Postgres / MySQL / Redis** provisioned on demand; the
  connection string is injected into the app as a generated `Secret`.
- Addon data lives on distributed storage and is backed up (P4 / P11).

### Storage

- **Longhorn** provides replicated, node-independent persistent volumes so
  stateful workloads and addons survive pod rescheduling and node loss — k3s's
  default `local-path` is single-node only and unsuitable for a fleet.

## Deployment flow

1. User registers an **App** (repo + Dockerfile + processes) and an
   **environment** with its env/secrets + domain.
2. Deploy is triggered (UI button, CLI, or Git webhook → auto-deploy).
3. Control-plane creates a **Release** and launches a **Kaniko Job**: clone →
   build from the Dockerfile → scan (Trivy) → push to the in-cluster registry
   (tag = commit SHA). Build logs stream to the UI.
4. The optional **release hook** runs (e.g. migrations) against the environment.
5. On success it renders per-process Kubernetes manifests and applies them into
   the environment's namespace: `Deployment`/`CronJob` + `Service` + `Ingress`
   (Traefik, web only) + `Secret` (env) + `HPA` + `PodDisruptionBudget`.
6. Rolling update with readiness gating; **automatic rollback** if the rollout
   does not become healthy within its deadline.
7. UI surfaces status, URL, logs, metrics, active alerts and the audit trail.

## Pillars

### Résilience
- `min_replicas >= 2` default; liveness/readiness/startup probes.
- `PodDisruptionBudget` + `topologySpreadConstraints` to survive node loss.
- `RollingUpdate` with `maxUnavailable: 0`; rollout deadline → auto-rollback.
- **Longhorn** replicated volumes so stateful data survives node failure.
- Control-plane runs HA; Postgres backed up (`pg_dump` cron → volume/object store).

### Auto-scaling
- Per-app `HorizontalPodAutoscaler` on CPU/RAM via `metrics-server`.
- User-configurable `min_replicas`, `max_replicas`, `cpu_target_percent`.
- v2: KEDA for event-driven scaling and scale-to-zero.

### Observabilité & Alerting
- **Metrics**: Prometheus scrapes the control-plane (`/metrics`) and workloads;
  Grafana dashboards bundled.
- **Logs**: Loki + a log shipper; pod logs streamed live to the UI and retained.
- **Alerting**: Alertmanager with default rules — `CrashLoopBackOff`, `OOMKilled`,
  failed deployment, CPU/RAM saturation, certificate near expiry, probe failures —
  routed to email / webhook / Slack.
- **Audit log**: every state-changing action (deploy, scale, secret change, addon
  provisioning) is recorded with actor + timestamp for multi-tenant traceability.

### Security & commercial (later phases)
- **Security** (P9): SSO/OIDC + 2FA, API tokens, granular RBAC, Kyverno admission
  control (blocks `privileged`/`hostPath`), image vulnerability + secrets scanning.
- **Billing & cost** (P10): per-app/per-client metering of CPU/RAM/storage, plans,
  spend limits, cost dashboard.
- **Backups & DR** (P11): tested restore of client + addon data and the
  control-plane database, plus a cluster-restore runbook.

## Domains & TLS without a domain

`BRUME_BASE_DOMAIN` defines the wildcard used for generated hostnames
(`<app>.<project>.<base>`). When unset, Brume derives a hostname from the cluster
ingress IP via `sslip.io` (`<ip>.sslip.io`) so apps are reachable over HTTP
immediately; real Let's Encrypt certificates via cert-manager kick in once a real
domain is configured.

## Installation

`deploy/install.sh` provisions a server end-to-end: installs k3s, cert-manager,
the in-cluster registry, the observability stack, then deploys Brume itself onto
the cluster. Additional nodes join with a printed `k3s agent` command.

## Configuration (environment)

| Variable | Purpose |
|---|---|
| `BRUME_ADDR` | listen address (default `:8080`) |
| `BRUME_DATABASE_URL` | Postgres DSN |
| `BRUME_BASE_DOMAIN` | wildcard domain for apps |
| `BRUME_PUBLIC_IP` | ingress IP for the sslip.io fallback |
| `BRUME_SECRETS_KEY` | key used to encrypt app secrets at rest |
| `BRUME_SHUTDOWN_TIMEOUT` | graceful shutdown window |
