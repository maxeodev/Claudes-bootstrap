# Claudes-bootstrap

**🇬🇧 English** · [🇫🇷 Français](./README.fr.md)

> Open-source catalog of **Claude Code bootstraps** for software teams.
> Spin up an AI-augmented squad in minutes — tailored to your mission and your stack.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

## Why

Configuring Claude Code for a team — agents, commands, hooks, permissions, integrations — takes
time and gets redone on every project. **Claudes-bootstrap** ships ready-to-use, **auditable**,
**telemetry-free** configurations you install and adapt.

## Principles

- **No telemetry.** Nothing leaves your machine. Feedback is **opt-in** (`/feedback`).
- **Least privilege.** Default permissions are minimal and documented.
- **Open source (MIT).** Everything is auditable.
- **Sustainable.** Stacks are isolated fragments: adding one doesn't touch the core.

## What makes it different

The space is crowded with massive piles of generic agents. We deliberately go the other way:

| The current market | Our angle |
|---|---|
| 100+ generic agents | **Lean squads by mission** (4 considered agents) |
| "Install and figure it out" | **Wizard + Handoff** (need → spec → delivery) |
| Quality unproven | **Eval gate** in CI *(coming)* |
| Security absent | **Zero telemetry + least privilege** (enterprise posture) |

## Quick start

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
/setup      # least-privilege config tailored to your stack
/doctor     # verify the install
/handoff "Your need or a Jira ticket key"
```

Full guide: [`docs/getting-started.md`](./docs/getting-started.md).

## Available bootstraps

| Bootstrap | Description |
|---|---|
| [`squad-realisation`](./bootstraps/squad-realisation/README.md) | Delivery squad: architect, developer, reviewer, integrator. Stacks: Angular, Spring Boot. |

## Status

🚧 **v1 in progress** — vertical slice: **Squad de réalisation** + **Angular** & **Spring Boot** +
**Handoff** + **wizard** + **`/feedback`**. See the plan: [`docs/PLAN.md`](./docs/PLAN.md).

## Contributing

See [`CONTRIBUTING.md`](./CONTRIBUTING.md). Security: [`SECURITY.md`](./SECURITY.md).

## License

[MIT](./LICENSE).
