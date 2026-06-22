---
description: Wizard d'installation — configure le projet pour l'escouade avec des permissions au moindre privilège, selon le stack détecté.
allowed-tools: Read, Grep, Glob, Write
---

# Wizard d'installation de l'escouade

Tu configures le projet courant pour l'escouade de réalisation. Procède de façon **déterministe** :
tu **remplis un template à trous**, tu n'inventes pas la structure.

## 1. Détecter le stack

Examine le projet (lecture seule) :
- `angular.json` ou `@angular/core` dans `package.json` → **Angular**
- `spring-boot-starter-*` dans `pom.xml`/`build.gradle` → **Spring Boot**
- Sinon → demande à l'utilisateur quel stack, ou laisse les placeholders génériques.

## 2. Déterminer les commandes (déterministe)

À partir du stack détecté et des fichiers réels du projet, choisis :

| Placeholder | Angular (npm) | Spring Boot (Maven) | Spring Boot (Gradle) |
|---|---|---|---|
| `{{TEST_COMMAND}}` | `npm test:*` | `./mvnw test:*` | `./gradlew test:*` |
| `{{BUILD_COMMAND}}` | `npm run build:*` | `./mvnw package:*` | `./gradlew build:*` |

Vérifie les scripts/wrapper réellement présents avant de figer les valeurs. Si tu n'es pas sûr,
demande plutôt que de deviner.

## 3. Produire `.claude/settings.json`

Charge le template `${CLAUDE_PLUGIN_ROOT}/templates/settings.json.template`, remplace les
placeholders, et **montre le résultat complet à l'utilisateur**.

Principe directeur : **moindre privilège**. Le template autorise lecture + test + build + git
en lecture, met `git push`/`git commit` en `ask`, et **refuse** la lecture des secrets et les
commandes destructives/réseau. N'élargis jamais les permissions sans le dire explicitement.

## 4. Écrire seulement après accord

- Si `.claude/settings.json` **n'existe pas** : propose de l'écrire, et écris-le après accord.
- S'il **existe déjà** : **ne l'écrase pas**. Montre le diff proposé et laisse l'utilisateur fusionner.

Termine en suggérant de lancer `/doctor` pour vérifier l'installation.
