# Évaluations / Evaluations

🇫🇷 Le **gate d'éval** est ce qui distingue ce catalogue des collections « non prouvées » : aucun
bootstrap n'est promu sans preuve qu'il se comporte correctement.
🇬🇧 The **eval gate** is what sets this catalog apart from "unproven" collections: no bootstrap is
promoted without evidence that it behaves correctly.

## Deux niveaux / Two levels

1. **Structurel / Structural** *(actif en CI / active in CI)* — `claude plugin validate --strict`
   sur chaque plugin et sur la marketplace. Attrape les manifestes invalides, les frontmatters
   cassés, les champs mal typés.
2. **Comportemental / Behavioral** *(cas déclaratifs ci-dessous / declarative cases below)* — des
   scénarios qui décrivent une entrée et le comportement attendu de l'escouade. Leur exécution
   automatisée nécessite une instance Claude Code en CI (étape branchée au fil de l'eau).

## Cas / Cases

Les cas vivent dans [`cases/`](./cases/). Chaque cas décrit : un contexte, une action, et des
**assertions** vérifiables. Une régression = un cas qui passait et qui échoue → la PR est bloquée.

## Lancer / Run

```text
# Structurel (local)
claude plugin validate ./bootstraps/squad-realisation --strict
claude plugin validate . --strict

# Comportemental : voir cases/ ; l'exécution automatisée arrive avec le runner CI.
```
