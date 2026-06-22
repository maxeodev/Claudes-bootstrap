# Bien démarrer

[🇬🇧 English](./getting-started.md) · [🇫🇷 Français](./getting-started.fr.md)

Ce guide te mène de zéro à une escouade de réalisation IA-augmentée opérationnelle.

## 1. Installer le bootstrap

Dans Claude Code :

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
```

Cela ajoute quatre agents (`architecte`, `developpeur`, `relecteur`, `integrateur`), les profils
de stack, et les commandes `/setup`, `/doctor`, `/handoff`, `/feedback`.

## 2. Configurer le projet (`/setup`)

```text
/setup
```

Le wizard détecte ton stack (Angular ou Spring Boot), puis propose un `.claude/settings.json` au
**moindre privilège** : lecture/test/build autorisés, `git push`/`commit` en *ask*, secrets et
commandes destructives/réseau refusés. Il te montre le résultat et n'écrit qu'après ton accord.
Si un `settings.json` existe déjà, il ne l'écrase pas — il propose un diff à fusionner.

## 3. Vérifier (`/doctor`)

```text
/doctor
```

Rapporte ✅/⚠️/❌ pour les agents, la détection du stack, les permissions, les commandes de stack
et les secrets — avec une action corrective pour chaque problème.

## 4. Transformer un besoin en spec (`/handoff`)

```text
/handoff "Ajouter l'export CSV à l'écran de facturation"
/handoff PROJ-123
```

Produit une spec structurée (contexte, objectif, critères d'acceptation, périmètre/hors-périmètre,
contraintes, questions ouvertes). Avec un serveur MCP Jira configuré, elle récupère le ticket ;
sinon elle te demande de le coller (mode dégradé). La spec alimente l'`architecte`.

## 5. Réaliser avec l'escouade

Le flux calque une vraie livraison :

1. **architecte** transforme la spec en plan séquencé.
2. **developpeur** implémente et lance les tests.
3. **relecteur** challenge le diff (lecture seule) avant commit.
4. **integrateur** commite, pousse et ouvre la PR (ne merge jamais sans accord).

La séparation des permissions est réelle : l'agent qui code ne peut pas pousser ; celui qui relit
ne peut pas modifier les fichiers.

## 6. Donner un retour (`/feedback`)

```text
/feedback
```

Prépare une issue GitHub préremplie (bug, idée, stack manquant). **Rien n'est envoyé
automatiquement** — tu relis le contenu et le publies toi-même via le lien.

## Confidentialité

Aucune télémétrie. Rien ne quitte ta machine sauf si tu publies explicitement une issue
`/feedback`. Voir [`SECURITY.md`](../SECURITY.md).
