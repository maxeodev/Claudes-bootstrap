# Squad de réalisation

**🇬🇧 English** · [🇫🇷 Français](./README.fr.md)

Opinionated Claude Code squad for **software delivery**, with least-privilege permissions.

## Install

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
```

## Agents

| Agent | Role | Guardrail |
|---|---|---|
| `architecte` | Need → delivery plan | Read-only + writes specs/docs; does not code |
| `developpeur` | Implements + tests | Does not push to remote |
| `relecteur` | Challenges the diff before commit | `Write`/`Edit` denied |
| `integrateur` | git, build, PR | `Write`/`Edit` denied; never merges without approval |

## Stack profiles

Auto-loaded based on the detected project: **Angular**, **Spring Boot**
(`skills/<stack>/SKILL.md`). Adding one = adding a folder, without touching the core.

## Commands

| Command | Purpose |
|---|---|
| `/setup` | Wizard: writes a least-privilege `.claude/settings.json` for your stack |
| `/doctor` | Diagnoses the install (agents, stack, permissions, secrets) |
| `/handoff` | Turns a need (or Jira ticket) into an actionable spec |
| `/feedback` | Prepares an opt-in GitHub issue — nothing is sent automatically |

### Optional Jira (degraded mode by default)

`/handoff` works **without Jira**: if no Jira MCP server is configured, it asks you to paste the
ticket content. To enable automatic retrieval, configure a Jira MCP server in **your** Claude Code
config (outside the plugin, so no credentials are stored here):

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "<jira-mcp-server-of-your-choice>"],
      "env": {
        "JIRA_URL": "https://your-instance.atlassian.net",
        "JIRA_EMAIL": "${JIRA_EMAIL}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    }
  }
}
```

> No credential is stored in this repository. Secrets go through your environment variables.
