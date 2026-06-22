# Claudes-bootstrap

[🇬🇧 English](./README.md) · **🇫🇷 Français**

> Catalogue open source de **bootstraps Claude Code** pour équipes de développement.
> Démarrez une escouade IA-augmentée en quelques minutes, adaptée à votre mission et à votre stack.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

## Pourquoi

Configurer Claude Code pour une équipe — agents, commandes, hooks, permissions, intégrations —
prend du temps et se refait à chaque projet. **Claudes-bootstrap** fournit des configurations
prêtes à l'emploi, **auditables** et **sans télémétrie**, qu'on installe et qu'on adapte.

## Principes

- **Aucune télémétrie.** Rien ne quitte votre machine. Le feedback est **opt-in** (`/feedback`).
- **Moindre privilège.** Les permissions par défaut sont minimales et documentées.
- **Open source (MIT).** Tout est auditable.
- **Soutenable.** Les stacks sont des fragments isolés : en ajouter un ne touche pas au cœur.

## Ce qui nous différencie

Le terrain est saturé de collections massives d'agents génériques. On prend l'inverse :

| Le marché actuel | Notre angle |
|---|---|
| 100+ agents génériques | **Escouades resserrées par mission** (4 agents pensés) |
| « Installe et débrouille-toi » | **Wizard + Handoff** (besoin → spec → réalisation) |
| Qualité non prouvée | **Gate d'éval** en CI *(à venir)* |
| Sécurité absente | **Zéro télémétrie + moindre privilège** (posture DSI) |

## Démarrage rapide

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
/setup      # config au moindre privilège, adaptée à ton stack
/doctor     # vérifie l'installation
/handoff "Ton besoin ou une clé de ticket Jira"
```

Guide complet : [`docs/getting-started.fr.md`](./docs/getting-started.fr.md).

## Bootstraps disponibles

| Bootstrap | Description |
|---|---|
| [`squad-realisation`](./bootstraps/squad-realisation/README.fr.md) | Escouade de réalisation : architecte, développeur, relecteur, intégrateur. Stacks : Angular, Spring Boot. |

## État

🚧 **v1 en construction** — tranche verticale : **Squad de réalisation** + **Angular** & **Spring Boot** +
**Handoff** + **wizard** + **`/feedback`**. Voir le plan : [`docs/PLAN.md`](./docs/PLAN.md).

## Contribuer

Voir [`CONTRIBUTING.md`](./CONTRIBUTING.md). Sécurité : [`SECURITY.md`](./SECURITY.md).

## Licence

[MIT](./LICENSE).
