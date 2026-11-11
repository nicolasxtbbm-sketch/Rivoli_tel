# Rivoli

Application personnelle de suivi des tâches et routines. L'entrée locale utilisée par le raccourci Finder est `Points.html`; `index.html` redirige vers cette même entrée pour l'accueil GitHub Pages. Les données restent dans le stockage local du navigateur et peuvent être exportées ou restaurées en JSON.

## Fonctionnalités

- Tâches et états de routine valorisés par demi-point, de 0 à 10.
- Les routines ont des états personnalisés ; chaque validation conserve le nom de l'état et ses points du jour.
- La valeur en points des tâches reste stable : le pourrissement des récompenses est suspendu.
- Une tâche peut être planifiée, abandonnée, supprimée, restaurée ou accomplie à une date antérieure.
- Le calendrier présente les tâches planifiées. Les oubliettes conservent séparément tâches abandonnées et supprimées ; seule la corbeille des tâches supprimées peut être vidée.
- Les tâches déjà accomplies et les validations antérieures sont migrées sans altérer leurs points.

## Lancer en local

Depuis ce dossier, servir les fichiers avec un serveur HTTP statique, par exemple :

```sh
python3 -m http.server 8000
```

Puis ouvrir `http://localhost:8000/Points.html`. Un serveur HTTP est nécessaire pour activer le service worker et l’installation PWA. Pour retrouver les données Chrome existantes, continuer d'ouvrir exactement le chemin local `Points.html` dans le même navigateur et le même profil.

## Publier sur GitHub Pages

1. Envoyer le contenu de ce dossier dans un dépôt GitHub.
2. Dans **Settings → Pages**, choisir **Deploy from a branch**, puis la branche et le dossier racine (`/`).
3. Ouvrir l’URL Pages affichée par GitHub. Sur iPhone, utiliser **Partager → Sur l’écran d’accueil** dans Safari.

L'application utilise des chemins relatifs pour fonctionner depuis un sous-chemin GitHub Pages. Une fois publiée, macOS peut l'ajouter au Dock depuis Safari avec **Fichier → Ajouter au Dock**. Une web app Safari conserve un stockage distinct de celui des onglets Safari ou Chrome : exporter une sauvegarde du navigateur existant puis la restaurer dans cette installation.

## Données et sauvegardes

Les données sont enregistrées dans `localStorage` sur l'appareil et dans le navigateur courant. La migration conserve une copie locale pré-migration. Le bouton de sauvegarde télécharge un fichier JSON complet ; la restauration remplace les données présentes dans le navigateur. La synchronisation cloud est facultative et utilise un compte privé Supabase ; elle n'est active qu'après configuration et connexion par lien e-mail.

## Version Lite et synchronisation Mac/iPhone

La version Lite est `Points.html?lite=1` (ou `Lite.html`), installable séparément depuis Safari. Elle affiche uniquement l'état du champ de bataille, l'ordre du jour, Thunes et le calendrier. Lite et complète utilisent la même base de données locale sur un navigateur donné.

Pour synchroniser entre appareils, le projet utilise Supabase avec connexion par lien e-mail. Créez un projet Supabase, puis dans son **SQL Editor**, exécutez tout le fichier `supabase-schema.sql`. Dans **Authentication → URL Configuration**, ajoutez aux URL de redirection autorisées l'adresse GitHub Pages du projet, avec `/**` à la fin : `https://nicolasxtbbm-sketch.github.io/Rivoli_tel/**`. Ajoutez aussi `http://localhost:8000/**` si vous voulez essayer en local.

Dans les paramètres du projet Supabase, copiez **Project URL** et la clé publique **anon/publishable** dans les deux champs de `sync-config.js`. Cette clé est publique par conception ; la politique SQL limite chaque compte à sa propre ligne et la fonction d'enregistrement refuse les mises à jour concurrentes. Le contenu du journal et le reste de la sauvegarde sont chiffrés dans le navigateur avec une phrase secrète avant l'envoi ; cette phrase n'est pas transmise à Supabase. Choisissez-en une et gardez-la : il faut saisir la même sur chaque appareil.

Publiez ensuite ces fichiers sur GitHub Pages en HTTPS. Sur le Mac qui contient déjà les bonnes données, ouvrez l'app complète dans Chrome, appuyez sur ↻, connectez-vous par le lien envoyé par e-mail, puis choisissez **Envoyer cette copie locale au cloud**. Sur l'iPhone 12, ouvrez `https://nicolasxtbbm-sketch.github.io/Rivoli_tel/Points.html?lite=1` dans Safari, connectez-vous avec le même e-mail, puis **Partager → Sur l’écran d’accueil**. Le Mac et le téléphone partageront alors cette même copie.

En cas d'édition simultanée, la synchronisation s'arrête au lieu d'écraser des changements ; rechargez la version cloud depuis le panneau ↻. Une copie locale préalable est conservée sous `mes-points:pre-cloud:v1` dans le navigateur avant tout remplacement par les données cloud.

Le graphique superpose les moyennes mobiles sur 7 et 30 jours aux colonnes journalières. L'historique est paginé par 60 cartes rectangulaires : les validations de routines d'une même journée sont regroupées et leurs points restent supprimables routine par routine. Chaque routine reçoit une couleur de la palette, modifiable dans son éditeur.

La vue du graphique couvre quatorze jours et trace les moyennes mobiles 7 et 30 jours. Le widget **Thunes** enregistre un revenu à la date choisie ; chaque entrée rapporte `arrondi inférieur(montant / 20)` points au jour correspondant. Le calendrier récapitule les revenus de la semaine et du mois, et signale par routine validée et par montant les jours concernés. L'historique est paginé par soixante entrées et regroupe les activités par date. Le bandeau de couverture utilise `campagne-de-france.jpg` avec un recadrage responsive.

Le tableau de bord utilise trois colonnes égales sur grand écran : le graphique et le suivi hebdomadaire des routines, le To-do étendu, puis Thunes, calendrier et oubliettes. Le suivi des routines se parcourt par semaine.

L'historique affiche quarante activités par page ; chaque tâche occupe une tuile étroite et les contours SVG regroupent les activités par jour. Les jours concernés ont toujours une tuile de routine, rouge barrée lorsqu'aucune routine n'a été validée. Le tableau de bord repose désormais sur le tableau `port-de-mer.jpg` en arrière-plan, sous les widgets opaques.
