# 🔍 AUDIT COMPLET — Vérification App 100% Gratuite

**Date** : 20/05/2026  
**Version cible** : V6.1.0  
**Objectif** : S'assurer que TOUTE logique paywall/IAP/unlock a été retirée

---

## ✅ FICHIERS DÉJÀ NETTOYÉS

### 1️⃣ **AddPlayerSheet.swift** ✅
- **Status** : ✅ PROPRE
- **Limite** : 20 joueurs max (gratuit)
- **Code freemium retiré** :
  - ✅ Pas de `isProOrTrial`
  - ✅ Pas de `shouldShowAdRequiredBanner`
  - ✅ Pas de `showProUpsellAlert`
  - ✅ Pas de bannière paywall
  - ✅ Pas d'alert "Deviens Pro"

---

### 2️⃣ **MigrationManager.swift** ✅
- **Status** : ✅ PROPRE (mais à optimiser)
- **Rôle** : Nettoie les anciennes clés IAP des utilisateurs existants
- **Actions** :
  - ✅ `migrateV2toV3()` supprime les clés obsolètes :
    - `store.hasAllPacksBundle`
    - `store.hasPremiumNoAds`
    - `store.unlockedPacks`
    - `store.isProUser`
  - ✅ Migration marquée comme "V3 completed"

**Recommandation** : ✅ Bon à garder pour la rétrocompatibilité

---

### 3️⃣ **StoreManager.swift** ✅
- **Status** : ✅ FICHIER MARQUÉ POUR SUPPRESSION
- **Contenu** : Fichier vide avec commentaire de tracking
- **Action requise** : ⚠️ À supprimer manuellement dans Xcode

---

### 4️⃣ **PackUnlockSheet.swift** ✅
- **Status** : ✅ FICHIER MARQUÉ POUR SUPPRESSION
- **Contenu** : Fichier vide avec commentaire de tracking
- **Action requise** : ⚠️ À supprimer manuellement dans Xcode

---

## 🚨 FICHIERS AVEC CODE PAYWALL RESTANT

### 1️⃣ **GamePack.swift** ⚠️ PROBLÈME MAJEUR

**Fichier** : `/repo/GamePack.swift`  
**Status** : ❌ LOGIQUE IAP ENCORE PRÉSENTE

#### Problèmes identifiés :

```swift
// ❌ Référence aux packs payants
var price: String { self == .coreFree ? "Gratuit" : "0,99 €" }

// ❌ Product IDs StoreKit
var productID: String? {
    case .classicCards:   return "com.universalscoreboard.pack.classicCards"
    case .funCardsDice:   return "com.universalscoreboard.pack.funCardsDice"
    // ... etc
}

// ❌ Fonction pour les packs payants
static var paidPacks: [GamePack] {
    allCases.filter { $0 != .coreFree }
}
```

#### Actions requises :

- ❌ **Supprimer** : `price` property (obsolète)
- ❌ **Supprimer** : `productID` property (obsolète)
- ❌ **Supprimer** : `paidPacks` computed property (obsolète)
- ✅ **Garder** : `displayName`, `description`, `includedPresets` (pour UI)
- ✅ **Simplifier** : Tous les packs deviennent gratuits

---

### 2️⃣ **SettingsView.swift** ⚠️ PROBLÈME MAJEUR

**Fichier** : `/repo/SettingsView.swift`  
**Status** : ❌ UI PAYWALL ENCORE PRÉSENTE

#### Composants à supprimer :

```swift
// ❌ Card Premium (obsolète)
struct PremiumStatusCard: View { ... }
struct PremiumCard: View { ... }

// ❌ Card Bundle (obsolète)
struct BundleCard: View { ... }

// ❌ Liste des packs avec unlock (obsolète)
struct PacksListView: View {
    let isUnlocked: Bool  // ❌ Plus besoin
    // ...
}

// ❌ Row pack avec lock icon (obsolète)
struct PackRowView: View {
    let isUnlocked: Bool  // ❌ Plus besoin
    if !isUnlocked {
        Image(systemName: "lock.fill")  // ❌ À retirer
    }
}
```

#### Actions requises :

- ❌ **Supprimer** : `PremiumStatusCard`
- ❌ **Supprimer** : `PremiumCard`
- ❌ **Supprimer** : `BundleCard`
- ❌ **Supprimer** : `PacksListView` (ou simplifier sans unlock)
- ❌ **Supprimer** : `PackRowView.isUnlocked`
- ❌ **Supprimer** : Toute référence à `StoreManager.shared`

---

## 📊 RÉSUMÉ AUDIT

| Fichier | Status | Actions requises |
|---------|--------|------------------|
| AddPlayerSheet.swift | ✅ PROPRE | Aucune |
| MigrationManager.swift | ✅ PROPRE | Aucune |
| StoreManager.swift | ⚠️ À SUPPRIMER | Supprimer manuellement (Xcode) |
| PackUnlockSheet.swift | ⚠️ À SUPPRIMER | Supprimer manuellement (Xcode) |
| **GamePack.swift** | ❌ CODE IAP | **Retirer price, productID, paidPacks** |
| **SettingsView.swift** | ❌ UI PAYWALL | **Retirer toutes les cards Premium/Bundle/Lock** |

---

## 🎯 PLAN D'ACTION

### Phase 1 : Nettoyage GamePack.swift ⏳
1. Supprimer `price` property
2. Supprimer `productID` property
3. Supprimer `paidPacks` computed property
4. Mettre à jour les commentaires (tous les packs = gratuits)

### Phase 2 : Nettoyage SettingsView.swift ⏳
1. Supprimer `PremiumStatusCard`
2. Supprimer `PremiumCard`
3. Supprimer `BundleCard`
4. Simplifier `PackRowView` (retirer lock icon + isUnlocked)
5. Supprimer toutes les références à `StoreManager.shared`

### Phase 3 : Suppression fichiers Xcode ⏳
1. Supprimer `StoreManager.swift` (Move to Trash)
2. Supprimer `PackUnlockSheet.swift` (Move to Trash)
3. Clean Build Folder

### Phase 4 : Tests finaux ⏳
1. Vérifier que l'app compile
2. Tester l'ajout de 20 joueurs
3. Vérifier que tous les packs sont visibles/accessibles
4. Vérifier qu'aucun paywall n'apparaît

---

## 🚀 Prêt à appliquer ?

Dis **"applique phase 1"** pour nettoyer `GamePack.swift`  
Dis **"applique phase 2"** pour nettoyer `SettingsView.swift`  
Dis **"applique tout"** pour tout faire d'un coup ! 🎯

---

## 📝 Notes importantes

- ⚠️ Les fichiers `StoreManager.swift` et `PackUnlockSheet.swift` doivent être supprimés **manuellement dans Xcode**
- ⚠️ `GamePack.swift` contient encore des Product IDs StoreKit (obsolètes)
- ⚠️ `SettingsView.swift` affiche encore des UI de paywall (cards Premium/Bundle)
- ✅ `AddPlayerSheet.swift` est déjà 100% propre (20 joueurs gratuits)
- ✅ `MigrationManager.swift` nettoie correctement les anciennes données IAP

---

## 🎉 Objectif final

**App 100% gratuite, sans restriction, sans paywall, sans IAP.**

- ✅ 20 joueurs max (gratuit)
- ✅ Tous les packs débloqués
- ✅ Aucune référence à StoreKit, RevenueCat, IAP
- ✅ UI simplifiée sans lock icons
