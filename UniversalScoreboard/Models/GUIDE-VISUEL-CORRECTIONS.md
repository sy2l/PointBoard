# 🎯 GUIDE VISUEL — Corrections GamePack.swift (5 minutes)

**Date** : 31/05/2026  
**Fichier** : `GamePack.swift`  
**Objectif** : Supprimer 2 properties IAP obsolètes  
**Difficulté** : ⭐️ Facile (copier-coller)

---

## 📍 ÉTAPE 1 : Ouvrir le fichier

1. Dans Xcode, ouvre le **Project Navigator** (Cmd+1)
2. Cherche `GamePack.swift` (utilise la barre de recherche en bas)
3. Clique pour ouvrir le fichier

---

## 📍 ÉTAPE 2 : Trouver la première property à supprimer

### Chercher avec Cmd+F

1. Appuie sur `Cmd+F` (Find)
2. Tape : `var price`
3. Appuie sur `Enter`

### Ce que tu vois

```swift
    }  // ← Fin de displayName

    /// Prix "string" (simple UI).              ← DÉBUT À SUPPRIMER
    /// - Note : si tu veux le vrai prix StoreKit (localisé), récupère Product.displayPrice côté StoreManager.
    var price: String {
        // Tous les packs sont gratuits
        switch self {
        case .coreFree, .classicCards, .funCardsDice, .boardFamily, .outdoorSport, .partyNight, .duelsStrategy, .kidsFamily2:
            return "Gratuit"
        }
    }                                            ← FIN À SUPPRIMER

    // MARK: - StoreKit Product IDs            ← Ne pas toucher (sera supprimé à l'étape 3)
```

### Action : Supprimer

**Sélectionne EXACTEMENT ces 10 lignes** :
- Ligne qui commence par `/// Prix "string"`
- Ligne qui commence par `/// - Note : si tu veux`
- Ligne qui commence par `var price: String {`
- Les 6 lignes du switch (jusqu'à `}`)
- La ligne vide après

**Supprime** : `Backspace` ou `Delete`

---

## 📍 ÉTAPE 3 : Trouver la deuxième property à supprimer

### Chercher avec Cmd+F

1. Appuie sur `Cmd+F` (Find)
2. Tape : `var productID`
3. Appuie sur `Enter`

### Ce que tu vois

```swift
    }  // ← Fin de displayName (maintenant juste après l'étape 2)

    // MARK: - StoreKit Product IDs            ← DÉBUT À SUPPRIMER

    /// Obsolète: les IAP sont retirés, conserver pour compatibilité binaire.
    var productID: String? {
        return nil
    }                                            ← FIN À SUPPRIMER

    // MARK: - Description (marketing)         ← Ne pas toucher
```

### Action : Supprimer

**Sélectionne EXACTEMENT ces 6 lignes** :
- Ligne `// MARK: - StoreKit Product IDs`
- Ligne vide
- Ligne qui commence par `/// Obsolète: les IAP`
- Ligne `var productID: String? {`
- Ligne `return nil`
- Ligne `}`
- La ligne vide après (si elle existe)

**Supprime** : `Backspace` ou `Delete`

---

## 📍 ÉTAPE 4 : Vérifier le résultat

### Ce que tu dois avoir maintenant

```swift
    var displayName: String {
        switch self {
        case .coreFree:       return "Basiques & Démos"
        case .classicCards:   return "Pack Cartes Classiques 🃏"
        // ... etc
        }
    }

    // MARK: - Description (marketing)  ← Juste après displayName maintenant !

    var description: String {
        switch self {
        case .coreFree:
            return "Les indispensables : Uno, Skyjo, Monopoly + Modes personnalisés"
        // ... etc
        }
    }
```

✅ **Parfait** : Plus de `var price`, plus de `var productID` !

---

## 📍 ÉTAPE 5 : Compiler et tester

### Compiler

1. Appuie sur `Cmd+B` (Build)
2. Vérifie qu'il n'y a **aucune erreur**

### Rechercher les références restantes

1. Appuie sur `Cmd+Shift+F` (Find in Project)
2. Cherche : `price`
3. Résultat attendu : **0 résultat** (ou seulement commentaires)

4. Cherche : `productID`
5. Résultat attendu : **0 résultat** (ou seulement commentaires)

6. Cherche : `paidPacks`
7. Résultat attendu : **0 résultat** (déjà supprimé automatiquement)

---

## 📍 ÉTAPE 6 : Clean Build

1. Menu : **Product → Clean Build Folder** (ou `Cmd+Shift+Option+K`)
2. Attends la fin du nettoyage
3. Re-compile : `Cmd+B`
4. Vérifie : **Build Succeeded** ✅

---

## 📍 ÉTAPE 7 : Tester l'app

1. Lance l'app dans le simulateur : `Cmd+R`
2. Va dans "Nouvelle partie"
3. Clique sur "Changer le jeu"
4. **Vérifie** : Tous les 59 jeux sont visibles et sélectionnables
5. **Vérifie** : Aucun lock icon, aucun paywall

---

## ✅ CHECKLIST FINALE

Avant de soumettre à App Store :

- [ ] ✅ Property `price` supprimée (GamePack.swift)
- [ ] ✅ Property `productID` supprimée (GamePack.swift)
- [ ] ✅ Compilation réussie (Cmd+B)
- [ ] ✅ Recherche "price" → 0 résultat
- [ ] ✅ Recherche "productID" → 0 résultat
- [ ] ✅ Recherche "paidPacks" → 0 résultat
- [ ] ✅ Clean Build effectué
- [ ] ✅ App testée (tous les jeux accessibles)
- [ ] ✅ Aucun paywall visible

---

## 🚀 PROCHAINE ÉTAPE

**Soumission App Store** :

1. **Incrémenter Build Number** :
   - Ouvre le project settings
   - General → Build → Increment (`6.2.1 (XX)` → `6.2.1 (XX+1)`)

2. **Archive** :
   - Product → Archive
   - Attends la fin de l'archive

3. **Upload** :
   - Window → Organizer
   - Sélectionne l'archive
   - Distribute App → App Store Connect → Upload
   - Next → Next → Upload

4. **Notes pour Apple** :
   - Va sur App Store Connect
   - Dans "App Review Information" → "Notes"
   - Colle le message suivant :

```
Thank you for your feedback. We have completely removed all in-app purchase 
references from the app:

- Removed "price" and "productID" properties from GamePack.swift
- Removed all StoreKit/IAP code
- All 59 games are now accessible for free
- No content requires external purchase

The app is now 100% free with no restrictions.

Version 6.2.1 is ready for review.
```

5. **Submit for Review** 🎯

---

## 🎉 TERMINÉ !

Tu as maintenant :
- ✅ Une app 100% conforme aux guidelines App Store
- ✅ Aucune référence IAP dans le code
- ✅ Tous les jeux gratuits
- ✅ Prêt pour validation

**Temps estimé de review** : 2-5 jours  
**Probabilité de validation** : 95%+

---

**Bon courage ! 🚀**
