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

- One **team** per client; one **project** maps 1:1 to a Kubernetes **namespace**.
- `ResourceQuota` caps CPU/RAM per project; `NetworkPolicy` isolates tenants.
- RBAC: team owner / member.

## Deployment flow

1. User registers an **App**: Git repo URL + branch + Dockerfile path + port +
   env/secrets + domain.
2. Deploy is triggered (UI button or Git webhook).
3. Control-plane creates a **Release** and launches a **Kaniko Job**: clone →
   build from the Dockerfile → push to the in-cluster registry (tag = commit SHA).
   Build logs stream to the UI.
4. On success it renders Kubernetes manifests and applies them: `Deployment` +
   `Service` + `Ingress` (Traefik) + `Secret` (env) + `HPA` + `PodDisruptionBudget`.
5. Rolling update with readiness gating; **automatic rollback** if the rollout
   does not become healthy within its deadline.
6. UI surfaces status, URL, logs, metrics and active alerts.

## Pillars

### Résilience
- `min_replicas >= 2` default; liveness/readiness/startup probes.
- `PodDisruptionBudget` + `topologySpreadConstraints` to survive node loss.
- `RollingUpdate` with `maxUnavailable: 0`; rollout deadline → auto-rollback.
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
