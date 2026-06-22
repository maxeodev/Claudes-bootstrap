# Contribuer

Merci de contribuer à Claudes-bootstrap ! Ce projet vise à devenir une **référence** :
la qualité et la soutenabilité priment.

## Conventions

- **Nommage court** des plugins (`squad-realisation`, pas `claudes-bootstrap-squad-de-realisation-v1`).
- **Stacks = fragments isolés** : un stack vit dans `stacks/<nom>/` et ne doit **pas** modifier le cœur.
- **Templates déterministes** : le wizard remplit des placeholders, il n'improvise pas la structure.

## Ajouter un stack

1. Créez `stacks/<votre-stack>/`.
2. Décrivez le profil (build, test, conventions) sous forme de fragment.
3. Ajoutez un cas à la suite d'éval.
4. Ouvrez une PR : la CI lance `claude plugin validate` + le **gate d'éval** (pas de régression).

## Ajouter un bootstrap

Même logique, sous `bootstraps/<nom>/`. Respectez le **moindre privilège** pour les permissions
et documentez tout hook livré (voir `SECURITY.md`).

## Process

- Toute contribution passe par une **PR** (y compris celles de l'agent curateur).
- Aucune PR n'est mergée sans passer la CI et le gate d'éval.
- Une PR = un périmètre clair. Évitez les changements fourre-tout (anti scope-creep).
