# tp-cd-github-flow

API de gestion de taches - support du TP cours-04 sur le Continuous Delivery avec GitHub Flow.

## Objectifs pedagogiques

Ce depot part d'une CI deja verte. Vous ajoutez la partie livraison :

- appliquer un GitHub Flow court et local ;
- versionner avec Conventional Commits et `commit-and-tag-version` ;
- publier un package npm dans Verdaccio ;
- publier une image Docker dans un registre local `registry:2` ;
- executer les workflows GitHub Actions localement avec `act`.

## Stack technique

| Outil | Role |
|---|---|
| Node 24 + NestJS 11 | API backend |
| better-sqlite3 | Base SQLite locale |
| Jest + Supertest | Tests unitaires et E2E |
| Prettier + ESLint | Qualite de code |
| Trivy | Scan de vulnerabilites |
| commit-and-tag-version | Versioning SemVer depuis les commits |
| Verdaccio | Registre npm local |
| registry:2 | Registre Docker local |
| act | Execution locale des workflows GitHub Actions |

## Demarrage recommande

Prerequis : Docker Desktop, VS Code et l'extension Dev Containers.

1. Ouvrir le dossier dans VS Code.
2. Accepter `Reopen in Container`.
3. Attendre la fin du `postCreateCommand`.

Le DevContainer installe les dependances, initialise SQLite, demarre Verdaccio et `registry:2`, installe `act` et precharge l'image runner.

## Services locaux

| Service | URL |
|---|---|
| API | http://localhost:3000 |
| Swagger | http://localhost:3000/api |
| Verdaccio | http://localhost:4873 |
| Docker Registry | http://localhost:5000/v2/ |

Commandes de verification :

```bash
curl http://localhost:4873/-/ping
curl http://localhost:5000/v2/
```

Si les relais reseau tombent apres une veille :

```bash
bash bin/check-relays.sh
```

## Lancer l'application

```bash
npm run start:dev
```

Routes principales :

| Methode | Route | Description |
|---|---|---|
| GET | `/health` | Healthcheck |
| GET | `/tasks` | Lister les taches |
| GET | `/tasks/:id` | Recuperer une tache |
| POST | `/tasks` | Creer une tache |
| PATCH | `/tasks/:id` | Mettre a jour |
| DELETE | `/tasks/:id` | Supprimer |

## Tests et CI locale

```bash
npm test
npm run test:e2e
act -j security
```

Pipeline initiale :

```text
install -> format-lint -> tests -> tests-e2e -> build -> security
```

Mission du TP :

```text
security -> release -> publish-npm
                    -> publish-docker
```

## Exercices

Les consignes detaillees sont dans [EXERCICE.md](./EXERCICE.md).

Commandes de fin de TP :

```bash
act -j release
act -j publish-npm
npm view tp-cd-github-flow --registry http://localhost:4873
act -j publish-docker
curl http://localhost:5000/v2/tp-cd-github-flow/tags/list
```

## Documentation utile

- [docs/ci-pipeline.md](docs/ci-pipeline.md) : rappel de la CI.
- [docs/fonctionnement-cache.md](docs/fonctionnement-cache.md) : cache `node_modules`.
- [docs/artefacts-et-runners.md](docs/artefacts-et-runners.md) : passage du build aux publications.
