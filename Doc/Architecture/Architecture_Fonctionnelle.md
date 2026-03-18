# Architecture Fonctionnelle - PointBoard V5

**Version 1.1 (02/02/2026)** - Mise à jour pour refléter les changements de la V5 Final : système de fausses publicités, nouvelle carte de partage, améliorations UI et mise à jour du prix.

---

## 1. Modèle de Monétisation Hybride

PointBoard utilise un modèle de monétisation hybride combinant un **Achat unique Pro** et des **Publicités** pour offrir de la flexibilité aux utilisateurs.

### 1.1. Version Gratuite (avec Publicités simulées)

La version gratuite est financée par des publicités. Dans la version actuelle (V5), les publicités sont **simulées** à l'aide d'une vue `FakeAdView` pour permettre de tester les points de déclenchement et l'expérience utilisateur sans intégrer de SDK externe. L'intégration réelle du SDK Google AdMob est documentée dans `Integration_AdMob.md`.

Le tableau ci-dessous décrit les déclencheurs de publicité prévus :

| Contexte | Limite Gratuite | Action de Déblocage | Type de Publicité (simulée) |
|---|---|---|---|
| **Ajout de Joueurs** | 6 joueurs max. | Ajouter un 7ème joueur | Interstitielle (15s) |
| **En cours de partie** | N/A | Tous les 5 tours de jeu | Interstitielle (45s) |
| **Fin de partie** | N/A | Affichage des résultats | Interstitielle (15s) |

**Parcours Utilisateur (Ex: En cours de partie)**
1. L'utilisateur termine le 5ème, 10ème, 15ème... tour de jeu.
2. L'overlay `FakeAdView` s'affiche automatiquement pour une durée de 45 secondes, avec un bouton pour le fermer.
3. Une fois la publicité fermée ou terminée, le jeu continue.

### 1.2. Version Pro (Achat Unique)

La version Pro, disponible via un **achat unique de 1,99 €**, supprime **toutes les publicités** et lève **toutes les limitations fonctionnelles**.

- **Joueurs Illimités**
- **Profils Illimités**
- **Aucune publicité** (ni interstitielle, ni bannière)
- **Accès à tous les packs de jeux de base** (défini dans `StoreManager`)

---

## 2. Améliorations UI/UX de la V5

La version 5 introduit plusieurs améliorations majeures de l'interface et de l'expérience utilisateur pour rendre l'application plus simple et scalable.

### 2.1. Nouvelle Carte de Partage

Le `ShareManager` a été entièrement refondu pour générer une carte de résultats moderne et visuellement attractive, inspirée des applications de paris sportifs.

- **Format**: 1080x1920 (Story Instagram).
- **Design**:
  - Fond en dégradé (Yale Blue → Ink Black).
  - Carte centrale blanche avec podium pour le Top 3.
  - Médailles colorées (🥇, 🥈, 🥉) pour les trois premiers joueurs.
  - Branding "PointBoard" en en-tête et en pied de page.

### 2.2. Améliorations de la Navigation et de l'Interaction

- **Bouton Retour en Jeu**: Un bouton "Retour" a été ajouté dans `GameView` après le premier tour, permettant aux utilisateurs de quitter une partie pour corriger les scores ou les paramètres sans avoir à la terminer.
- **Gestion des Profils Améliorée**:
  - **SetupView**: Si aucun profil n'existe, un bouton proéminent "Sélectionner un profil" guide l'utilisateur vers l'écran de création/sélection.
  - **ProfileSelectionView**: Les cartes de profil sont maintenant **extensibles**. Un clic révèle des boutons d'action rapide : **Sélectionner**, **Stats** (ouvre `PlayerStatsView`) et **Supprimer** (avec dialogue de confirmation).

---

## 3. Splash Screen (Écran de Lancement)

Au lancement de l'application, un écran de lancement (splash screen) est affiché.

- **Contenu**: L'icône de l'application et le titre "PointBoard" au centre.
- **Animation**: Une animation de zoom est jouée sur l'icône pour une transition fluide vers la vue principale de l'application (`MainTabView`).
