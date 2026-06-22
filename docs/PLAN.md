# Claudes-bootstrap — Plan

> Catalogue open source de **bootstraps Claude Code** pour équipes de développement.
> Objectif : devenir **la référence** pour démarrer une escouade IA-augmentée, en quelques minutes, sur un stack donné.

---

## 1. Décisions verrouillées

| Sujet | Décision | Raison |
|---|---|---|
| **Licence** | **MIT** | Permissive, standard du tooling/plugins, zéro friction d'adoption en entreprise. |
| **Télémétrie** | **Aucune** (rien ne quitte la machine) | Le code et les tickets sont confidentiels ; condition d'adoption par les DSI. |
| **Feedback** | **Opt-in via GitHub** (`/feedback`) | L'utilisateur déclenche, voit, et valide ce qui part. L'inverse de la télémétrie cachée. |
| **Stratégie de livraison** | **Tranche verticale v1** | Prouver une chaîne complète bout-en-bout avant de scaler (anti scope-creep). |
| **Communauté** | Pilier de 1er rang (Phase 7) | La référence se construit avec ses contributeurs. |

---

## 2. Vision

Un développeur arrive sur un nouveau projet. En une commande, il installe un **bootstrap** :
une **escouade d'agents Claude Code** préconfigurée pour son **type de mission** (réalisation, TMA, DevOps, Data)
et son **stack technique** (Angular, Spring Boot, …), avec un **flux de Handoff** qui transforme un besoin
en spec actionnable, et des garde-fous (permissions minimales, hooks documentés).

Tout est **auditable, open source (MIT), sans télémétrie**.

---

## 2bis. État de l'art & différenciation

Le terrain est déjà peuplé (veille juin 2026). Ce qui domine : des **collections massives d'agents
génériques** — [wshobson/agents](https://github.com/wshobson/agents) (192 agents),
[VoltAgent](https://github.com/VoltAgent/awesome-claude-code-subagents) (100+),
[jamsajones/claude-squad](https://github.com/jamsajones/claude-squad) (29+),
[mylee04](https://github.com/mylee04/claude-code-subagents) (équipe générée selon le stack) — recensées
par des annuaires ([claudemarketplaces.com](https://claudemarketplaces.com/), aitmpl, awesomeclaude).

**On n'invente pas la catégorie.** Notre survie vient de l'exécution sur 4 axes que le marché néglige :

| Le marché actuel | Notre angle (assumé) |
|---|---|
| 100+ agents génériques empilés | **Escouades resserrées par mission** (4 agents pensés) |
| « Installe et débrouille-toi » | **Wizard + Handoff** (besoin → spec → réalisation) |
| Qualité non prouvée | **Gate d'éval** en CI |
| Sécurité absente | **Zéro télémétrie + moindre privilège** (posture DSI) |

Positionnement : **opinionné + entreprise + qualité prouvée**, pas « encore une collection ».

---

## 3. Architecture cible

```
claudes-bootstrap/
├── LICENSE                      # MIT
├── README.md                    # quickstart + value prop
├── SECURITY.md                  # ce que font hooks/MCP, moindre privilège
├── CONTRIBUTING.md              # comment ajouter un stack / un bootstrap
├── docs/
│   ├── PLAN.md                  # ce document
│   └── site/                    # galerie (GitHub Pages)
├── bootstraps/
│   └── squad-realisation/       # v1 : le bootstrap cœur
│       ├── agents/              # escouade (archi, dev, revue, …)
│       ├── commands/            # /handoff, /feedback, /doctor
│       ├── hooks/               # documentés, opt-in
│       └── plugin.json
├── stacks/                      # fragments isolés (1 fichier = 1 stack)
│   ├── angular/
│   └── spring-boot/
├── wizard/                      # templates déterministes à trous
└── .github/workflows/           # CI : claude plugin validate + gate d'éval
```

**Principes de soutenabilité :**
- **Stacks = fragments isolés** → ajouter un stack ne touche pas au cœur.
- **Templates déterministes à trous** → le wizard *remplit* des placeholders, il n'*invente* pas.
- **CI `claude plugin validate`** sur chaque PR + **gate d'éval** (pas de régression).
- **Note de compatibilité** : version de Claude Code testée.

---

## 4. Périmètre v1 (tranche verticale)

> **1 bootstrap (Squad de réalisation) + 2 stacks (Angular + Spring Boot) + Handoff + wizard + `/feedback` + 1 carte de galerie.**

Prouve la boucle complète : `install → wizard → Handoff → réalisation → feedback → galerie`.
Une fois solide, ajouter TMA/DevOps/Data et d'autres stacks devient **mécanique** (copier un fragment).

---

## 5. Phases

### Phase 0 — Fondations  ← *en cours*
- `LICENSE` (MIT), `README.md`, `SECURITY.md`, `CONTRIBUTING.md`.
- Structure de dossiers + conventions de **nommage court** des plugins.
- Squelette CI `.github/workflows/` (`claude plugin validate`).

### Phase 1 — Bootstrap « Squad de réalisation »
- `plugin.json` + escouade d'agents (archi, dev, revue, intégration).
- Permissions **moindre privilège** par défaut.

### Phase 2 — Profils de stack (fragments)
- `stacks/angular/` + `stacks/spring-boot/`.

### Phase 3 — Le Handoff
- Commande `/handoff` : besoin → spec actionnable.
- **MCP Jira optionnel** + **mode dégradé** (ticket collé à la main si pas de creds).

### Phase 4 — Wizard d'installation
- Templates déterministes à trous.
- Commande **`/doctor`** : vérifie que le setup est correct.

### Phase 5 — Feedback opt-in
- Commande **`/feedback`** : ouvre une issue GitHub préremplie, l'utilisateur valide ce qui part.

### Phase 6 — Galerie
- Site GitHub Pages + **1 carte** + **badges de score d'éval**.

### Phase 7 — Communauté & évolution  *(continu)*
- **Agent curateur** : propose des **PR uniquement** (humain dans la boucle), **gate d'éval avant merge**.
- Soumission à la **marketplace communautaire** d'Anthropic.
- Note de compatibilité maintenue.

---

## 6. Risques & mitigations

| Risque | Mitigation |
|---|---|
| Devenir une référence (visibilité) | Marketplace + GitHub Pages + README quickstart + badges d'éval. |
| Soutenabilité (N stacks à maintenir) | Démarrer mince (v1) ; stacks = fragments isolés ; CI validate ; note de compatibilité. |
| Confiance entreprise | 100 % auditable ; aucune télémétrie ; `SECURITY.md` ; moindre privilège. |
| Wizard non déterministe | Templates à trous + `/doctor`. |
| Agent curateur qui dérape | PR seulement, jamais merge ; gate d'éval. |
| MCP Jira sans creds | Mode dégradé. |
| Scope creep | Tranche verticale v1 d'abord. |
