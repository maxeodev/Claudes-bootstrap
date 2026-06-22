---
description: Vérifie que l'escouade est correctement installée et configurée dans le projet.
allowed-tools: Read, Grep, Glob, Bash
---

# /doctor — diagnostic de l'installation

Vérifie l'installation de l'escouade et rapporte un bilan clair. **Ne modifie rien** : tu
diagnostiques et tu recommandes.

Contrôle chaque point et marque ✅ / ⚠️ / ❌ avec une explication courte et l'action corrective :

1. **Agents** : les 4 agents sont-ils présents et chargés (`architecte`, `developpeur`,
   `relecteur`, `integrateur`) ? (`/agents` les liste.)
2. **Profil de stack** : le stack du projet est-il détecté et un profil correspondant existe-t-il
   (Angular / Spring Boot) ? Sinon, signale qu'un profil manque (contribution possible).
3. **Permissions** : `.claude/settings.json` existe-t-il ? Les permissions suivent-elles le
   moindre privilège (lecture/test/build autorisés, secrets et commandes destructives refusés) ?
   Si absent, recommande `/setup`.
4. **Commandes de stack** : les commandes de test/build référencées dans `settings.json`
   correspondent-elles à des scripts/wrappers réellement présents dans le projet ?
5. **Secrets** : aucun secret en clair committé (rapide vérif `.env`, clés) ? Confirme que la
   config refuse leur lecture.

## Sortie

Un bilan synthétique : nombre de ✅/⚠️/❌, puis la liste détaillée avec, pour chaque problème,
**l'action corrective précise** (souvent `/setup`). Si tout est vert, dis-le clairement.
