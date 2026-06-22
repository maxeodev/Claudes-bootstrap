---
name: spring-boot
description: À charger quand l'escouade travaille sur un projet Spring Boot (présence de pom.xml/build.gradle avec spring-boot, annotations @SpringBootApplication). Fournit les commandes de build/test, les conventions et les pièges connus du stack Spring Boot.
---

# Profil de stack — Spring Boot

Ce profil indique à l'escouade comment travailler proprement sur un projet **Spring Boot** (Java/Kotlin).
Détecte le stack via `spring-boot-starter-*` dans `pom.xml`/`build.gradle`, l'annotation `@SpringBootApplication`.

## Commandes

> Détecte le build : `pom.xml` → Maven (`./mvnw`), `build.gradle` → Gradle (`./gradlew`). Utilise le wrapper du repo.

| But | Maven | Gradle |
|---|---|---|
| Lancer en dev | `./mvnw spring-boot:run` | `./gradlew bootRun` |
| Build | `./mvnw package` | `./gradlew build` |
| Tests | `./mvnw test` | `./gradlew test` |
| Tests + vérifs | `./mvnw verify` | `./gradlew check` |

## Conventions

- **Architecture en couches** : `controller` → `service` → `repository`. Pas de logique métier dans le controller.
- **Injection par constructeur** (pas `@Autowired` sur champ) : testable et immuable.
- **DTO en frontière** : n'expose jamais les entités JPA directement dans l'API.
- **Profils** (`application-{dev,test,prod}.yml`) pour la config ; **jamais de secret en dur**.
- **Gestion d'erreurs** centralisée via `@ControllerAdvice` / `@ExceptionHandler`.

## Tests

- **JUnit 5** + **AssertJ**. Tests web ciblés via `@WebMvcTest` + `MockMvc` ; service via tests unitaires purs.
- `@SpringBootTest` pour l'intégration (coûteux — réserve-le aux cas qui le justifient).
- **Testcontainers** pour tester contre une vraie base plutôt qu'un H2 qui ment sur le comportement.

## Pièges connus

- **N+1 requêtes** : les relations `LAZY` parcourues en boucle. Utilise `JOIN FETCH` ou des projections.
- **Frontières transactionnelles** : `@Transactional` n'agit pas sur les appels internes à la même classe (proxy).
- **Injection par champ** : casse la testabilité et masque les dépendances cycliques. Bannis-la.
- **Secrets** : ne jamais committer de credentials ; passe par variables d'environnement / vault.
