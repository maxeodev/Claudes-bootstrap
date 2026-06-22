# Getting started

[🇬🇧 English](./getting-started.md) · [🇫🇷 Français](./getting-started.fr.md)

This guide takes you from zero to a working AI-augmented delivery squad.

## 1. Install the bootstrap

In Claude Code:

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
```

This adds four agents (`architecte`, `developpeur`, `relecteur`, `integrateur`), the stack
profiles, and the commands `/setup`, `/doctor`, `/handoff`, `/feedback`.

## 2. Configure the project (`/setup`)

```text
/setup
```

The wizard detects your stack (Angular or Spring Boot), then proposes a **least-privilege**
`.claude/settings.json`: read/test/build allowed, `git push`/`commit` set to *ask*, secrets and
destructive/network commands denied. It shows you the result and writes only after your approval.
If a `settings.json` already exists, it won't overwrite it — it shows a diff to merge.

## 3. Verify (`/doctor`)

```text
/doctor
```

Reports ✅/⚠️/❌ for agents, stack detection, permissions, stack commands, and secrets — with a
corrective action for each issue.

## 4. Turn a need into a spec (`/handoff`)

```text
/handoff "Add CSV export to the billing screen"
/handoff PROJ-123
```

Produces a structured spec (context, goal, acceptance criteria, scope/out-of-scope, constraints,
open questions). With a Jira MCP server configured, it fetches the ticket; otherwise it asks you to
paste it (degraded mode). The spec is the input for the `architecte`.

## 5. Deliver with the squad

The flow mirrors a real delivery:

1. **architecte** turns the spec into a sequenced plan.
2. **developpeur** implements and runs the tests.
3. **relecteur** challenges the diff (read-only) before commit.
4. **integrateur** commits, pushes, and opens the PR (never merges without approval).

The permission separation is real: the agent that codes can't push; the one that reviews can't
modify files.

## 6. Give feedback (`/feedback`)

```text
/feedback
```

Prepares a pre-filled GitHub issue (bug, idea, missing stack). **Nothing is sent automatically** —
you review the content and publish it yourself via the link.

## Privacy

No telemetry. Nothing leaves your machine unless you explicitly publish a `/feedback` issue.
See [`SECURITY.md`](../SECURITY.md).
