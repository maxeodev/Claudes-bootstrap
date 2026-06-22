# Sécurité

Claudes-bootstrap est conçu pour être **installable en entreprise**. Cela impose des règles claires.

## Aucune télémétrie

**Rien ne quitte votre machine automatiquement.** Aucun code, aucun ticket, aucune commande
n'est collecté ni envoyé. Le seul canal de retour est la commande **opt-in `/feedback`** :
c'est l'utilisateur qui la déclenche, qui voit le contenu, et qui valide ce qui part
(une issue GitHub préremplie).

## Moindre privilège

Chaque bootstrap est livré avec un **allowlist de permissions minimal**. Les commandes
sensibles (réseau, écriture hors projet, exécution) sont explicites et documentées.
Le wizard n'élargit jamais les permissions sans le dire.

## Hooks et MCP : transparence

- Chaque **hook** livré est documenté : ce qu'il déclenche, quand, et pourquoi.
- Les serveurs **MCP** (ex. Jira) sont **optionnels**. En l'absence de credentials,
  le bootstrap fonctionne en **mode dégradé** plutôt que d'échouer.

## Signaler une vulnérabilité

Ouvrez une issue GitHub avec le label `security`, ou contactez les mainteneurs en privé
avant divulgation publique.
