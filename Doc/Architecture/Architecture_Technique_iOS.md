# Architecture Technique iOS - PointBoard V5

Ce document détaille l'architecture technique de l'application iOS PointBoard, en se concentrant sur les choix technologiques, le design pattern et les composants clés de la version 5.

---

## 1. Stack Technologique

- **UI Framework**: SwiftUI (pour une interface déclarative, moderne et réactive).
- **Version iOS Cible**: iOS 16+.
- **Architecture**: MVVM (Model-View-ViewModel) pour une séparation claire des préoccupations.
- **Gestion des Achats**: StoreKit 2 pour les achats in-app (IAP).
- **Graphiques**: Swift Charts pour les visualisations de statistiques.
- **Persistance**: `UserDefaults` pour le stockage local simple des profils, des droits et de l'historique des parties.

---

## 2. Architecture MVVM

L'application suit une architecture MVVM stricte pour garantir la maintenabilité et la scalabilité.

- **Model**: Représente les données de l'application (`Game`, `PlayerProfile`, `GameResult`, etc.). Ces structures sont pures et ne contiennent aucune logique métier.
- **View**: Couche de présentation en SwiftUI, responsable de l'affichage des données et de la capture des interactions utilisateur. Les vues sont légères et délèguent toute la logique au ViewModel.
- **ViewModel**: Le cœur de la logique de l'application. Il prépare les données pour la vue, gère les états et répond aux actions de l'utilisateur en interagissant avec les managers et les modèles.

---

## 3. Composants Clés et Managers

L'architecture repose sur un ensemble de managers spécialisés qui gèrent des domaines fonctionnels spécifiques.

### 3.1. `GameViewModel`
- **Rôle**: Orchestrateur principal de la logique de jeu.
- **Responsabilités**:
  - Gérer l'état de la partie en cours (`Game`).
  - Appliquer les scores, passer au tour suivant, annuler le dernier tour.
  - Déterminer la fin de la partie et les gagnants.
  - Gérer l'ajout/suppression de joueurs en cours de partie tout en préservant les scores.

### 3.2. `ProfileManager`
- **Rôle**: Gérer la création, la lecture, la mise à jour et la suppression (CRUD) des profils joueurs.
- **Responsabilités**:
  - Persister les profils dans `UserDefaults`.
  - Mettre à jour les statistiques des profils (parties jouées, victoires).
  - Fournir une source de vérité unique pour les profils via un singleton `shared`.

### 3.3. `StoreManager`
- **Rôle**: Gérer les achats in-app avec StoreKit 2.
- **Responsabilités**:
  - Gérer l'achat de l'abonnement "Pro".
  - Restaurer les achats précédents.
  - Vérifier les droits de l'utilisateur (`isProUser`).
  - Persister les droits dans `UserDefaults`.

### 3.4. `AdManager` & `FakeAdView`
- **Rôle**: Gérer l'affichage des publicités.
- **Phase de Test (Actuelle)**:
  - `AdManager` utilise une vue `FakeAdView` pour simuler l'affichage de publicités interstitielles et récompensées.
  - `FakeAdView` est une vue SwiftUI personnalisable (durée, bouton de fermeture) qui s'affiche en overlay sur toute l'application.
  - Cela permet de tester les déclencheurs de publicité et l'expérience utilisateur sans intégrer le SDK AdMob.
- **Phase de Production (Future)**:
  - L'intégration suivra le document `Integration_AdMob.md` pour remplacer `FakeAdView` par de vraies publicités Google AdMob.

### 3.5. `ShareManager`
- **Rôle**: Générer et partager une image récapitulative des résultats de la partie.
- **Responsabilités**:
  - Utiliser `UIGraphicsImageRenderer` pour dessiner une carte de résultats moderne et stylisée (format Story Instagram).
  - La carte inclut un dégradé, un podium avec médailles, le classement des joueurs et le branding de l'application.
  - Présenter un `UIActivityViewController` pour le partage natif.

### 3.6. `DesignSystem.swift`
- **Rôle**: Centraliser tous les éléments de design de l'application.
- **Responsabilités**:
  - Définir la palette de couleurs (`Ink Black`, `Yale Blue`, etc.) avec support Light/Dark mode.
  - Définir les styles de typographie, les espacements, les rayons de coin et les ombres.
  - Fournir des `ViewModifier` (`modernCardStyle`) pour appliquer un style cohérent à travers l'application.

---

## 4. Flux de Données et Navigation

- **Navigation**: L'application utilise `NavigationStack` pour la navigation hiérarchique et des `.sheet()` pour les vues modales (sélection de profil, règles, etc.).
- **Partage de Données**: Les managers et ViewModels sont injectés dans la hiérarchie des vues via `@StateObject` et `@EnvironmentObject` pour assurer une source de vérité unique et des mises à jour réactives.
