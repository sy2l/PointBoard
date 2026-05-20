# 📋 Migration : 12 → 20 joueurs max (Gratuit)

**Date** : 20/05/2026  
**Fichier concerné** : `AddPlayerSheet.swift`  
**Objectif** : Passer de 12 à 20 joueurs maximum en version gratuite

---

## ✅ État des lieux

Le fichier est **déjà propre** ! Tout le code freemium a été retiré.  
Il reste juste à ajuster la limite de joueurs.

---

## 🎯 TASKS

### ✅ Task 1 : Mettre à jour la constante `maxPlayers`
- **Ligne** : 27
- **Action** : Changer `let maxPlayers: Int = 12` → `let maxPlayers: Int = 20`
- **Status** : ✅ TERMINÉ

---

### ✅ Task 2 : Mettre à jour le commentaire en-tête
- **Ligne** : 10
- **Action** : Changer `- 12 joueurs maximum (gratuit)` → `- 20 joueurs maximum (gratuit)`
- **Status** : ✅ TERMINÉ

---

### ✅ Task 3 : Mettre à jour la section "Liste des joueurs"
- **Ligne** : 76
- **Action** : Changer `Section("Liste (max 12 joueurs)")` → `Section("Liste (max 20 joueurs)")`
- **Status** : ✅ TERMINÉ

---

### ✅ Task 4 : Mettre à jour le commentaire de la fonction `attemptAddPlayer`
- **Ligne** : 159
- **Action** : Changer `/// Ajout de joueur (12 joueurs maximum, gratuit)` → `/// Ajout de joueur (20 joueurs maximum, gratuit)`
- **Status** : ✅ TERMINÉ

---

### ✅ Task 5 : Mettre à jour le commentaire inline dans `attemptAddPlayer`
- **Ligne** : 161
- **Action** : Changer `// Limite à 12 joueurs` → `// Limite à 20 joueurs`
- **Status** : ✅ TERMINÉ

---

### ✅ Task 6 : Mettre à jour le commentaire de mise à jour du fichier
- **Ligne** : 6
- **Action** : Changer `Updated by sy2l on 13/05/2026 — V6.0.0 : App gratuite (12 joueurs max)` 
  → `Updated by sy2l on 20/05/2026 — V6.1.0 : App gratuite (20 joueurs max)`
- **Status** : ✅ TERMINÉ

---

## 📊 Résumé

- **Total tasks** : 6
- **Terminées** : ✅ 6
- **En cours** : 0
- **En attente** : 0

---

## 🎉 MIGRATION TERMINÉE !

Tous les changements ont été appliqués avec succès.
### Changements effectués :
- ✅ Limite de joueurs passée de 12 → 20
- ✅ Tous les commentaires mis à jour
- ✅ UI Section mise à jour
- ✅ Version bump : V6.0.0 → V6.1.0
- ✅ Date de mise à jour : 20/05/2026

Le fichier `AddPlayerSheet.swift` est maintenant **100% gratuit avec support de 20 joueurs** ! 🚀

