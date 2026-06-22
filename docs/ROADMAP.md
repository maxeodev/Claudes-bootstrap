# Brume — Roadmap (MVP)

Each phase ends with a verifiable deliverable and green CI. "Full IA": every
phase is self-reviewed (`/code-review`, `/security-review`) and covered by
automated tests (unit + integration against an ephemeral k3d cluster + an E2E
smoke deploy).

| Phase | Scope | Deliverable |
|---|---|---|
| **P0 — Foundations** ✅ | Go scaffolding, DB schema + migrations, config, health/metrics endpoints, CI, dev env, docs, installer skeleton | Binary builds, boots, `make test` green |
| **P1 — Control-plane & data** | Auth (sessions/JWT), users/teams/projects/apps CRUD, `sqlc` queries, `client-go` integration, namespace-per-project + ResourceQuota | API CRUD tested; namespaces created in k3d |
| **P2 — Build pipeline** | Git clone + Kaniko Job + push to in-cluster registry + build log streaming | A repo with a Dockerfile yields an image in the registry |
| **P3 — Resilient runtime** | Deployment/Service/Ingress generation, env/secrets injection, domains + TLS (cert-manager), probes, PDB, topology spread, zero-downtime rollout + auto-rollback | An app is reachable over HTTPS and survives a pod kill |
| **P4 — Auto-scaling** | Per-app HPA (CPU/RAM), configurable min/max replicas, resource requests/limits | App scales out under load in an integration test |
| **P5 — Observability & alerting** | Loki log aggregation + live UI streaming, Prometheus metrics surfaced per app, Alertmanager default rules + email/webhook/Slack notifications | CrashLoop on a test app raises an alert |
| **P6 — Dashboard** | Web UI (`templ`+HTMX): create project, deploy, env, domains, logs, scale, alerts | Full deploy journey without touching the API by hand |
| **P7 — Multi-node & hardening** | Node join flow, HA control-plane, NetworkPolicies, RBAC, rate limiting, Postgres backups, complete `install.sh` | App survives adding a 2nd node; one-command install |

## Out of scope for MVP (v2 candidates)
Nixpacks/buildpack auto-detection, git-push deploy, prebuilt-image deploys,
one-click managed databases, scale-to-zero (KEDA), usage-based billing, dedicated CLI.
