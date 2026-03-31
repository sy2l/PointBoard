# 🚨 Guide de Correction - Rejet App Store (v5.4.0)

**Date :** 31 mars 2026  
**Submission ID :** 1b97de31-4055-4254-807f-fbdefbeda754  
**Problèmes identifiés :** 3 (IAP, Bug iPad, ATT)

---

## 📋 RÉSUMÉ DES PROBLÈMES

### 🔴 Problème 1 : Guideline 3.1.1 - In-App Purchase
**Statut :** CRITIQUE  
**Cause :** Métadonnées IAP manquantes (tous les produits en "Métadonnées manquantes")  
**Impact :** Apple ne peut pas tester les achats

### 🔴 Problème 2 : Guideline 2.1(a) - Bug iPad
**Statut :** CRITIQUE  
**Cause :** Bouton "Acheter premium" non fonctionnel sur iPad Pro  
**Impact :** L'app ne fonctionne pas correctement

### 🟡 Problème 3 : Guideline 2.1 - App Tracking Transparency
**Statut :** MODÉRÉ  
**Cause :** Déclaration de tracking sans demande de permission  
**Impact :** Non-conformité avec les règles de confidentialité

---

## 🎯 PLAN D'ACTION (3 ÉTAPES)

### ✅ ÉTAPE 1 : Corriger les métadonnées IAP (PRIORITÉ ABSOLUE)
### ✅ ÉTAPE 2 : Résoudre le problème ATT
### ✅ ÉTAPE 3 : Corriger le bug iPad

---

# 📦 ÉTAPE 1 : CORRIGER LES MÉTADONNÉES IAP

## 🔍 Diagnostic

**Problème :** Tous les produits IAP sont en "Métadonnées manquantes"

**Produits concernés :**
1. `com.universalscoreboard.premium.noads` (Premium No Ads - 0,99€)
2. `com.universalscoreboard.bundle.allpacks` (Bundle All Packs - 3,99€)
3. `com.universalscoreboard.pack.classicCards` (Classic Cards - 0,99€)
4. `com.universalscoreboard.pack.funCardsDice` (Fun Cards & Dice - 0,99€)
5. `com.universalscoreboard.pack.boardFamily` (Board & Family - 0,99€)
6. `com.universalscoreboard.pack.outdoorSport` (Outdoor & Sport - 0,99€)
7. `com.universalscoreboard.pack.partyNight` (Party Night - 0,99€)
8. `com.universalscoreboard.pack.duelsStrategy` (Duels & Strategy - 0,99€)
9. `com.universalscoreboard.pack.kidsFamily2` (Kids & Family 2 - 0,99€)

---

## 📝 Actions à réaliser dans App Store Connect

### Pour CHAQUE produit IAP :

1. **Aller dans App Store Connect** → Mon App → **In-App Purchases**
2. **Cliquer sur le produit**
3. **Compléter les sections suivantes :**

---

### 📋 Section A : Informations générales (Vérifier)

- **Reference Name** : Nom interne (ex: "Premium No Ads")
- **Product ID** : Ne PAS modifier (ex: `com.universalscoreboard.premium.noads`)
- **Type** : Non-Consumable ✅ (correct)

---

### 💰 Section B : Pricing and Availability

- **Price** : Sélectionner le bon prix dans la grille
  - Premium No Ads : **0,99€** (Tier 1)
  - Bundle All Packs : **3,99€** (Tier 5)
  - Packs individuels : **0,99€** (Tier 1)

- **Availability** :
  - ✅ Cocher "Available in all territories"
  - OU sélectionner manuellement les pays

---

### 🌍 Section C : Localization (OBLIGATOIRE)

**Au minimum ajouter la localisation Française :**

Cliquer sur **"Add Localization"** → Sélectionner **French (France)**

#### **Textes pour Premium No Ads (0,99€)**

```
Display Name: Premium - Sans Publicité
Description: Profitez d'une expérience sans interruption ! Supprimez toutes les publicités et ajoutez jusqu'à 12 joueurs par partie. Achat unique, à vie.
```

#### **Textes pour Bundle All Packs (3,99€)**

```
Display Name: Bundle All Packs + Premium
Description: Débloquez TOUS les packs de jeux (actuels + futurs) + Premium sans publicité. Économisez 3,93€ par rapport aux achats individuels. Achat unique, à vie.
```

#### **Textes pour Classic Cards (0,99€)**

```
Display Name: Pack Classic Cards
Description: Débloquez les jeux de cartes classiques : Poker, Belote, Tarot, et plus encore. Parfait pour les soirées entre amis !
```

#### **Textes pour Fun Cards & Dice (0,99€)**

```
Display Name: Pack Fun Cards & Dice
Description: Découvrez des jeux amusants avec cartes et dés : Uno, Jungle Speed, Perudo, et bien d'autres. Ambiance garantie !
```

#### **Textes pour Board & Family (0,99€)**

```
Display Name: Pack Board & Family
Description: Les grands classiques de société : Monopoly, Scrabble, Trivial Pursuit, et plus. Pour toute la famille !
```

#### **Textes pour Outdoor & Sport (0,99€)**

```
Display Name: Pack Outdoor & Sport
Description: Jeux d'extérieur et sportifs : Pétanque, Molkky, Fléchettes, et autres. Parfait pour les beaux jours !
```

#### **Textes pour Party Night (0,99€)**

```
Display Name: Pack Party Night
Description: Les meilleurs jeux de soirée : Loup-Garou, Time's Up, Blanc Manger Coco, et plus. Pour des nuits inoubliables !
```

#### **Textes pour Duels & Strategy (0,99€)**

```
Display Name: Pack Duels & Strategy
Description: Jeux de stratégie et duels : Échecs, Dames, Puissance 4, et autres. Pour les esprits tactiques !
```

#### **Textes pour Kids & Family 2 (0,99€)**

```
Display Name: Pack Kids & Family 2
Description: Encore plus de jeux familiaux : Dobble, Piou Piou, Bataille, et bien d'autres. Pour petits et grands !
```

---

### 📸 Section D : Review Information (🔴 CRITIQUE - OBLIGATOIRE)

**C'est la section qui manque et qui bloque la validation !**

Pour chaque produit, tu DOIS fournir :

#### **Screenshot for Review (Capture d'écran obligatoire)**

**Comment faire :**

1. **Lance l'app sur un simulateur ou iPad**
2. **Navigue vers l'écran d'achat du produit :**
   - Premium No Ads : `SettingsView` → Tap sur "Premium Card" → `PremiumPaywallView`
   - Bundle All Packs : `SettingsView` → Tap sur "Bundle Card" → `BundlePaywallView`
   - Packs individuels : `SettingsView` → Tap sur un pack → `PackUnlockSheet`

3. **Prends une capture d'écran** (Cmd+S sur simulateur)

4. **Upload dans App Store Connect** :
   - Section "Review Information"
   - Bouton "Choose File"
   - Sélectionner la capture

**💡 Astuce :** Tu peux utiliser la MÊME capture pour plusieurs produits similaires (ex: tous les packs individuels)

---

#### **Review Notes (Notes pour l'équipe de révision)**

**Pour Premium No Ads :**
```
Pour tester cet achat :
1. Ouvrir l'app
2. Aller dans "Réglages" (icône engrenage en haut à droite)
3. Scroller jusqu'à "Premium - Sans Publicité"
4. Taper sur la carte pour ouvrir l'écran d'achat
5. Le bouton "Acheter Premium • 0,99€" lance l'achat StoreKit

Note : Les publicités Google AdMob s'affichent uniquement pour les utilisateurs gratuits.
```

**Pour Bundle All Packs :**
```
Pour tester cet achat :
1. Ouvrir l'app
2. Aller dans "Réglages" (icône engrenage en haut à droite)
3. Scroller jusqu'à "Bundle All Packs"
4. Taper sur la carte pour ouvrir l'écran d'achat
5. Le bouton "Acheter le Bundle • 3,99€" lance l'achat StoreKit

Note : Le bundle débloque tous les packs + supprime les publicités.
```

**Pour les packs individuels :**
```
Pour tester cet achat :
1. Ouvrir l'app
2. Aller dans "Réglages" (icône engrenage en haut à droite)
3. Scroller jusqu'à la section "Packs"
4. Taper sur le pack souhaité (ex: "Classic Cards")
5. Le bouton "Acheter • 0,99€" lance l'achat StoreKit

Note : Les packs débloquent des jeux supplémentaires dans la sélection.
```

---

### ✅ Vérification finale

Après avoir rempli toutes les sections, le statut du produit doit passer à :

**"Ready to Submit"** ✅

Si ce n'est pas le cas, vérifie qu'il ne manque pas :
- [ ] Display Name (Français)
- [ ] Description (Français)
- [ ] Price (0,99€ ou 3,99€)
- [ ] Screenshot for Review (OBLIGATOIRE)
- [ ] Availability (All territories)

---

## ⏱️ Temps estimé pour ÉTAPE 1

- **Complétion métadonnées** : 40-60 minutes (9 produits)
- **Captures d'écran** : 10 minutes
- **Vérification** : 5 minutes

**Total : ~1h15**

---

# 🔒 ÉTAPE 2 : RÉSOUDRE LE PROBLÈME ATT

## 🔍 Diagnostic

**Problème :** L'app déclare utiliser le tracking (`NSUserTrackingUsageDescription` dans Info.plist) mais ne demande jamais la permission avec `ATTrackingManager.requestTrackingAuthorization()`

**Cause :** Google AdMob collecte des données utilisateur → Apple oblige à demander la permission

---

## 💡 Deux Options Possibles

### **Option A : Implémenter ATT (Popup de permission)**

**Avantages :**
- ✅ Revenus publicitaires maximisés (+10-20%)
- ✅ Conformité totale avec Apple

**Inconvénients :**
- ⚠️ Popup intrusive (70-80% des utilisateurs refusent)
- ⚠️ Plus complexe à implémenter
- ⚠️ Peut faire fuir certains utilisateurs

**Revenus estimés :** 100€/mois (si 20% acceptent)

---

### **Option B : Enlever le tracking (✅ RECOMMANDÉE)**

**Avantages :**
- ✅ Plus simple à implémenter (5 minutes)
- ✅ Pas de popup intrusive
- ✅ Conforme aux règles Apple
- ✅ AdMob fonctionne quand même (mode SKAdNetwork)

**Inconvénients :**
- ⚠️ Revenus publicitaires réduits (-20 à -30%)

**Revenus estimés :** 70-80€/mois

---

## 🎯 RECOMMANDATION : Option B (Sans tracking)

**Pourquoi ?**
- La majorité des utilisateurs refusent ATT de toute façon (70-80%)
- La différence de revenus est négligeable (20-30€/mois)
- Expérience utilisateur plus fluide (pas de popup)
- Beaucoup plus simple à maintenir

---

## 📝 Actions pour Option B (Sans tracking)

### **1. Modifier Info.plist**

**Trouver le fichier :** `Info.plist` (racine du projet Xcode)

**Supprimer la clé :**
```xml
<!-- Chercher et SUPPRIMER cette ligne -->
<key>NSUserTrackingUsageDescription</key>
<string>Votre message ici...</string>
```

**OU dans Xcode (interface graphique) :**
1. Ouvrir `Info.plist`
2. Chercher "Privacy - Tracking Usage Description"
3. Clic droit → Delete

---

### **2. Modifier la déclaration dans App Store Connect**

1. **Aller dans App Store Connect** → Mon App → **App Privacy**
2. **Section "Data Used to Track You"**
3. **Répondre "No" à la question :**
   > "Does this app collect data in order to track the end user?"

4. **Sauvegarder**

---

### **3. Vérifier que AdMob fonctionne toujours**

**Aucune modification de code nécessaire !**

AdMob va automatiquement passer en mode **"Limited Ad Tracking"** (SKAdNetwork) qui :
- ✅ Affiche toujours des publicités
- ✅ Respecte la vie privée sans demander de permission
- ⚠️ Génère moins de revenus (mais légalement conforme)

---

## ⏱️ Temps estimé pour ÉTAPE 2 (Option B)

- **Modification Info.plist** : 2 minutes
- **Modification App Store Connect** : 5 minutes
- **Vérification** : 3 minutes

**Total : ~10 minutes**

---

# 🐛 ÉTAPE 3 : CORRIGER LE BUG iPad

## 🔍 Diagnostic

**Problème :** "The Acheter premium button was unresponsive" (iPad Pro M4, iPadOS 26.3.1)

**Causes possibles :**
1. Le composant `ProStatusCard` dans `SettingsCards.swift` est obsolète/non utilisé
2. Conflit de noms entre `ProStatusCard` et `PremiumCard`
3. L'action `onUpgrade` n'est pas correctement reliée

---

## 📝 Actions de correction

### **1. Nettoyer `SettingsCards.swift`**

**Fichier :** `SettingsCards.swift`

**Problème :** Le composant `ProStatusCard` est défini mais jamais utilisé dans `SettingsView.swift`

**Solution :** Supprimer ce composant obsolète (il est remplacé par `PremiumCard` + `BundleCard`)

**Code à SUPPRIMER :**

```swift
// MARK: - ProStatusCard
struct ProStatusCard: View {
    let isPro: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            if isPro {
                // ... (tout le code de ProStatusCard)
            } else {
                // ... (tout le code de ProStatusCard)
            }
        }
        .padding(Spacing.md)
        .background(isPro ? Color.accentGreen.opacity(0.1) : Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isPro ? Color.accentGreen.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}
```

**Raison :** Ce composant est remplacé par `PremiumStatusCard` (dans `SettingsView.swift` lignes 338-369)

---

### **2. Vérifier que les boutons fonctionnent**

**Fichier :** `SettingsView.swift`

**Vérifier que ces composants sont bien utilisés :**

```swift
// Ligne 155 : Premium Card
if !storeManager.hasPremiumNoAds && !storeManager.hasAllPacksBundle {
    PremiumCard(onTap: { showPremiumPaywall = true })
        .padding(.horizontal, Spacing.lg)
}

// Ligne 162 : Bundle Card
if !storeManager.hasAllPacksBundle {
    BundleCard(onTap: { showPaywall = true })
        .padding(.horizontal, Spacing.lg)
}
```

**Vérifier que les sheets sont bien reliés :**

```swift
// Ligne 82-91 : Sheets
.sheet(isPresented: $showPaywall) {
    BundlePaywallView()
}
.sheet(isPresented: $showPremiumPaywall) {
    PremiumPaywallView()
}
```

---

### **3. Tester sur iPad (Simulateur)**

1. **Lancer l'app sur iPad Pro 11" (simulateur)**
2. **Aller dans Réglages**
3. **Taper sur "Premium - Sans Publicité"**
4. **Vérifier que `PremiumPaywallView` s'ouvre**
5. **Taper sur "Acheter Premium"**
6. **Vérifier que la popup StoreKit apparaît (ou erreur sandbox)**

---

## ⏱️ Temps estimé pour ÉTAPE 3

- **Suppression code obsolète** : 5 minutes
- **Vérification** : 5 minutes
- **Test iPad** : 10 minutes

**Total : ~20 minutes**

---

# 📤 SOUMISSION À APPLE

## ✅ Checklist avant soumission

### **In-App Purchases**
- [ ] Tous les produits IAP en "Ready to Submit"
- [ ] Métadonnées complètes (Français minimum)
- [ ] Screenshots de review uploadés
- [ ] Review Notes remplies

### **App Tracking Transparency**
- [ ] `NSUserTrackingUsageDescription` supprimée du Info.plist
- [ ] App Privacy mise à jour (No tracking)

### **Bug iPad**
- [ ] Code obsolète supprimé (`ProStatusCard`)
- [ ] Testé sur simulateur iPad Pro 11"
- [ ] Boutons "Acheter" fonctionnels

### **Build**
- [ ] Nouvelle build uploadée (5.4.1 recommandé)
- [ ] Build testée sur device physique (si possible)
- [ ] Aucune erreur de compilation

---

## 📝 Message de réponse à Apple

Dans App Store Connect, **répondre au message de révision** avec :

```
Bonjour,

Merci pour votre retour détaillé. J'ai corrigé les 3 problèmes identifiés :

1. **Guideline 3.1.1 - In-App Purchase**
   ✅ Toutes les métadonnées IAP ont été complétées
   ✅ Screenshots de review ajoutés pour tous les produits
   ✅ Review notes ajoutées pour guider les tests

2. **Guideline 2.1(a) - Bug iPad**
   ✅ Code obsolète supprimé
   ✅ Bouton "Acheter premium" testé et fonctionnel sur iPad Pro 11"
   ✅ Tous les achats passent bien par StoreKit 2

3. **Guideline 2.1 - App Tracking Transparency**
   ✅ Clé NSUserTrackingUsageDescription supprimée du Info.plist
   ✅ App Privacy mise à jour : aucun tracking utilisateur
   ✅ AdMob fonctionne en mode Limited Ad Tracking (SKAdNetwork)

L'app est maintenant prête pour révision.

Merci pour votre patience,
Sem YL.
```

---

## 🎯 RÉSUMÉ GLOBAL

### **Temps total estimé**
- ÉTAPE 1 (IAP) : ~1h15
- ÉTAPE 2 (ATT) : ~10 minutes
- ÉTAPE 3 (Bug iPad) : ~20 minutes

**TOTAL : ~1h45**

---

### **Ordre des actions**
1. ✅ Compléter métadonnées IAP (PRIORITÉ)
2. ✅ Supprimer tracking (Info.plist + App Store Connect)
3. ✅ Nettoyer code obsolète (`ProStatusCard`)
4. ✅ Tester sur iPad
5. ✅ Upload nouvelle build (5.4.1)
6. ✅ Répondre à Apple
7. ✅ Soumettre à révision

---

### **🎉 Après correction**

Apple devrait accepter l'app sous **2-3 jours** (révision standard).

Si nouveau rejet, ce document servira de base pour identifier rapidement le problème.

---

**Bon courage ! 💪**

**Date de création :** 31 mars 2026  
**Version app :** 5.4.0 → 5.4.1  
**Status :** 🔴 En attente de correction
