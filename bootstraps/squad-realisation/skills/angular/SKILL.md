---
name: angular
description: À charger quand l'escouade travaille sur un projet Angular (présence de angular.json, *.component.ts). Fournit les commandes de build/test/lint, les conventions de code et les pièges connus du stack Angular.
---

# Profil de stack — Angular

Ce profil indique à l'escouade comment travailler proprement sur un projet **Angular**.
Détecte le stack via `angular.json`, `package.json` (dépendance `@angular/core`), fichiers `*.component.ts`.

## Commandes

> Vérifie le gestionnaire de paquets réel (`package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn) avant de lancer une commande.

| But | Commande (npm) |
|---|---|
| Installer (CI reproductible) | `npm ci` |
| Lancer en dev | `npm start` (alias `ng serve`) |
| Build de prod | `npm run build` (alias `ng build`) |
| Tests unitaires | `npm test` (alias `ng test`) |
| Lint | `npm run lint` |

Adapte si le projet utilise Nx (`nx test <app>`) ou un runner custom (regarde les scripts de `package.json`).

## Conventions

- **Composants standalone** par défaut (Angular moderne) ; évite les NgModules sauf existant historique.
- **Change detection `OnPush`** dès que possible ; privilégie les **signals** pour l'état local.
- **Typage strict** : pas de `any` non justifié ; active `strict` dans `tsconfig`.
- **Nommage** : `feature.component.ts`, `feature.service.ts`, `feature.spec.ts`. Un dossier par feature.
- **RxJS** : préfère les opérateurs déclaratifs (`map`, `switchMap`) à l'imbrication de `subscribe`.

## Tests

- Tests unitaires via **Jasmine/Karma** (défaut Angular) ou **Jest** selon la config du projet — vérifie.
- Teste les composants via `TestBed` ; isole la logique métier dans des services testables sans DOM.
- Un changement n'est pas fini sans test vert correspondant.

## Pièges connus

- **Fuites mémoire** : désabonne les Observables (`takeUntilDestroyed`, `async` pipe) — cause n°1 de bugs.
- **Change detection** : muter un objet sans nouvelle référence casse `OnPush`. Travaille en immuable.
- **Build prod ≠ dev** : l'AOT et le strict mode révèlent des erreurs absentes en `serve`. Build avant de livrer.
