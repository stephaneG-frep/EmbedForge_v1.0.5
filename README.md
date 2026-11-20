# EmbedForge Academy

Apprendre le développement **Linux embarqué** de zéro jusqu'au niveau
professionnel, entièrement **hors-ligne**, en français.

![Version](https://img.shields.io/badge/version-1.0.5-38B6FF)
![Plateforme](https://img.shields.io/badge/android-ready-green)

## Ce que c'est

EmbedForge est une application Android (Flutter) qui accompagne un parcours
d'apprentissage progressif : des premiers commandes shell jusqu'à la
création d'images système avec Buildroot et Yocto, en passant par les bus
GPIO / UART / I²C / SPI et l'écriture de drivers.

Tout le contenu est embarqué dans l'APK : aucun compte, aucun serveur,
aucun abonnement.

## Contenu

| Dossier | Quantité | Détail |
|---|---|---|
| Cours | 31 modules | 124 chapitres, 5 niveaux (Fondamentaux → Pro), 368 exercices corrigés dont ~110 pratiques |
| Commandes | 79 | exemples réels, exercices, défis, erreurs courantes |
| Quiz | 4 + 31 | 4 quiz de niveau de 20 questions (10 tirées par partie) + 1 quiz de 5 questions par module : 235 questions |
| Projets | 11 | 10 mini-projets + 1 projet final « Smart Environment Monitor » |
| Glossaire | 40 termes | du Kernel au Devicetree |
| Cheat sheets | 12 | fiches pratiques |
| Roadmap | 30 étapes | du débutant au pro |
| Badges | 16 | objectifs déblocables |
| Labs interactifs | 8 | GPIO, UART, I²C, SPI, boot, mémoire, binaire, bitwise |
| Terminal simulé | 1 | + mode défi |

## Structure du projet

```
lib/
  app/            thème (Material 3) + coquille de navigation (6 onglets)
  core/           constantes (couleurs, icônes, niveaux), formateurs
  data/           DataLoader + ContentRepository (assets JSON)
  features/       écrans par domaine : home, courses, labs, terminal,
                  quizzes, projects, roadmap, tools
  models/         modèles des contenus (course, secondary)
  services/       persistance locale (SharedPreferences)
  state/          AppState global (progress, favoris, badges, réglages)
  widgets/        composants réutilisables (cartes, code, progress…)
assets/
  data/           contenu pédagogique en JSON (voir schémas ci-dessous)
  fonts/          Space Grotesk (Static) + JetBrains Mono (MonoTech)
  images/         icône générée par tool/make_icon.py
tool/
  make_icon.py    générateur d'icône (PCB + prompt)
  content_durations.py  recalcule les durées des cours à partir du contenu
test/             tests unitaires + validation du contenu
```

## Identité Android

- `applicationId` : `com.embedforge.academy`
- `namespace` : `com.embedforge.academy`
- Version : `1.0.5` (`versionCode` `6`)
- **Source unique de la version : `version:` dans `pubspec.yaml`**
  (`1.0.5+6` = `versionName+versionCode`). Gradle la lit via
  `flutter.versionName` / `flutter.versionCode`, et l'appli l'affiche
  depuis le paquet Android : ne jamais la recopier ailleurs.
  Incrémenter le nombre après `+` à chaque APK distribué.
- Libellé affiché : `EmbedForge`

## Schéma des données (assets/data)

Les contenus sont des fichiers JSON chargés au démarrage :

- `courses/manifest.json` : `[{"file": "level1_fondamentaux.json"}, …]`,
  puis un fichier par niveau contenant une liste de modules
  (`id`, `title`, `level`, `accent`, `icon`, `duration`, `summary`,
  `objectives`, `chapters[]` dont `sections[]` typées
  `text | code | tip | warning | exercise | definition | list | table | quote`).
- `commands/commands.json` : liste de commandes (`name`, `category`,
  `definition`, `syntax`, `example`, `options`, `exercise`,
  `challenge`, `commonError`).
- `quizzes/quizzes.json` : 4 quiz de niveau (`level` : beginner/intermediate/
  advanced/expert, `questions[]` : `q`, `options`, `answer`, `explanation`) ;
  chaque partie tire 10 questions parmi la banque.
- `quizzes/module_quizzes.json` : un quiz par module (`id` préfixé `mq_`,
  champ `course` = id du module), affiché sur la page du module. Ces quiz ne
  comptent pas pour le badge « Maître du quiz ».
- `projects/projects.json` : projets avec `steps[]` (`title`, `body`,
  `code`, `output`), drapeau `final` pour le projet de fin de parcours.
- `glossary/glossary.json`, `cheat_sheets/cheat_sheets.json`,
  `roadmap/roadmap.json` (chaîne d'étapes liées aux cours),
  `badges/badges.json` (16 badges, ids stables testés dans `AppState`).

## Construction

```bash
flutter pub get
flutter analyze        # 0 problème
flutter test           # 45 tests (python3 requis, voir ci-dessous)
dart run flutter_launcher_icons
flutter build apk --release
```

L'APK est généré dans `build/app/outputs/flutter-apk/app-release.apk`.

## Signature

Une build release exige une clé dédiée (elle échoue sinon, pour ne jamais
publier un APK signé avec la clé de debug).

1. Générer la clé (une seule fois, à conserver précieusement : sans elle,
   plus aucune mise à jour possible) :

   ```bash
   keytool -genkey -v -keystore ~/embedforge-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias embedforge
   ```

2. Créer `android/key.properties` (ignoré par git) :

   ```properties
   storePassword=<mot de passe du keystore>
   keyPassword=<mot de passe de la clé>
   keyAlias=embedforge
   storeFile=/home/<vous>/embedforge-release.jks
   ```

## Journal de diagnostic

Les erreurs sont consignées dans le stockage privé de l'application
(`files/embedforge_crash.log`, 256 Ko max + une archive `.1`). Aucune
permission requise, invisible des autres applications. Lecture avec une
build debug :

```bash
adb shell run-as com.embedforge.academy cat files/embedforge_crash.log
```

APK vérifié : `package com.embedforge.academy`, version `1.0.5 (6)`,
label `EmbedForge`, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`.

## Tests

- `test/widget_test.dart` : formateurs (binaire/hex), recherche
  accent-insensible, modèles, `StorageService`, `AppState`, badges.
- `test/fixes_test.dart` : non-régression (défis, SPI, quiz, chargement
  JSON, stockage de repli, taille du texte).
- `test/content_test.dart` : charge les JSON, vérifie les quantités,
  l'existence des modules référencés par les badges et la roadmap,
  la cohérence des quiz et des chapitres, au moins 2 exercices corrigés
  par chapitre, et des durées synchronisées avec le contenu (ce dernier
  test lance `python3 tool/content_durations.py --check`).

## Modifier le contenu des cours

Après toute modification d'un fichier `assets/data/courses/level*.json`,
recalculer les durées affichées dans l'appli :

```bash
python3 tool/content_durations.py
```

Barème : texte lu à 110 mots/min, 0,3 min par ligne de code, 1,5 min par
question de cours, 4 min par exercice pratique (correction sur plusieurs
lignes), 3 min minimum par chapitre.

## Licence

Projet pédagogique à but éducatif. Les systèmes, marques et exemples cités
(Raspberry Pi, ARM, Buildroot, Yocto…) appartiennent à leurs auteurs et
communautés respectives.