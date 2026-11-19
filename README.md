# Rivoli

Rivoli est une application web personnelle de suivi des tâches, routines, argent et notes. Le dépôt `Rivoli_tel` est la source de code à maintenir et publier. `Points.html?lite=1` active l’interface Lite ; `Lite.html` la redirige vers cette même page.

## Déploiement

GitHub Pages sert l’application depuis la racine de la branche `main`. Sur iPhone, ouvrir la version Lite dans Safari et utiliser **Partager → Sur l’écran d’accueil**. Sur Mac, ouvrir la même adresse GitHub Pages pour utiliser la version complète ou Lite.

Éviter d’utiliser `file:///…/Points.html` au quotidien : `file://`, GitHub Pages et un serveur local ont des stockages de navigateur séparés. Le fichier local peut rester une sauvegarde de code, mais ses données ne sont pas celles de l’application Pages.

## Données locales et cloud

Chaque navigateur garde une copie de travail dans `localStorage`. La version complète et la Lite partagent cette copie lorsqu’elles sont ouvertes sur le même domaine GitHub Pages. Un autre domaine, un autre profil de navigateur ou `file://` possède un stockage séparé.

La synchronisation Supabase stocke **un instantané complet chiffré** dans la colonne JSONB `public.app_data.payload`, avec une révision qui bloque les écrasements concurrents. Ce n’est pas une table distincte par tâche ou note, et le client n’utilise pas encore Supabase Realtime : il envoie les changements après une courte pause et vérifie les changements distants périodiquement. Une divergence demande un choix explicite ; ne pas remplacer le cloud avant d’avoir vérifié quelle copie est la plus récente.

`sync-config.js` contient l’URL du projet et sa clé publique. Les données sont chiffrées dans le navigateur avec la phrase secrète de synchronisation avant envoi. Utiliser le même compte et la même phrase sur chaque appareil.

## Sauvegardes JSON sur Mac

Dans Chrome sur Mac, ouvrir ↗, choisir un dossier personnel et autoriser l’accès. Rivoli met à jour le JSON après une minute sans modification, le réécrit toutes les 15 minutes lorsque l’app reste ouverte et conserve une archive toutes les 12 heures. À l’ouverture, il restaure le JSON si sa date montre clairement qu’il est plus récent que la copie du navigateur ; si les copies ne peuvent pas être départagées, il suspend l’écriture pour les préserver.

Chrome peut demander à nouveau l’autorisation d’accès au dossier. Cette sauvegarde directe dans un dossier n’est pas disponible sur iPhone ; la copie Supabase sert au transfert entre appareils.

## Développement local

Depuis ce dépôt, démarrer un serveur HTTP statique :

```sh
python3 -m http.server 8000
```

Puis ouvrir `http://localhost:8000/Points.html`. Ce domaine a son propre stockage et ne doit pas être confondu avec celui de GitHub Pages.
