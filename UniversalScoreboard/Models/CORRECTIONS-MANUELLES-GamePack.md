# 🔧 CORRECTIONS MANUELLES REQUISES — GamePack.swift

**Date** : 31/05/2026  
**Raison** : Problèmes d'encodage (emojis) empêchent str_replace automatique  
**Status** : ⚠️ CORRECTIONS MANUELLES NÉCESSAIRES

---

## ❌ BLOCS DE CODE À SUPPRIMER MANUELLEMENT

### 1️⃣ Supprimer : Property `price` (lignes ~57-66)

**Chercher ce bloc** :
```swift
    /// Prix "string" (simple UI).
    /// - Note : si tu veux le vrai prix StoreKit (localisé), récupère Product.displayPrice côté StoreManager.
    var price: String {
        // Tous les packs sont gratuits
        switch self {
        case .coreFree, .classicCards, .funCardsDice, .boardFamily, .outdoorSport, .partyNight, .duelsStrategy, .kidsFamily2:
            return "Gratuit"
        }
    }
```

**Action** : Supprimer COMPLÈTEMENT ce bloc (commentaires inclus)

---

### 2️⃣ Supprimer : Property `productID` (lignes ~68-73)

**Chercher ce bloc** :
```swift
    // MARK: - StoreKit Product IDs

    /// Obsolète: les IAP sont retirés, conserver pour compatibilité binaire.
    var productID: String? {
        return nil
    }
```

**Action** : Supprimer COMPLÈTEMENT ce bloc (MARK + commentaires + property)

---

### 3️⃣ **DÉJÀ SUPPRIMÉ** ✅ : Static var `paidPacks`

✅ Cette property a déjà été supprimée automatiquement.

---

## 📝 FICHIER APRÈS CORRECTION

Après suppression, la structure devrait être :

```swift
// MARK: - UI / Display

var displayName: String {
    switch self {
    case .coreFree:       return "Basiques & Démos"
    // ... etc
    }
}

// MARK: - Description (marketing)   ← Devrait être juste après displayName

var description: String {
    switch self {
    case .coreFree:
        return "Les indispensables : Uno, Skyjo, Monopoly + Modes personnalisés"
    // ... etc
    }
}

// MARK: - Presets inclus (source de vérité pack -> presets)  ← Devrait venir ensuite

var includedPresets: [PresetID] {
    // ... etc
}
```

---

## 🎯 CHECKLIST

- [ ] Ouvrir `GamePack.swift` dans Xcode
- [ ] Supprimer property `price` (lignes ~57-66)
- [ ] Supprimer property `productID` (lignes ~68-73)
- [ ] Vérifier compilation (Cmd+B)
- [ ] Rechercher "price" dans le projet (aucune référence)
- [ ] Rechercher "productID" dans le projet (aucune référence)
- [ ] Rechercher "paidPacks" dans le projet (aucune référence)

---

## ⚠️ POURQUOI MANUEL ?

Les emojis dans `displayName` (🃏, 🎲, ♟️, ☀️, 🎉, 🧠, 👨‍👩‍👧‍👦) causent des problèmes d'encodage Unicode avec `str_replace`, rendant le matching impossible.

**Solution** : Édition manuelle dans Xcode (safe et rapide).

---

## ✅ APRÈS CORRECTIONS

Une fois les modifications faites, vérifie :

1. **Compilation** : Aucune erreur (Cmd+B)
2. **Recherche** : `price`, `productID`, `paidPacks` → 0 résultats
3. **Clean Build** : Product → Clean Build Folder
4. **Archive** : Créer un nouveau build pour App Store

---

## 📊 IMPACT

### ✅ Ce qui sera corrigé

- ❌ Suppression `var price: String` → Plus de mention "prix"
- ❌ Suppression `var productID: String?` → Plus de référence StoreKit
- ✅ `static var paidPacks` **déjà supprimé**

### ✅ Ce qui restera

- ✅ `displayName` : OK (noms des packs)
- ✅ `description` : OK (descriptions marketing)
- ✅ `includedPresets` : OK (liste des jeux)
- ✅ `packContaining(_:)` : OK (helper de mapping)

---

## 🚀 RÉSULTAT FINAL

**Fichier conforme App Store Review** :
- ✅ Aucune référence à "prix"
- ✅ Aucune référence à "productID"
- ✅ Aucune référence à "packs payants"
- ✅ Tous les packs sont gratuits (pas de logique IAP)

---

**Note** : Ce fichier peut être supprimé après validation App Store réussie.
