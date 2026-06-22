# CLAUDE.md

Entry point for any session working on this repository. Read this first, then
`docs/PROGRESS.md` to see where we are.

## What we're building

**Brume** — a self-hosted PaaS that builds client apps from a `Dockerfile` and
deploys them onto a **k3s** cluster (1 to N servers), with automatic routing,
TLS, autoscaling and observability.

Pillars: **résilience**, **auto-scaling**, **observabilité/alerting**.

## Where the plan lives

- `docs/ROADMAP.md` — phases P0→P13 + Tier 3 backlog.
- `docs/PROGRESS.md` — **living progress tracker** (update it as work advances).
- `docs/ARCHITECTURE.md` — full design (tenancy, environments, processes,
  addons, storage, pillars, security/billing/DR).

## Stack

Go (`chi`) control-plane + PostgreSQL state, drives k3s via `client-go`.
Kaniko builds + in-cluster registry, Traefik + cert-manager for routing/TLS,
Longhorn storage, Prometheus/Grafana/Loki/Alertmanager observability.
Web UI in Go `templ` + HTMX.

## Working agreement

- Develop on branch `claude/busy-heisenberg-1lmmru`. Commit + push when a unit
  of work is complete.
- "Full IA": each phase is self-reviewed (`/code-review`, `/security-review`)
  and covered by tests (unit + integration on ephemeral k3d + an E2E smoke
  deploy). Keep CI green.
- **Update `docs/PROGRESS.md` whenever a task changes state.**

## Common commands

```sh
make build   # build the control-plane binary
make test    # unit tests
make vet     # go vet
make dev     # run against a local Postgres (make db-up first)
```

## Layout

```
cmd/brume-server/   control-plane entrypoint
internal/config     env configuration
internal/server     HTTP routes + observability endpoints
internal/store      Postgres access
internal/k8s        client-go integration (from P1)
migrations/         SQL migrations (golang-migrate format)
deploy/install.sh   server installer (fleshed out in P7/P13)
docs/               ROADMAP, PROGRESS, ARCHITECTURE
```
