# 🔧 PLAN DE NETTOYAGE : AddPlayerSheet.swift

**Date** : 13/05/2026  
**Fichier** : `AddPlayerSheet.swift`  
**Objectif** : Nettoyer complètement le code mort et supprimer toutes les références freemium/IAP

---

## 🔍 ANALYSE DU PROBLÈME

### ❌ Erreurs identifiées

Le fichier contient **du code mort** (lignes 49-61) qui référence des variables inexistantes :
```swift
// CODE MORT (lignes 49-61) :
    if isProOrTrial {                    // ❌ Variable inexistante
        return "Jusqu'à 12 joueurs"
    }
    if shouldShowAdRequiredBanner {      // ❌ Variable inexistante
        return "de 7 à 12 joueurs"
    }
    return "jusqu'à 6 joueurs"
}

private var bannerIconSystemName: String {
    if isProOrTrial { return "crown.fill" }
    return shouldShowAdRequiredBanner ? "lock.fill" : "checkmark.seal.fill"
}

private var bannerTintColor: Color {
    if isProOrTrial { return .yellow }
    return shouldShowAdRequiredBanner ? .orange : .green
}
```

### ❌ Composants obsolètes

1. **Alert "Deviens Pro"** (lignes 186-195) : Référence à paywall inexistant
2. **View `freemiumBanner`** (lignes 199-216) : Affichage de statut freemium
3. **Preview avec `maxPlayers: 6`** (ligne 317) : Devrait être 12

---

## 📋 TASKS DE NETTOYAGE (7 tasks)

### ✅ Task 1 : Supprimer le code mort (lignes 49-61)

**Localisation** : Après `private var canSubmitGuest: Bool`

**Action** : Supprimer complètement ces lignes :
```swift
// SUPPRIMER TOUT CE BLOC :
        if isProOrTrial {
            return "Jusqu'à 12 joueurs"
        }
        if shouldShowAdRequiredBanner {
            return "de 7 à 12 joueurs"
        }
        return "jusqu'à 6 joueurs"
    }

    private var bannerIconSystemName: String {
        if isProOrTrial { return "crown.fill" }
        return shouldShowAdRequiredBanner ? "lock.fill" : "checkmark.seal.fill"
    }

    private var bannerTintColor: Color {
        if isProOrTrial { return .yellow }
        return shouldShowAdRequiredBanner ? .orange : .green
    }
```

**Résultat attendu** : La section `// MARK: - Computed` doit se terminer directement par `canSubmitGuest`, puis vient `// MARK: - Body`

---

### ✅ Task 2 : Supprimer l'alert "Deviens Pro"

**Localisation** : Après `.toolbar { }`, avant la fermeture de `NavigationStack`

**Action** : Supprimer complètement ce bloc :
```swift
// SUPPRIMER :
            // MARK: - Pro upsell
            
            .alert("Deviens Pro", isPresented: $showProUpsellAlert) {
                Button("Plus tard", role: .cancel) { }
                Button("Voir l'offre Pro") {
                    // TODO: branche ton paywall ici
                }
            } message: {
                Text("La version gratuite est limitée à 12 joueurs. Passe Pro pour en ajouter davantage.")
            }
```

**Résultat attendu** : La fermeture du `.toolbar { }` est suivie directement de `}` (fermeture de NavigationStack), puis `}` (fermeture du body)

---

### ✅ Task 3 : Supprimer la view `freemiumBanner`

**Localisation** : Section `// MARK: - UI Components`

**Action** : Supprimer complètement cette section :
```swift
// SUPPRIMER TOUTE LA SECTION :
    // MARK: - UI Components

    private var freemiumBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: bannerIconSystemName)
                .foregroundColor(bannerTintColor)

            Text("\(bannerTitle) ")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(bannerTintColor)
            +
            Text(bannerSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
```

**Résultat attendu** : Après la fermeture du `body`, on passe directement à `// MARK: - Add Player Logic`

---

### ✅ Task 4 : Corriger le Preview (maxPlayers)

**Localisation** : `AddPlayerSheetPreviewWrapper`

**Action** : Changer `maxPlayers: 6` en supprimant complètement ce paramètre (valeur par défaut = 12)

**Avant** :
```swift
AddPlayerSheet(
    playerSlots: $playerSlots,
    maxPlayers: 6,                    // ❌ À supprimer
    canAddPlayer: true,
    availableProfiles: [],
    onTapPickProfile: { _ in },
    onClose: {}
)
```

**Après** :
```swift
AddPlayerSheet(
    playerSlots: $playerSlots,
    canAddPlayer: true,
    availableProfiles: [],
    onTapPickProfile: { _ in },
    onClose: {}
)
```

---

### ✅ Task 5 : Vérifier la structure finale

**Action** : Vérifier que le fichier a cette structure propre :

```
1. Imports
2. struct AddPlayerSheet: View
   - @Environment, @Binding, let properties
   - @State private var guestName
   - Computed properties (trimmedGuestName, canSubmitGuest)
   - body: some View
     - NavigationStack
       - List (3 sections)
       - .toolbar
   - attemptAddPlayer (logique simple)
   - Actions (addGuest, addProfile, removePlayer, removeProfile)
3. struct PlayerSlotEditableRow: View
4. Preview
```

**Aucune** référence à :
- `isProOrTrial`
- `shouldShowAdRequiredBanner`
- `bannerTitle`, `bannerSubtitle`
- `showProUpsellAlert`
- `freemiumBanner`
- `StoreManager`
- `AdManager`

---

### ✅ Task 6 : Simplifier le commentaire du header

**Localisation** : En-tête du fichier

**Action** : Vérifier que le header est clair et ne mentionne plus "freemium"

**Version finale souhaitée** :
```swift
/*
 * AddPlayerSheet.swift
 * PointBoard
 *
 * Created by sy2l on 21/01/2026.
 * Updated by sy2l on 13/05/2026 — V6.0.0 : App gratuite (12 joueurs max)
 * -----------------------------------------------------------------------------
 * AddPlayerSheet — Ajout d'un joueur (invité ou profil)
 * -----------------------------------------------------------------------------
 * - 12 joueurs maximum (gratuit)
 * - Ajout invité (TextField)
 * - Ajout profil enregistré (Liste)
 * - Modification/Suppression en cours de partie
 * -----------------------------------------------------------------------------
 */
```

---

### ✅ Task 7 : Vérifier la conformité Apple Best Practices

**Checklist** :

- [ ] **SwiftUI natif** : Pas de UIKit, pas de wrapper custom
- [ ] **@Binding pattern** : Communication parent-enfant propre
- [ ] **Computed properties** : Logique séparée de la vue
- [ ] **Private methods** : Encapsulation correcte
- [ ] **Naming Apple-style** : `attemptAddPlayer`, `addGuest`, etc.
- [ ] **List style inset** : `.listStyle(.insetGrouped)` (Apple recommandé)
- [ ] **Toolbar placement** : `.topBarLeading`, `.topBarTrailing` (correct)
- [ ] **Button roles** : `.destructive` pour suppression (correct)
- [ ] **Accessibility** : Labels avec SF Symbols (correct)
- [ ] **Preview** : `#Preview` moderne (correct)

---

## 🎯 ORDRE D'EXÉCUTION RECOMMANDÉ

```
1. Task 1 : Supprimer code mort (lignes 49-61)         [CRITIQUE]
2. Task 2 : Supprimer alert "Deviens Pro"              [CRITIQUE]
3. Task 3 : Supprimer view freemiumBanner               [IMPORTANTE]
4. Task 4 : Corriger Preview                            [SIMPLE]
5. Task 5 : Vérifier structure finale                   [VALIDATION]
6. Task 6 : Simplifier header                           [COSMÉTIQUE]
7. Task 7 : Checklist Apple Best Practices              [VALIDATION]
```

---

## ✅ RÉSULTAT FINAL ATTENDU

### Structure propre (~ 220 lignes)

```swift
// Imports
import SwiftUI

// AddPlayerSheet
struct AddPlayerSheet: View {
    // Properties (20 lignes)
    // Computed (10 lignes)
    // Body (110 lignes)
    // Logic (10 lignes)
    // Actions (30 lignes)
}

// PlayerSlotEditableRow
private struct PlayerSlotEditableRow: View {
    // (40 lignes)
}

// Preview
#Preview {
    // (20 lignes)
}
```

### Code 100% clean

```
✅ 0 référence à StoreManager
✅ 0 référence à AdManager
✅ 0 code mort (variables inexistantes)
✅ 0 alert paywall
✅ 0 banner freemium
✅ Limite 12 joueurs (simple guard)
✅ Apple Best Practices respectées
```

---

## 🚨 ERREURS À ÉVITER

### ❌ NE PAS faire :
- Ajouter des vérifications `isPremiumUser`
- Ajouter des calls à `AdManager.showRewardedAd`
- Ajouter des limites différentes selon le statut (6 vs 12)
- Compliquer la logique `attemptAddPlayer`

### ✅ À faire :
- **Garder simple** : `guard playerSlots.count < 12`
- **Pas de dépendances** : Juste `playerSlots`, `availableProfiles`
- **Vue stateless** : Toutes les données viennent du parent
- **Logique minimale** : Ajout, suppression, c'est tout

---

## 📊 MÉTRIQUES DE QUALITÉ

### Avant nettoyage :
- **Lignes** : ~340 (avec code mort)
- **Computed properties** : 6 (dont 3 obsolètes)
- **Dépendances** : StoreManager, AdManager
- **Complexité** : 🔴 Élevée (freemium logic)

### Après nettoyage :
- **Lignes** : ~220 (propre)
- **Computed properties** : 2 (utiles uniquement)
- **Dépendances** : 0 (vue pure)
- **Complexité** : 🟢 Faible (add/remove)

---

## 🎯 VALIDATION FINALE

### Test manuel (après nettoyage) :

1. ✅ **Build réussit** : 0 erreur de compilation
2. ✅ **Ajout invité** : TextField → Bouton → Apparaît dans liste
3. ✅ **Ajout profil** : Sélection profil → Apparaît avec icône
4. ✅ **Suppression** : Trash icon → Joueur retiré
5. ✅ **Limite 12** : Impossible d'ajouter un 13e joueur (guard silent)
6. ✅ **Toolbar** : Compteur "X/12" à jour
7. ✅ **Fermeture** : Bouton X → Dismiss

---

## 📝 NOTES TECHNIQUES

### Garde simple pour la limite

**❌ Mauvais** (ancien système freemium) :
```swift
func addPlayerSlot() {
    if playerSlots.count >= 6 && !StoreManager.shared.hasAllPacksBundle {
        showingAdOrProAlert = true
        return
    }
    if playerSlots.count >= 12 {
        // Hard cap
        return
    }
    playerSlots.append(PlayerSlot(name: ""))
}
```

**✅ Bon** (système gratuit) :
```swift
private func attemptAddPlayer(performAdd: @escaping () -> Void) {
    guard playerSlots.count < 12 else { return }
    performAdd()
}
```

**Avantages** :
- 1 seule vérification
- Pas de dépendance externe
- Logique claire et testable
- Conforme Apple : "Fail silently for UX" (pas d'alert invasive)

---

## 🚀 COMMANDES UTILES

### Après avoir fait les modifications :

```bash
# 1. Nettoyer DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/UniversalScoreboard-*

# 2. Dans Xcode :
# Product → Clean Build Folder (Cmd+Shift+K)

# 3. Rebuild
# Product → Build (Cmd+B)

# 4. Vérifier 0 warning
# Navigator → Issues (Cmd+5)
```

---

## ✅ CHECKLIST POST-NETTOYAGE

```
[ ] Task 1 : Code mort supprimé
[ ] Task 2 : Alert "Deviens Pro" supprimé
[ ] Task 3 : freemiumBanner supprimé
[ ] Task 4 : Preview corrigé (pas de maxPlayers: 6)
[ ] Task 5 : Structure vérifiée (propre)
[ ] Task 6 : Header mis à jour
[ ] Task 7 : Apple Best Practices OK

[ ] Build réussit (0 erreur)
[ ] 0 warning
[ ] Tests manuels OK
[ ] Code review OK (simple, lisible)
```

---

**Document créé le** : 13/05/2026  
**Auteur** : Assistant IA Banacourt  
**Projet** : PointBoard V6.0.0 — Migration Gratuite  
**Statut** : 🟢 PRÊT POUR EXÉCUTION
