# Brume

**Brume** is a self-hosted PaaS: point it at a Git repository containing a
`Dockerfile`, set your environment variables and domain, and Brume builds the
image and deploys your app onto a [k3s](https://k3s.io) cluster with automatic
routing, TLS, autoscaling and observability.

It runs on **a single server or a fleet** — the orchestration model is the same
from 1 to N nodes.

## Pillars

- **Résilience** — multi-replica by default, health probes, pod disruption
  budgets, node spreading, zero-downtime rollouts with automatic rollback,
  replicated storage (Longhorn), backups.
- **Auto-scaling** — per-app Horizontal Pod Autoscaler (CPU/RAM) with
  configurable min/max replicas.
- **Observabilité & Alerting** — Prometheus metrics, Grafana dashboards, Loki
  logs, and Alertmanager alerts (CrashLoop, OOM, failed deploys, saturation,
  expiring certificates) via email / webhook / Slack.

## Stack

| Layer | Choice |
|---|---|
| Orchestration | k3s |
| Control-plane | Go (`chi`) + PostgreSQL |
| Image build | Kaniko (in-cluster Job) from a Dockerfile + Trivy scan |
| Registry | private in-cluster registry |
| Storage | Longhorn (replicated, node-independent volumes) |
| Routing / TLS | Traefik (bundled with k3s) + cert-manager |
| Managed addons | Postgres / MySQL / Redis per environment |
| Observability | Prometheus + Grafana + Loki + Alertmanager |
| Web UI | Go + `templ` + HTMX |

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design and
[`docs/ROADMAP.md`](docs/ROADMAP.md) for the phased delivery plan.

## Development

```sh
make db-up     # start a local Postgres
make dev       # run the control-plane against it
make test      # unit tests
```

The control-plane boots without a database in "smoke mode" (P0); `/readyz`
reflects database availability.

### Endpoints (P0)

| Path | Purpose |
|---|---|
| `GET /healthz` | liveness |
| `GET /readyz` | readiness (checks DB) |
| `GET /version` | build metadata |
| `GET /metrics` | Prometheus metrics |
| `GET /api/v1/ping` | API smoke check |

## Status

Early development. Current phase: **P0 — Foundations** (see roadmap).
