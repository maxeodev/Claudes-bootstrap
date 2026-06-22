# Squad de réalisation

Escouade Claude Code opinionnée pour la **réalisation logicielle**, avec permissions au moindre privilège.

## Installation

```
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
```

## Les agents

| Agent | Rôle | Garde-fou |
|---|---|---|
| `architecte` | Besoin → plan de réalisation | Lecture seule + écrit specs/docs ; ne code pas |
| `developpeur` | Implémente + teste | Ne pousse pas sur le distant |
| `relecteur` | Challenge le diff avant commit | `Write`/`Edit` interdits |
| `integrateur` | git, build, PR | `Write`/`Edit` interdits ; ne merge jamais sans accord |

## Profils de stack

Chargés automatiquement selon le projet détecté : **Angular**, **Spring Boot**
(`skills/<stack>/SKILL.md`). En ajouter un = ajouter un dossier, sans toucher au cœur.

## Commande `/handoff`

Transforme un besoin (ou un ticket Jira) en spécification actionnable :

```
/handoff PROJ-123
/handoff "Ajouter l'export CSV à l'écran de facturation"
```

### Jira optionnel (mode dégradé par défaut)

Le `/handoff` fonctionne **sans Jira** : si aucun serveur MCP Jira n'est configuré, il te demande
de coller le contenu du ticket. Pour activer la récupération automatique, configure un serveur MCP
Jira dans **ta** config Claude Code (hors du plugin, pour ne pas y stocker de credentials), par ex. :

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "<serveur-mcp-jira-de-ton-choix>"],
      "env": {
        "JIRA_URL": "https://ton-instance.atlassian.net",
        "JIRA_EMAIL": "${JIRA_EMAIL}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    }
  }
}
```

> Aucun credential n'est stocké dans ce dépôt. Les secrets passent par tes variables d'environnement.
