# Artefacts et runners locaux

Un job GitHub Actions ne partage pas son systeme de fichiers avec les autres jobs. Pour transmettre le resultat du build a un job de publication, le workflow utilise donc `actions/upload-artifact` puis `actions/download-artifact`.

Dans ce TP, `act` execute les jobs dans des conteneurs locaux. Les registres sont exposes sur `localhost` grace a `.actrc` et aux relais lances par le DevContainer.

Repere important :

- `build` compile l'application et sauvegarde `dist/`.
- `publish-npm` publie ce `dist/` dans Verdaccio.
- `publish-docker` construit une image avec le meme `dist/` et la pousse dans `registry:2`.

Le principe a retenir est `build once, publish many` : on ne recompile pas separement pour chaque format d'artefact.
