# 📊 Guide Complet : Statistiques dans PointBoard

Date : 08/03/2026

## 🎯 Deux Types de Statistiques

### 1. **Stats de Joueur** (PlayerStatsView) 👤
**Accessible depuis** : Paramètres → Profils → [Profil]

**Contenu** :
- ✅ Parties jouées
- ✅ Victoires
- ✅ Défaites
- ✅ Éliminations
- ✅ Taux de victoire (%)
- ✅ Score moyen
- ✅ Score minimum
- ✅ Score maximum
- ✅ Graphique Victoires/Défaites/Éliminations (barres)
- ✅ Évolution des performances (placeholder pour Sprint 5)

**Design** : Style moderne avec avatar, couleurs et graphiques

---

### 2. **Stats Avancées de Partie** (AdvancedStatsView) 🎮
**Accessible depuis** : ResultsView → "Voir les stats avancées"

**Restriction** :
- 🔒 Utilisateurs gratuits : **Après avoir regardé une pub** (15 sec)
- ✅ Utilisateurs Pro : **Accès direct**

---

## 📈 Statistiques Intelligentes (AdvancedStatsView)

### Section 1 : Résumé de la Partie

| Statistique | Description | Icône |
|-------------|-------------|-------|
| **Tours Joués** | Nombre total de tours | `arrow.clockwise` |
| **Joueurs** | Nombre de joueurs | `person.2.fill` |
| **Score Moyen** | Moyenne arithmétique des scores | `chart.line.uptrend.xyaxis` |
| **Écart Max** | Différence entre meilleur et pire score | `arrow.up.arrow.down` |

**Exemple** :
```
Tours Joués : 11
Joueurs     : 5
Score Moyen : 63
Écart Max   : 67
```

---

### Section 2 : Statistiques Intelligentes 🧠

#### 2.1 Meilleur Score 🏆
- **Joueur** avec le meilleur score selon le mode de jeu
- **Mode "score le plus bas"** → Plus petit score
- **Mode "score le plus haut"** → Plus grand score

**Exemple** : `Alice avec 38 pts` (Skyjo)

#### 2.2 Score le Plus Élevé/Faible
- Joueur avec le pire score selon le mode
- **N'affiche PAS** si c'est le même que le meilleur

**Exemple** : `Charlie avec 105 pts` (éliminé)

#### 2.3 Compétitivité 🔥
Calcul intelligent basé sur le **coefficient de variation** :

```swift
coefficient = écart_max / score_moyen
```

| Coefficient | Label | Couleur | Signification |
|-------------|-------|---------|---------------|
| < 0.2 | Très Serré 🔥 | Vert | Match très équilibré |
| 0.2 - 0.5 | Équilibré | Vert sage | Match normal |
| 0.5 - 1.0 | Écarts Modérés | Orange | Différences notables |
| > 1.0 | Grands Écarts | Rouge | Match déséquilibré |

**Exemple** :
- Écart max = 67
- Score moyen = 63
- Coefficient = 67/63 = 1.06
- **Résultat** : "Grands Écarts" (rouge)

#### 2.4 Durée Estimée ⏱️
Estimation basée sur **2 minutes par tour** :

```swift
durée_estimée = tours_joués × 2 minutes
```

**Exemple** : 11 tours = 22 minutes

---

### Section 3 : Distribution des Scores (Graphique) 📊

**Type** : Graphique en **barres verticales** (Swift Charts)

**Données** :
- Axe X : Nom des joueurs
- Axe Y : Scores
- Annotations : Score affiché au-dessus de chaque barre

**Couleurs** :
- 🏆 **Vainqueur** : Vert (`.success`)
- ❌ **Éliminé** : Rouge (`.error`)
- 🥇 **Meilleur score** (actif) : Couleur du thème
- 🎮 **Autres** : Couleur secondaire (`.appSecondary`)

**Exemple visuel** :
```
    120│         Charlie (❌)
    100│           ▓▓▓
     80│         ▓▓▓▓▓   Bob
     60│         ▓▓▓▓▓  ▓▓▓▓
     40│  Eve   ▓▓▓▓▓  ▓▓▓▓  Diana
     20│ (🏆)   ▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓  Alice
      0└──────┬──────┬──────┬──────┬──────
          Eve  Charlie  Bob  Diana Alice
```

---

### Section 4 : Classement Détaillé 🏅

**Format** : Liste ordonnée avec design riche

#### Informations par Joueur

| Élément | Description |
|---------|-------------|
| **Rang** | Position (1, 2, 3...) avec couleur |
| **Nom** | Avec badge couronne si vainqueur |
| **Statut** | 🏆 Vainqueur / ❌ Éliminé / 🎮 En jeu |
| **Score** | Score final |
| **Écart** | Différence avec le meilleur |

#### Couleurs des Rangs

| Rang | Couleur | Signification |
|------|---------|---------------|
| 1️⃣ | Vert | Champion |
| 2️⃣ | Bleu | Second |
| 3️⃣ | Orange | Troisième |
| 4+ | Gris | Autres |

#### Design Spécial pour le 1er

- **Background** : Couleur du thème (transparente 10%)
- **Border** : Couleur du thème (transparente 30%)
- **Épaisseur** : 2px

**Exemple** :
```
┌─────────────────────────────────────┐
│ 1  Alice            🏆 Vainqueur  38│ ← Highlight vert
├─────────────────────────────────────┤
│ 2  Diana            🎮 En jeu     62│
│                                  +24│
├─────────────────────────────────────┤
│ 3  Bob              🎮 En jeu     78│
│                                  +40│
├─────────────────────────────────────┤
│ 4  Charlie          ❌ Éliminé  105│
│                                  +67│
└─────────────────────────────────────┘
```

---

### Section 5 : Configuration de la Partie ⚙️

**Informations** :

| Paramètre | Valeur Exemple |
|-----------|----------------|
| Mode de Jeu | Points / Manches |
| Valeur Initiale | 0 |
| Cible | 100 |
| Objectif | Score le plus bas 📉 |
| Conséquence Cible | Élimination ❌ |
| Date | 8 mars 2026 à 22:30 |

---

## 🎨 Design System

### Couleurs

```swift
// Couleurs sémantiques
.success  // Vert - Victoire, meilleur score
.error    // Rouge - Élimination, pire score
.warning  // Orange - Alertes, modération
.info     // Bleu - Informations neutres

// Couleurs de marque
.accentGreen     // Vert sage - Highlights positifs
.appPrimary      // Bleu - Couleur principale
.appSecondary    // Bleu clair - Éléments secondaires

// Texte
.textPrimary     // Noir/Blanc - Texte principal
.textSecondary   // Gris - Texte secondaire
```

### Icônes

| Statistique | Icône SF Symbol |
|-------------|-----------------|
| Tours | `arrow.clockwise` |
| Joueurs | `person.2.fill` |
| Score moyen | `chart.line.uptrend.xyaxis` |
| Écart | `arrow.up.arrow.down` |
| Meilleur | `trophy.fill` |
| Pire | `flag.fill` |
| Compétitivité | `flame.fill` |
| Durée | `clock.fill` |
| Graphique | `chart.bar.xaxis` |
| Classement | `list.number` |
| Configuration | `info.circle.fill` |
| Stats intelligentes | `lightbulb.fill` |

---

## 📱 UX / Flow

### Pour Utilisateurs Gratuits

```
ResultsView
    ↓
Tap "Voir les stats avancées"
    ↓
Alert : "Stats avancées"
    ↓
Choix : "Regarder une vidéo"
    ↓
Pub s'affiche (15 sec)
    ↓
Pub terminée
    ↓
Sheet AdvancedStatsView
    ↓
Scroll pour voir toutes les stats
    ↓
Tap "Fermer"
```

### Pour Utilisateurs Pro

```
ResultsView
    ↓
Tap "Voir les stats avancées"
    ↓
Sheet AdvancedStatsView (direct)
    ↓
Scroll pour voir toutes les stats
    ↓
Tap "Fermer"
```

---

## 🧮 Formules de Calcul

### Score Moyen
```swift
moyenne = somme_des_scores / nombre_de_joueurs
```

### Écart Maximum
```swift
écart_max = |meilleur_score - pire_score|
```

### Coefficient de Compétitivité
```swift
coefficient = écart_max / score_moyen
```

### Durée Estimée
```swift
durée = tours_joués × 2 minutes
```

### Écart avec le Meilleur
```swift
// Mode "score le plus bas"
écart = score_joueur - meilleur_score  // +24, +40, +67

// Mode "score le plus haut"
écart = meilleur_score - score_joueur  // -15, -30, -50
```

---

## 🚀 Améliorations Futures (V2)

### Graphique d'Évolution 📈
**Prérequis** : Passer `GameViewModel.gameHistory` à `AdvancedStatsView`

**Contenu** :
- Graphique **linéaire** avec Swift Charts
- Une ligne par joueur
- Axe X : Tours (1, 2, 3...)
- Axe Y : Scores
- Légende avec couleurs

**Code** :
```swift
Chart {
    ForEach(players) { player in
        ForEach(player.scoreHistory) { point in
            LineMark(
                x: .value("Tour", point.turn),
                y: .value("Score", point.score)
            )
            .foregroundStyle(by: .value("Joueur", player.name))
        }
    }
}
```

### Statistiques Avancées Supplémentaires

| Statistique | Formule | Description |
|-------------|---------|-------------|
| **Momentum** | `(score_final - score_initial) / tours` | Progression moyenne par tour |
| **Meilleur Tour** | `max(delta_par_tour)` | Tour avec le plus gros gain |
| **Pire Tour** | `min(delta_par_tour)` | Tour avec la plus grosse perte |
| **Régularité** | `écart_type(deltas)` | Constance des performances |
| **Retournement** | Détection | Joueur qui était dernier et qui a gagné |

### Export & Partage

- **Export PDF** : Génération d'un rapport PDF
- **Export CSV** : Données brutes pour analyse
- **Partage Image** : Screenshot stylisé pour réseaux sociaux

---

## 📋 Checklist Qualité

### Contenu
- [x] ✅ Résumé de partie (4 stats clés)
- [x] ✅ Stats intelligentes (4 insights)
- [x] ✅ Graphique distribution (barres)
- [x] ✅ Classement détaillé (liste riche)
- [x] ✅ Configuration partie (6 infos)

### Design
- [x] ✅ Couleurs cohérentes (DesignSystem)
- [x] ✅ Icônes pertinentes (SF Symbols)
- [x] ✅ Cartes avec ombres (modernCardStyle)
- [x] ✅ Spacing cohérent (Spacing.*)
- [x] ✅ Corner radius cohérent (CornerRadius.*)
- [x] ✅ Responsive (scroll si nécessaire)

### Logique
- [x] ✅ Respect lowestScoreIsBest
- [x] ✅ Tri correct des joueurs
- [x] ✅ Couleurs sémantiques (winner/eliminated)
- [x] ✅ Calculs corrects (moyenne, écart, coefficient)
- [x] ✅ Gestion des cas limites (1 joueur, scores égaux)

### UX
- [x] ✅ Navigation fluide (NavigationStack)
- [x] ✅ Bouton "Fermer" visible
- [x] ✅ Scrollable (contenu long)
- [x] ✅ Annotations claires (valeurs sur graphique)
- [x] ✅ Feedback visuel (couleurs, icônes)

---

## 🎯 Comparaison avec PlayerStatsView

| Aspect | PlayerStatsView | AdvancedStatsView |
|--------|-----------------|-------------------|
| **Scope** | Toutes les parties d'un joueur | Une partie spécifique |
| **Données** | PlayerProfile.stats | Game + Players |
| **Accès** | Paramètres → Profils | ResultsView (après pub si gratuit) |
| **Graphiques** | Victoires/Défaites/Éliminations | Distribution scores + Classement |
| **Stats** | Globales (taux victoire, scores min/max/moyen) | Intelligentes (compétitivité, écart, durée) |
| **Public** | Tous les utilisateurs | Pro ou après pub |

---

## ✅ Résumé

### Stats de Joueur (PlayerStatsView)
- ✅ Existe déjà
- ✅ Design moderne (screenshot fourni)
- ✅ Graphique en barres
- ✅ Stats globales

### Stats Avancées de Partie (AdvancedStatsView)
- ✅ **Nouvellement créée**
- ✅ **Statistiques intelligentes** :
  - Score moyen, écart max
  - Meilleur/pire joueur
  - Compétitivité (algorithme)
  - Durée estimée
- ✅ **Graphique en barres** (distribution)
- ✅ **Classement détaillé** avec design riche
- ✅ **Configuration de partie**
- ✅ **Design cohérent** avec DesignSystem
- ✅ **Logique solide** (respect lowestScoreIsBest, tri, couleurs)

### Améliorations Futures
- 📈 Graphique d'évolution (lignes, tour par tour)
- 🧮 Stats avancées (momentum, meilleur/pire tour, régularité)
- 📤 Export PDF/CSV, partage image

---

**Tout est prêt !** Les stats sont intelligentes, les graphiques sont propres, et le design est cohérent ! 🎉

Date : 08/03/2026  
Version : 5.0.1
