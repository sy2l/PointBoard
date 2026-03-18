# Universal Scoreboard - Projet iOS SwiftUI

## Vue d'ensemble

**Universal Scoreboard** est une application iOS SwiftUI conçue pour gérer les scores de jeux de société. Elle offre une interface simple et flexible pour créer des parties avec des règles personnalisées, suivre les scores, et afficher les résultats.

Cette version inclut des améliorations significatives de l'interface utilisateur et des fonctionnalités étendues.

## Statut du Projet

- **Version :** 5.0.0 (Modes de jeu avancés + Documentation complète)
- **Statut :** ✅ Prêt pour compilation et développement
- **Plateforme :** iOS 16+
- **Langage :** Swift 5.9+
- **Architecture :** MVVM

## Comment démarrer

1.  **Dézippez** le fichier `UniversalScoreboard.zip`.
2.  Ouvrez le dossier `UniversalScoreboard` dans Xcode.
3.  **Signature :**
    - Allez dans `Signing & Capabilities`.
    - Sélectionnez votre compte Apple ID dans le menu `Team` (un compte gratuit suffit pour le simulateur).
4.  **Compilez et exécutez** (⌘R).

## Fonctionnalités Principales (v2.7)

### SetupView

- **Seuil cible personnalisable :** Un Picker `wheel` permet de choisir le seuil de 10 à 500.
- **Score initial personnalisable :** Un Picker `wheel` permet de choisir le score initial de -50 à 100.
- **Mode descendant :** Toggle pour jouer en mode descendant (ex: 100 → 0) au lieu d'ascendant (0 → 100).
- **Seuil = Élimination :** Toggle pour définir si atteindre le seuil élimine ou fait gagner le joueur.

**Combinaisons possibles :**
- **Ascendant + Élimination** : Le premier à 100 est éliminé (ex: Skyjo)
- **Ascendant + Objectif** : Le premier à 100 gagne (ex: course aux points)
- **Descendant + Élimination** : Le premier à 0 est éliminé (ex: perdre toutes ses vies)
- **Descendant + Objectif** : Le premier à 0 gagne (ex: se débarrasser de tous ses points)

### GameView

- **Contrôles +/- :** Incrémentez ou décrémentez le score de 1 en 1 avec des boutons.
- **Saisie de nombres négatifs :** Le clavier autorise les nombres négatifs.
- **Résultats en cours :** Un bouton `chart.bar.fill` affiche un classement actuel sans quitter la partie.
- **Terminer la partie :** Un bouton `stop.circle.fill` permet de mettre fin à la partie manuellement.

### Preview Automatique

- **Chargement automatique :** Le `GameViewModel` charge automatiquement la partie sauvegardée dans son `init()`.
- **Preview en temps réel :** Cliquez sur `GameView` dans Xcode pour voir votre partie en cours dans le Preview.
- **Persistance transparente :** La partie est sauvegardée automatiquement à chaque action et restaurée au lancement.

## Structure du Projet

La structure reste simple et organisée :

```
UniversalScoreboard/
├── App/                 # Point d'entrée de l'application
├── Models/              # Structures de données (Game, Player)
├── ViewModels/          # Logique de l'interface (GameViewModel)
├── Views/               # Écrans SwiftUI (SetupView, GameView)
├── Logic/               # Moteur de jeu (GameEngine)
└── Persistence/         # Sauvegarde des données (PersistenceManager)
```

## Documentation

- Chaque fichier Swift contient un en-tête détaillé expliquant son rôle, ses fonctionnalités et sa technique.
- **Architecture_Fonctionnelle.md** : Décrit les cas d'utilisation et les 4 modes de jeu.
- **Architecture_Technique_iOS.md** : Détaille l'implémentation MVVM et la gestion des modes.
