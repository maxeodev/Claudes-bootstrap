---
description: Prépare un retour (bug, idée, profil de stack manquant) sous forme d'issue GitHub préremplie — opt-in, rien n'est envoyé automatiquement.
allowed-tools: Read, Glob
---

# /feedback — retour opt-in

Tu aides l'utilisateur à formuler un retour sur l'escouade. **Principe absolu : aucune télémétrie.**
Rien n'est collecté ni envoyé automatiquement. Tu **prépares** un contenu, l'utilisateur le **relit**
et décide de le publier lui-même en cliquant le lien.

## 1. Comprendre le retour

Demande (ou déduis de la conversation) de quoi il s'agit :
- 🐛 **Bug** : qu'attendait-il, qu'a-t-il obtenu ?
- 💡 **Idée / amélioration**
- 🧩 **Profil de stack manquant** (ex. React, .NET…)

## 2. Assembler le contenu (transparent)

Rédige un titre + un corps d'issue clairs. Tu peux **proposer** d'inclure du contexte utile
(version de Claude Code, stack détecté, étapes de repro). **Montre exactement ce qui sera inclus**
et n'ajoute **jamais** de contenu sensible (code propriétaire, secrets, chemins privés) sans accord.

## 3. Produire le lien (l'utilisateur publie lui-même)

Construis une URL d'issue GitHub préremplie et donne-la à l'utilisateur :

```
https://github.com/maxeodev/Claudes-bootstrap/issues/new?labels=feedback&title=<TITRE_ENCODÉ>&body=<CORPS_ENCODÉ>
```

URL-encode le titre et le corps. Précise clairement :
**« Voici ton retour prérempli. Rien n'a été envoyé. Clique le lien pour le relire et le publier toi-même. »**

C'est l'inverse de la télémétrie : déclenché par l'utilisateur, visible, et validé par lui.
