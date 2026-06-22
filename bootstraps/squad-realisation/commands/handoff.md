---
description: Transforme un besoin (ou un ticket Jira) en spécification actionnable prête pour l'architecte.
argument-hint: [clé de ticket Jira | description du besoin]
allowed-tools: Read, Grep, Glob
---

# Handoff : besoin → spécification actionnable

Tu produis une **spec claire** à partir du besoin fourni : `$ARGUMENTS`

C'est le point d'entrée de l'escouade de réalisation. Une spec bâclée contamine tout l'aval —
prends le temps de lever les ambiguïtés.

## 1. Récupérer le besoin

- **Si `$ARGUMENTS` ressemble à une clé de ticket Jira** (ex. `PROJ-123`) :
  - **Si un serveur MCP Jira est configuré et disponible**, récupère le ticket (titre, description,
    critères, commentaires) via les outils Jira.
  - **Sinon (mode dégradé)** : ne tente pas d'inventer le contenu. Demande à l'utilisateur de
    **coller le contenu du ticket**, puis continue normalement. Le Handoff fonctionne sans Jira.
- **Sinon**, traite `$ARGUMENTS` comme la description directe du besoin.
- Si le besoin est vide ou trop vague, **pose les questions** qui te manquent avant de rédiger.

## 2. Comprendre le contexte (lecture seule)

Explore le code pertinent (`Read`, `Grep`, `Glob`) pour ancrer la spec dans la réalité du projet :
zones impactées, conventions, contraintes existantes. Ne modifie rien.

## 3. Rédiger la spécification

Produis une spec structurée :

- **Contexte** : pourquoi ce besoin, d'où il vient.
- **Objectif** : le résultat attendu, en une phrase vérifiable.
- **Critères d'acceptation** : liste testable (« étant donné… quand… alors… »).
- **Périmètre / Hors-périmètre** : ce qui est inclus, et surtout ce qui ne l'est pas (anti scope-creep).
- **Contraintes** : techniques, sécurité, perf, compatibilité.
- **Questions ouvertes** : ce qui reste à trancher avec le demandeur.

## 4. Passer le relais

Termine en indiquant que la spec est prête pour l'**architecte**, qui en fera un plan de réalisation.
Ne commence pas à coder : le Handoff s'arrête à la spec validée.
