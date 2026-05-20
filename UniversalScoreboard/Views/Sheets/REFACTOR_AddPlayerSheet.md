# 🛠️ Refactor AddPlayerSheet.swift — Version 100% Gratuite

**Date** : 20/05/2026  
**Objectif** : Supprimer toute logique freemium/paywall et rendre l'app gratuite (max 20 joueurs)  
**Status** : 🚧 EN COURS

---

## 📋 Liste des tâches

### ✅ Phase 1 : Nettoyage des propriétés obsolètes

- [ ] **TASK-1.1** : Supprimer `@State private var showProUpsellAlert`
- [ ] **TASK-1.2** : Changer `let maxPlayers: Int = 12` → `let maxPlayers: Int = 20`
- [ ] **TASK-1.3** : Supprimer `let canAddPlayer: Bool` (inutile si pas de restriction)

---

### ✅ Phase 2 : Supprimer les computed properties freemium

- [ ] **TASK-2.1** : Supprimer le code orphelin entre `canSubmitGuest` et `bannerIconSystemName` (lignes 44-51)
- [ ] **TASK-2.2** : Supprimer `private var bannerIconSystemName: String`
- [ ] **TASK-2.3** : Supprimer `private var bannerTintColor: Color`

---

### ✅ Phase 3 : Nettoyer le body

- [ ] **TASK-3.1** : Supprimer l'alert "Deviens Pro" (lignes ~174-181)
- [ ] **TASK-3.2** : Mettre à jour le texte de la Section : "Liste (max 20 joueurs)"

---

### ✅ Phase 4 : Supprimer les UI components inutiles

- [ ] **TASK-4.1** : Supprimer `private var freemiumBanner: some View` (lignes ~192-208)

---

### ✅ Phase 5 : Simplifier la logique

- [ ] **TASK-5.1** : Simplifier `attemptAddPlayer()` pour juste vérifier les 20 joueurs max
- [ ] **TASK-5.2** : Vérifier que toutes les références à `isProOrTrial` et `shouldShowAdRequiredBanner` sont supprimées

---

### ✅ Phase 6 : Corriger le Preview

- [ ] **TASK-6.1** : Supprimer le paramètre `maxPlayers: 6` du Preview
- [ ] **TASK-6.2** : Supprimer le paramètre `canAddPlayer: true` si on a supprimé la propriété

---

## 📊 Progression

- **Total** : 12 tâches
- **Terminées** : 0
- **En cours** : 0
- **Restantes** : 12

---

## 🔄 Changelog

### [20/05/2026 - Début]
- Création du plan de refactoring
- Début de l'exécution

---

## ✅ Validation finale

- [ ] Le fichier compile sans erreur
- [ ] Aucune référence à Pro/Trial/Ads/Paywall
- [ ] Limite fixée à 20 joueurs
- [ ] Design system préservé
- [ ] Preview fonctionnel
