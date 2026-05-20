# 📋 Fonctionnement et Logique Métier — PointBoard

**Date de création** : 12/05/2026  
**Version analysée** : V5.4.3  
**Statut** : Documentation actuelle (AVANT migration gratuite)

---

## 🎯 Vue d'ensemble

**PointBoard** est une application de comptage de points universelle pour jeux de société, cartes, et activités sportives.

### Architecture globale

- **Pattern** : MVVM (Model-View-ViewModel)
- **Framework UI** : SwiftUI (iOS 16+)
- **Persistance** : UserDefaults + JSONEncoder/Decoder
- **Achats** : StoreKit 2 (IAP)
- **Publicités** : Google Mobile Ads SDK

---

## 📦 Structure des Composants Principaux

### 1. **UniversalScoreboardApp.swift** (Point d'entrée)

**Rôle** :
- Point d'entrée de l'app
- Initialise les managers (AdManager, StoreManager, NotificationManager)
- Gère le splash screen et le routing initial

**Flux d'initialisation** :
```
1. MigrationManager.migrateV1toV2() — Migration anciennes données
2. NotificationManager.resetBadge() — Reset badge notifications
3. Demande permission notifications (2e lancement)
4. AdManager.preloadAds() — Précharge les pubs
5. Route vers SplashScreenView
```

**Injection de dépendances** :
- `GameViewModel` : État du jeu actuel
- `AdManager` : Gestion des publicités

---

### 2. **GameViewModel** (Logique métier principale)

**Responsabilités** :
- Création de parties (avec settings, presets, noms joueurs)
- Validation des tours (deltas de scores)
- Undo/Redo (historique local en mémoire)
- Fin de partie + archivage
- Mise à jour des stats profils
- Sauvegarde/chargement via PersistenceManager

**Points clés** :

#### Validation de tour (validateTurn)
```swift
1. Snapshot du jeu actuel → gameHistory (undo)
2. Appliquer les deltas via GameEngine
3. Incrémenter turnCount
4. ⚠️ Tous les 5 tours → afficher pub interstitielle (si pas Bundle)
5. Sauvegarder le jeu via PersistenceManager
```

#### Undo
```swift
1. Restore dernier snapshot depuis gameHistory
2. Décrementer turnCount
3. Sauvegarder l'état restauré
```

#### Fin de partie (endGame)
```swift
1. Marquer game.isOver = true
2. Archiver dans HistoryManager
3. Mettre à jour les stats ProfileManager
4. Sauvegarder
```

---

### 3. **AdManager** (Gestion des publicités)

**Types de publicités** :

| Type | Déclencheur | Durée | Récompense |
|------|-------------|-------|------------|
| **Interstitielle** | Tous les 5 tours | 15s | Aucune |
| **Récompensée** | Déblocage actions (ex: +6 joueurs) | 15s | Déverrouillage temporaire |
| **Bannière native** | Écrans Historique/Stats | Permanente | N/A |

**Logique de gating** :
```swift
func canShowAd() -> Bool {
    return !StoreManager.shared.isPremiumUser
}
```

**Flow publicité récompensée** :
```
1. Vérifie canShowAd()
2. Si Premium/Bundle → exécute action directement (pas de pub)
3. Sinon → showRewardedAd()
4. Si pub AdMob disponible → présente GADRewardedAd
5. Sinon → fallback FakeAdView (15s)
6. Après visionnage → exécute callback (déblocage)
7. Recharge la pub suivante
```

**Flow publicité interstitielle** :
```
1. Vérifie canShowAd()
2. Si Premium/Bundle → skip
3. Sinon → présente InterstitialAd (ou FakeAdView)
4. Recharge la pub suivante
```

**IDs AdMob** :
- Rewarded : `ca-app-pub-1225865230141398/7076087654`
- Interstitial : `ca-app-pub-1225865230141398/2861510474`
- Banner : `ca-app-pub-1225865230141398/VOTRE_BANNER_ID` (non configuré)

---

### 4. **StoreManager** (Achats IAP)

**Produits disponibles** :

| Produit | ID | Prix | Avantages |
|---------|-----|------|-----------|
| **Premium No Ads** | `com.universalscoreboard.premium.noads` | 0,99€ | Pas de pub + 12 joueurs |
| **Bundle All Packs** | `com.universalscoreboard.bundle.allpacks` | 3,99€ | Tous les packs + Premium |
| **Packs individuels** | `com.universalscoreboard.pack.{nom}` | 0,99€ | Débloque un pack |

**Règles de déblocage** :

#### Packs de jeux
```swift
func isPackUnlocked(_ pack: GamePack) -> Bool {
    if pack == .coreFree { return true }
    if hasAllPacksBundle { return true }
    if unlockedPacks.contains(pack) { return true }
    return false
}
```

#### Publicités
```swift
var shouldShowAds: Bool {
    return !isPremiumUser  // Premium OU Bundle
}
```

#### Limite de joueurs
```swift
var maxPlayersAllowed: Int {
    return isPremiumUser ? 12 : 6
}
```

**État observable** :
- `hasAllPacksBundle: Bool` — Bundle All Packs acheté
- `hasPremiumNoAds: Bool` — Premium No Ads acheté
- `unlockedPacks: Set<GamePack>` — Packs individuels achetés
- `isPremiumUser: Bool` — Computed (Premium OU Bundle)

**Chargement des produits** :
```swift
1. loadProducts() au démarrage (Option C - Fix iPad)
2. Product.products(for: allProductIDs) via StoreKit 2
3. Affiche loading/error UI si problème réseau
4. availableProducts[] stocke les Product objets
```

**Flow achat** :
```swift
1. Vérifie isLoadingProducts
2. Vérifie availableProducts contient le produit
3. product.purchase() via StoreKit 2
4. Switch result:
   - .success → checkVerified() + finish() + persist
   - .userCancelled → nil
   - .pending → message d'attente
5. Met à jour @Published state
6. persistEntitlements() → UserDefaults
```

**Restauration des achats** :
```swift
1. Transaction.currentEntitlements (StoreKit 2)
2. Parcourt toutes les transactions actives
3. Met à jour les états (Bundle, Premium, packs)
4. Persiste
```

---

### 5. **PersistenceManager** (Sauvegarde locale)

**Données sauvegardées** :
- `currentGame` — Partie en cours (Game object)
- `gameHistory` — Snapshots pour undo (local-first, best-effort disk)

**Méthodes principales** :
```swift
func saveGame(_ game: Game) throws
func loadGame() -> Game?
func saveGameSnapshot(_ game: Game) throws  // Pour undo
func loadGameHistory() throws -> [Game]
func deleteGame()
```

**Format** : JSON avec ISO8601 dates via JSONEncoder/Decoder

**Important** : L'undo ne dépend PAS de la persistance disque (historique en mémoire d'abord).

---

### 6. **NotificationManager** (Notifications locales)

**Rôle** :
- Demander permission notifications (au 2e lancement)
- Reset badge app icon

**Système supprimé** : Ancien système de notifications streak/mystery (refusé par Apple).

**Flow permission** :
```
1. App launch → launchCount++
2. Si launchCount == 2 ET pas déjà demandé → requestPermission()
3. Sauvegarde flag "notif.permissionAsked"
```

---

### 7. **MigrationManager** (Migrations de données)

**Migration V1 → V2** :
- Détecte `store.isProUser` (ancien système)
- Convertit en `store.hasAllPacksBundle` (nouveau système)
- Nettoie anciennes clés
- Flag `migration.v2.completed` pour ne pas répéter

**Appelé** : Au tout début du launch (avant tous les autres managers).

---

## 🎮 Flux Utilisateur Principaux

### 1️⃣ Lancement de l'app

```
UniversalScoreboardApp.init()
    ↓
MigrationManager.migrateV1toV2()
    ↓
AppDelegate.application(didFinishLaunching)
    ↓
MobileAds.shared.start()
    ↓
SplashScreenView (2 secondes)
    ↓
Si game != nil → GameView
Sinon → MainTabView
    ↓
NotificationManager.resetBadge()
requestNotificationPermissionIfNeeded() (si 2e lancement)
AdManager.preloadAds()
```

### 2️⃣ Création d'une partie

```
SetupView : Sélection preset + joueurs
    ↓
Vérification isPresetUnlocked()
    ↓
Si locked → BundlePaywallView / PackPaywallView
    ↓
Si unlocked → GameViewModel.createGame()
    ↓
PersistenceManager.saveGame()
    ↓
Navigation → GameView
```

### 3️⃣ Validation d'un tour

```
GameView : Saisie scores
    ↓
GameViewModel.validateTurn(deltas)
    ↓
Snapshot → gameHistory (undo local)
    ↓
GameEngine.validateTurn()
    ↓
turnCount++
    ↓
Si turnCount % 5 == 0 ET !hasBundle
    ↓
AdManager.showInterstitialAd()
    ↓
PersistenceManager.saveGame()
```

### 4️⃣ Ajout de joueurs en cours de partie

```
GameView → AddPlayerSheet
    ↓
Si joueurs <= 6 → Ajout direct
    ↓
Si joueurs > 6 ET !isPremiumUser
    ↓
AdManager.showStaticGateAd()
    ↓
Après pub → ajout autorisé
```

### 5️⃣ Fin de partie

```
GameView → Bouton "Terminer"
    ↓
GameViewModel.endGame()
    ↓
game.isOver = true
    ↓
HistoryManager.archiveGame()
    ↓
ProfileManager.updateStats() (si profils liés)
    ↓
PersistenceManager.saveGame()
    ↓
Navigation → EndGameView (podium)
```

### 6️⃣ Achat IAP

```
SettingsView / PaywallView → Bouton achat
    ↓
StoreManager.purchasePremium() / purchaseBundle()
    ↓
Vérification isLoadingProducts
    ↓
product.purchase() (StoreKit 2)
    ↓
Si success → transaction.finish()
    ↓
StoreManager.persistEntitlements()
    ↓
Dismiss paywall (onChange)
```

---

## 🔒 Système de Monétisation (ACTUEL)

### Modèle économique

**Freemium avec IAP + Publicités** :
- Version gratuite : 5 presets + 6 joueurs max + pubs
- Premium No Ads (0,99€) : Pas de pub + 12 joueurs
- Packs individuels (0,99€/pack) : Débloque un pack de jeux
- Bundle All Packs (3,99€) : Tous les packs + Premium

### Packs de jeux

| Pack | Prix | Presets inclus | ID Product |
|------|------|----------------|------------|
| **Core Free** | Gratuit | 5 presets | N/A |
| **Classic Cards** | 0,99€ | 7 presets | `pack.classicCards` |
| **Fun Cards & Dice** | 0,99€ | 7 presets | `pack.funCardsDice` |
| **Board Family** | 0,99€ | 7 presets | `pack.boardFamily` |
| **Outdoor Sport** | 0,99€ | 8 presets | `pack.outdoorSport` |
| **Party Night** | 0,99€ | 8 presets | `pack.partyNight` |
| **Duels Strategy** | 0,99€ | 8 presets | `pack.duelsStrategy` |
| **Kids Family 2** | 0,99€ | 8 presets | `pack.kidsFamily2` |

### Points de pub (gating)

| Action | Condition | Type pub |
|--------|-----------|----------|
| **Tour +5** | Tous les 5 tours | Interstitielle |
| **Ajout joueur 7-12** | Si pas Premium | Récompensée (gate) |
| **Écran Historique** | Si pas Bundle | Bannière native |
| **Écran Stats** | Si pas Bundle | Bannière native |

### Vérifications de déblocage

```swift
// Avant d'afficher une pub
if StoreManager.shared.isPremiumUser { 
    // Pas de pub (Premium OU Bundle)
}

// Avant de montrer un preset
if StoreManager.shared.isPresetUnlocked(preset) { 
    // Accès direct
} else {
    // Paywall
}

// Limite de joueurs
let maxPlayers = StoreManager.shared.maxPlayersAllowed  // 6 ou 12
```

---

## 📊 Données Utilisateur

### UserDefaults (Persistance locale)

**Store** :
- `store.hasAllPacksBundle: Bool`
- `store.hasPremiumNoAds: Bool`
- `store.unlockedPacks: [String]`

**App State** :
- `app.launchCount: Int`
- `notif.permissionAsked: Bool`

**Migration** :
- `migration.v2.completed: Bool`

**Anciens (obsolètes)** :
- `store.isProUser: Bool` (converti en hasAllPacksBundle)

### Fichiers JSON encodés

**PersistenceManager** :
- `currentGame: Data` — Partie en cours
- `gameHistory: Data` — Snapshots pour undo

**HistoryManager** :
- Archive des parties terminées (GameResult objects)

**ProfileManager** :
- Profils joueurs avec stats (victoires, parties jouées)

---

## 🧩 Dépendances Externes

### Packages Swift

**Google Mobile Ads SDK** :
- Source : `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
- Version : Compatible iOS 16+
- Utilisé pour : Pubs interstitielles, récompensées, bannières

**StoreKit 2** (natif Apple) :
- Framework système (iOS 15+)
- Utilisé pour : Achats IAP, vérification transactions

### Assets externes

**Aucun** : L'app utilise uniquement SF Symbols et couleurs programmatiques.

---

## 🚨 Points d'attention (Design actuel)

### 1. Dépendance critique AdMob

- SDK initialisé dans `AppDelegate`
- Préchargement au launch
- Fallback `FakeAdView` si pub non chargée
- ⚠️ **Problème** : Si SDK non initialisé, les pubs ne fonctionnent pas

### 2. Vérifications répétées

- `isPremiumUser` vérifié dans :
  - AdManager (avant affichage pub)
  - GameViewModel (gating tours)
  - SetupView (déblocage presets)
  - AddPlayerSheet (limite joueurs)
  - HistoryView (bannière)
  - SettingsView (affichage sections)

### 3. État réparti

- **StoreManager** : État achats (Bundle, Premium, packs)
- **AdManager** : État pubs (loading, lastShown)
- **GameViewModel** : État jeu (turnCount pour gating)
- ⚠️ **Couplage** : GameViewModel dépend de StoreManager pour les pubs

### 4. Persistance IAP

- Sauvegarde locale uniquement (UserDefaults)
- Pas de serveur backend
- Restauration via `Transaction.currentEntitlements` (StoreKit 2)
- ⚠️ **Risque** : Perte de données si désinstallation sans restauration

---

## 🎯 Architecture Résumée

```
UniversalScoreboardApp (Root)
    ├── AppDelegate → Initialise Google Mobile Ads
    ├── @StateObject GameViewModel → Logique métier jeu
    ├── @StateObject AdManager → Gestion pubs
    │
    └── SplashScreenView
        ├── Si game != nil → GameView
        └── Sinon → MainTabView
            ├── SetupView (Nouveau jeu)
            ├── HistoryView (Archive)
            ├── ProfilesView (Profils)
            └── SettingsView (IAP)

Services (Singletons):
    ├── StoreManager.shared → Achats IAP
    ├── AdManager.shared → Publicités
    ├── PersistenceManager.shared → Sauvegarde JSON
    ├── HistoryManager.shared → Archive parties
    ├── ProfileManager.shared → Stats joueurs
    ├── NotificationManager.shared → Notifs locales
    └── MigrationManager → Migrations données
```

---

## 📝 Notes Importantes

### Points forts de l'architecture actuelle

✅ **MVVM bien structuré** : Séparation claire Model-View-ViewModel  
✅ **Services singletons** : Accès centralisé aux managers  
✅ **Persistance robuste** : UserDefaults + JSON encodage  
✅ **StoreKit 2 moderne** : Async/await, vérification transactions  
✅ **Undo local-first** : Histoire en mémoire, disque best-effort  
✅ **Migration automatique** : Protège les utilisateurs existants  

### Points à améliorer (avant migration gratuite)

⚠️ **Couplage AdManager ↔ GameViewModel** : Logique pub dans ViewModel  
⚠️ **Vérifications répétées** : `isPremiumUser` dupliqué partout  
⚠️ **IDs AdMob en dur** : Pas de configuration centralisée  
⚠️ **Pas de tests unitaires** : Difficile de tester les flows IAP/pubs  
⚠️ **Pas de feature flags** : Impossible de tester modes sans rebuild  

---

## 🔮 Prochaine Étape

➡️ **Migration vers version 100% gratuite** (voir PLAN-MIGRATION-GRATUIT.md)

---

**Document généré le** : 12/05/2026  
**Auteur** : Assistant IA Banacourt  
**Projet** : PointBoard — Universal Scoreboard App
