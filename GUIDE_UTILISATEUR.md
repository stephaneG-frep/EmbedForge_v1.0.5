# Guide utilisateur — EmbedForge Academy

Bienvenue dans **EmbedForge**, votre compagnon pour apprendre le
développement **Linux embarqué** : du premier `ls` à l'image système
Buildroot ou Yocto, entièrement **hors-ligne** sur votre téléphone.

*Guide à jour pour la version 1.0.5.*

---

## Installation

1. Copiez le fichier APK (`EmbedForge_v1.0.5.apk`) sur votre téléphone.
2. Ouvrez-le depuis « Téléchargements » (ou un gestionnaire de fichiers)
   et appuyez sur **Installer**.
   - Si Android bloque l'installation, autorisez « Installer des
     applications inconnues » pour l'application qui ouvre le fichier.
3. Lancez **EmbedForge**.

> **Mise à jour depuis une ancienne version.** Les versions jusqu'à 1.0.5
> étaient signées avec une clé de développement. Si une version future
> signée avec la clé officielle refuse de s'installer par-dessus
> (« conflit avec un paquet existant »), il faudra désinstaller l'ancienne
> d'abord, ce qui efface la progression enregistrée. **Avant de
> désinstaller, exportez votre progression** (Outils → Paramètres →
> Exporter), puis réimportez-la dans la nouvelle version (voir
> *Sauvegarder et transférer sa progression*).

---

## Premiers pas

L'application est organisée en **6 onglets** en bas de l'écran :
**Accueil · Cours · Lab · Projets · Outils · Profil**.

À l'ouverture, l'accueil affiche :

- votre **progression générale** sur le parcours ;
- une carte **Reprendre l'apprentissage** vers le dernier module consulté ;
- des raccourcis : **Lab**, **Terminal**, **Roadmap**, **Recherche** ;
- vos **statistiques** : meilleur score de quiz, projets terminés,
  badges obtenus ;
- vos badges **récemment débloqués**.

---

## Les 6 onglets

### 1. Accueil
Vue d'ensemble et raccourcis (voir ci-dessus).

### 2. Cours
Deux sous-onglets :

**Modules** : 31 modules répartis en 5 niveaux, avec un champ de recherche.

| Niveau | Thèmes |
|---|---|
| 1 · Fondamentaux | découverte du Linux embarqué, commandes essentielles, Bash, fichiers et permissions, processus, bases du C |
| 2 · Système & Outils | C avancé (pointeurs, mémoire), systemd, journalctl, SSH, apt, Git |
| 3 · Matériel & Bus | sysfs, GPIO, UART, I²C, SPI, architectures ARM, cross-compilation |
| 4 · Plateforme Linux | noyau, écriture d'un driver, U-Boot, Buildroot, Yocto, Devicetree |
| 5 · Pro & Production | temps réel, sécurité, débogage, performance, mises à jour de flottes |

Chaque module est découpé en chapitres (124 au total), eux-mêmes composés
de sections : texte, code, astuces, avertissements, définitions,
exercices, tableaux… Marquez un chapitre ou un module comme terminé pour
faire avancer votre progression.

Chaque chapitre propose au moins deux exercices : une question de cours et,
le plus souvent, un exercice pratique (script, commande, programme C…) à
faire sur votre machine ou votre carte. Cherchez d'abord, puis touchez
« Voir la correction ». La durée affichée pour chaque chapitre inclut la
lecture, le code et les exercices.

En bas de la page de chaque module, la carte **Quiz du module** propose
5 questions pour vérifier vos acquis ; votre meilleur score s'y affiche
ensuite. Le badge *Maître du quiz* s'obtient, lui, avec les quiz de niveau
(Outils → Quiz).

**Commandes** : 79 commandes Linux classées par catégorie. Chaque fiche
contient la définition, la syntaxe, un exemple, les options, un exercice,
l'erreur fréquente et un **défi** :
- si la réponse est une commande, tapez-la : elle doit être exacte
  (les majuscules, espaces en trop et un `sudo` initial sont tolérés) ;
- si la réponse est une explication, réfléchissez puis touchez
  « voir la réponse ».

### 3. Lab
Huit manipulations interactives, sans matériel :

| Lab | Ce que vous manipulez |
|---|---|
| GPIO | LED, résistance et bouton sur une broche |
| UART | échange série TX / RX, choix du débit (baudrate) |
| I²C | scan du bus et détection des périphériques |
| SPI | échange full-duplex MOSI / MISO : bit après bit, les registres du master et du slave s'échangent leurs octets en 8 coups d'horloge |
| Linux Boot | la séquence de démarrage, étape par étape |
| Memory | pile (stack), tas (heap) et adresses |
| Binary | conversions binaire / décimal / hexadécimal |
| Bitwise | opérations bit à bit : AND, OR, XOR, NOT |

### 4. Projets
- **10 mini-projets** guidés pas à pas : LED clignotante, moniteur de
  température CPU, Morse, mini serveur HTTP, écho UART, bouton GPIO,
  sauvegarde en Bash, démon systemd, journal rotatif, cross-compilation
  pour ARM ;
- le **projet final** « Smart Environment Monitor », qui réunit capteurs,
  bus et système.

Cochez un projet terminé : trois projets débloquent un badge.

### 5. Outils
| Outil | Rôle |
|---|---|
| Terminal Linux | console simulée (voir ci-dessous) |
| Défis | trouvez la commande qui répond à la question ; compteur de défis relevés et de série en cours (remise à zéro à la première erreur) |
| Quiz | 4 niveaux (Débutant → Expert), 20 questions chacun dont 10 tirées au hasard à chaque partie ; l'ordre des réponses change aussi ; correction détaillée à la fin |
| Roadmap métier | le parcours en 30 étapes, du débutant au pro ; cochez vos compétences |
| Glossaire | 40 termes, filtrables par catégorie |
| Cheat sheets | 12 fiches pratiques |
| Recherche | dans tout le contenu : modules, chapitres, commandes, quiz, projets, glossaire, fiches |
| Favoris | vos modules, chapitres, commandes et fiches épinglés (icône ☆) |
| Paramètres | thème, taille du texte, réinitialisation |

**Le terminal simulé.** Aucune commande n'est réellement exécutée sur
votre téléphone. Commandes disponibles : `help`, `pwd`, `ls`, `cd`, `cat`,
`uname`, `ps`, `top`, `ip`, `ping`, `dmesg`, `lsmod`, `lsusb`, `free`,
`df`, `whoami`, `hostname`, `date`, `echo`, `history`, `clear`, `exit`.
Le système de fichiers est en lecture seule (pas de `touch` ni `mkdir`).
Le bouton **Défi** pose une question (« Quelle commande affiche le journal
du noyau ? ») : tapez la commande pour y répondre.

### 6. Profil
Votre tableau de bord : statistiques, progression par niveau, scores des
quiz, compétences acquises et badges. Accès aux paramètres.

---

## Progression, badges, sauvegarde

- La progression (modules et chapitres terminés, projets, scores de quiz,
  roadmap, favoris, réglages) est **enregistrée sur l'appareil**. Aucun
  compte, aucune connexion : rien ne quitte le téléphone.
- Votre rang évolue avec le nombre de modules terminés : Novice →
  Débutant (5) → Intermédiaire (12) → Avancé (20) → Expert embarqué (26).
- **16 badges** à débloquer, par exemple *Hello Linux*, *Recrue du
  terminal*, *Explorateur GPIO*, *Pirate série*, *Maître du quiz*
  (80 % à un quiz de niveau), *Constructeur de projets* (3 projets) et
  *Développeur embarqué* (12 modules et 3 projets).

---

## Sauvegarder et transférer sa progression

Dans **Outils → Paramètres → Données** :

1. **Exporter** copie un code de sauvegarde (il commence par
   `EMBEDFORGE1:`). Collez-le dans une note ou envoyez-le-vous : c'est
   votre seule copie, l'application ne l'envoie nulle part.
2. Sur le nouveau téléphone ou après réinstallation : **Importer**, touchez
   l'icône *Coller*, puis **Importer**.

Le code contient les modules et chapitres terminés, les projets, les scores
de quiz, la roadmap, les labs utilisés, les favoris, le thème et la taille
du texte. **L'import remplace la progression actuelle.** Un code incomplet
ou modifié est refusé sans rien changer.

---

## Réglages

- **Thème** : clair, sombre ou celui du système.
- **Taille du texte** : de 85 % à 130 %. S'applique à toute l'application,
  en plus du réglage de taille de police d'Android.
- **Réinitialiser toute ma progression** : efface modules, chapitres,
  quiz, projets, roadmap et favoris (après confirmation, irréversible).
  Le thème et la taille du texte sont conservés.

---

## Dépannage

| Problème | Solution |
|---|---|
| L'installation est bloquée | Autorisez « Installer des applications inconnues » pour le gestionnaire de fichiers |
| « Conflit avec un paquet existant » | Exportez votre progression, désinstallez, installez, puis importez (voir l'encadré *Mise à jour*) |
| « Ce n'est pas un code EmbedForge » à l'import | Le code doit commencer par `EMBEDFORGE1:` et être copié en entier |
| Le texte est trop petit ou trop grand | Outils → Paramètres → Taille du texte |
| Je veux tout recommencer | Outils → Paramètres → Réinitialiser toute ma progression |
| Ma réponse à un défi est refusée | Elle doit correspondre exactement à la commande attendue (options et arguments compris). Dans l'écran Défis, la bonne réponse s'affiche après coup ; sur la fiche d'une commande, touchez « Voir la réponse » |
| Le terminal ne connaît pas une commande | C'est un simulateur volontairement réduit : tapez `help` pour la liste |

---

## Questions fréquentes

**Faut-il du vrai matériel ?**
Non. Les labs sont simulés pour comprendre les principes n'importe où.
Les projets préparent ensuite au matériel réel (Raspberry Pi…).

**L'application nécessite-t-elle Internet ?**
Non. Tout le contenu est embarqué dans l'application.

**L'application collecte-t-elle des données ?**
Non. Elle ne demande aucune permission sensible. En cas de plantage, un
journal technique est écrit dans l'espace privé de l'application
(inaccessible aux autres applis, supprimé à la désinstallation) ; il
n'est jamais envoyé.

**Puis-je réutiliser le contenu ?**
Le contenu pédagogique est au format JSON dans le code source du projet
(`assets/data/`).

Bonne forge !
