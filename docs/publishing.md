# Publication & découvrabilité / Publishing & discoverability

[🇬🇧 English](#english) · [🇫🇷 Français](#français)

## Français

### Le repo est déjà une marketplace

Aucune inscription, aucun paiement, aucune validation centralisée. Le fichier
[`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json) fait de ce dépôt une
marketplace installable :

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
```

Toute mise à jour se fait en poussant sur le dépôt ; les utilisateurs font `/plugin marketplace update`.

### Gagner en visibilité (optionnel)

Pour devenir une référence, on se référence dans les annuaires **communautaires** (proposition par
simple PR de leur côté, gratuit, aucun pouvoir de blocage sur nous) :
- annuaires type `claudemarketplaces.com`, listes « awesome Claude Code » ;
- activer **GitHub Pages** sur `docs/site/` pour publier la galerie.

### Avant de publier une évolution
1. `claude plugin validate ./bootstraps/<plugin> --strict`
2. `claude plugin validate . --strict`
3. Vérifier les cas de [`evals/`](../evals/) impactés.
4. Mettre à jour [`COMPATIBILITY.md`](../COMPATIBILITY.md) si la version testée change.

## English

### The repo is already a marketplace

No registration, no payment, no central approval. The
[`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json) file makes this repository
an installable marketplace:

```text
/plugin marketplace add maxeodev/Claudes-bootstrap
/plugin install squad-realisation@claudes-bootstrap
```

Updates ship by pushing to the repo; users run `/plugin marketplace update`.

### Discoverability (optional)

To become a reference, list the catalog in **community** directories (a simple PR on their side,
free, with no blocking power over us):
- directories like `claudemarketplaces.com`, "awesome Claude Code" lists;
- enable **GitHub Pages** on `docs/site/` to publish the gallery.

### Before publishing a change
1. `claude plugin validate ./bootstraps/<plugin> --strict`
2. `claude plugin validate . --strict`
3. Check the impacted [`evals/`](../evals/) cases.
4. Update [`COMPATIBILITY.md`](../COMPATIBILITY.md) if the tested version changes.
