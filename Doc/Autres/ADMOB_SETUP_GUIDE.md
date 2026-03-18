# 🎯 Guide de Configuration AdMob pour PointBoard

## ✅ Problèmes Résolus

### 1. ❌ Problème : Tri des scores incorrect pour les jeux "lowestScoreIsBest"
**Symptôme** : Dans un jeu comme Skyjo (0→100 avec élimination), le joueur avec le PLUS de points était affiché en premier, alors que le but est d'avoir le MOINS de points possible.

**Solution appliquée** :
- ✅ Correction du tri dans `GameView.swift` (InProgressResultsView)
- ✅ Correction du tri dans `ResultsView.swift` (tri par survie ET par score)
- ✅ Prise en compte du paramètre `lowestScoreIsBest` partout

---

### 2. ❌ Problème : Les publicités AdMob ne s'affichent pas
**Causes possibles identifiées** :

1. **Configuration manquante dans Info.plist** ⚠️ CRITIQUE
2. Erreurs de chargement des annonces
3. IDs d'unités publicitaires incorrects

---

## 📋 Checklist de Configuration AdMob

### Étape 1 : Configuration du fichier Info.plist

Ouvrez votre fichier `Info.plist` et ajoutez ces clés :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Vos autres clés existantes... -->
    
    <!-- 🔑 ID de l'application AdMob (OBLIGATOIRE) -->
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-1225865230141398~XXXXXXXXXX</string>
    
    <!-- 📊 Active le support App Tracking Transparency -->
    <key>NSUserTrackingUsageDescription</key>
    <string>Nous utilisons les données pour personnaliser les publicités et améliorer votre expérience.</string>
    
    <!-- 🎯 SKAdNetwork identifiers pour l'attribution -->
    <key>SKAdNetworkItems</key>
    <array>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>cstr6suwn9.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>4fzdc2evr5.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>2u9pt9hc89.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>hs6bdukanm.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>v72qych5uu.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>ludvb6z3bs.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>c6k4g5qg8m.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>9rd848q2bz.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>4468km3ulz.skadnetwork</string>
        </dict>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>t38b2kh725.skadnetwork</string>
        </dict>
    </array>
    
    <!-- 🔧 Mode Ad Manager (optionnel) -->
    <key>GADIsAdManagerApp</key>
    <true/>
</dict>
</plist>
```

**⚠️ ATTENTION** : Remplacez `ca-app-pub-1225865230141398~XXXXXXXXXX` par votre **véritable ID d'application AdMob**.

---

### Étape 2 : Récupérer votre ID d'Application AdMob

1. Connectez-vous à [AdMob Console](https://apps.admob.com/)
2. Allez dans **Apps** → Sélectionnez votre application
3. Copiez l'**App ID** (format : `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)
4. Collez-le dans `Info.plist` pour la clé `GADApplicationIdentifier`

---

### Étape 3 : Vérifier les IDs d'Unités Publicitaires

Dans `AdManager.swift`, vérifiez vos IDs :

```swift
// IDs de PRODUCTION (à utiliser en release)
private let rewardedAdUnitID = "ca-app-pub-1225865230141398/7076087654"
private let interstitialAdUnitID = "ca-app-pub-1225865230141398/2861510474"
private let bannerAdUnitID = "ca-app-pub-1225865230141398/VOTRE_BANNER_ID"

// IDs de TEST (utilisez-les pendant le développement !)
// private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
// private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
```

**💡 Conseil** : Utilisez les IDs de test pendant le développement pour éviter les bannissements de votre compte AdMob.

---

### Étape 4 : Tester l'Intégration

1. **Activez les IDs de test** dans `AdManager.swift`
2. **Lancez l'application** en mode Debug
3. **Vérifiez la console Xcode** pour les logs :

```
🚀 [AppDelegate] Initializing Google Mobile Ads SDK...
✅ [AppDelegate] AdMob SDK initialized
   Adapter statuses:
   - com.google.mediation.admob.AdMobAdapter: 1
🔄 [AdManager] Loading rewarded ad...
✅ [AdManager] Rewarded loaded successfully
🔄 [AdManager] Loading interstitial ad...
✅ [AdManager] Interstitial loaded successfully
```

4. **Si vous voyez des erreurs** :
   - Code `0` : Pas de publicité disponible (normal en test)
   - Code `2` : Erreur réseau
   - Code `3` : ID invalide ⚠️ Vérifiez vos IDs

---

### Étape 5 : Tester les Publicités

#### Test Rewarded Ad (Vidéo Récompensée)
1. Allez dans **ResultsView**
2. Tapez sur "Voir les stats avancées"
3. Choisissez "Regarder une vidéo"
4. Une publicité devrait s'afficher

#### Test Interstitial Ad
1. Jouez quelques tours
2. Une publicité devrait s'afficher automatiquement tous les 5 tours

---

## 🔍 Diagnostic des Erreurs Courantes

### Erreur : "No fill" ou Code 0
**Cause** : Pas de publicité disponible pour le moment.
**Solution** : 
- Utilisez les IDs de test
- Attendez quelques minutes
- Vérifiez votre connexion Internet

### Erreur : "Invalid request" ou Code 3
**Cause** : ID d'unité publicitaire incorrect.
**Solution** : 
- Vérifiez que les IDs dans `AdManager.swift` sont corrects
- Vérifiez que l'ID d'application dans `Info.plist` est correct

### Erreur : "SDK not initialized"
**Cause** : Le SDK AdMob n'a pas été initialisé.
**Solution** : 
- Vérifiez que `GADApplicationIdentifier` est dans `Info.plist`
- Vérifiez que `MobileAds.shared.start()` est appelé dans `AppDelegate`

### Les pubs ne s'affichent jamais
**Causes possibles** :
1. Vous êtes en mode Pro → Les pubs sont désactivées (normal)
2. Le préchargement échoue silencieusement
3. `canShowAd()` retourne `false`

**Solutions** :
- Vérifiez `StoreManager.shared.isProUser` dans la console
- Vérifiez `ProTrialManager.shared.isTrialActive` 
- Ajoutez des logs pour tracer l'exécution

---

## 🚀 Passage en Production

Avant de publier sur l'App Store :

1. ✅ Remplacez tous les IDs de test par vos IDs de production
2. ✅ Vérifiez que `GADApplicationIdentifier` est correct dans `Info.plist`
3. ✅ Testez en mode Release (pas Debug)
4. ✅ Respectez le délai de quelques heures pour que AdMob active vos annonces
5. ✅ Vérifiez dans AdMob Console que vos unités publicitaires sont actives

---

## 📚 Ressources

- [Documentation officielle AdMob](https://developers.google.com/admob/ios/quick-start)
- [IDs de test AdMob](https://developers.google.com/admob/ios/test-ads)
- [SKAdNetwork IDs](https://developers.google.com/admob/ios/ios14#skadnetwork)
- [Troubleshooting AdMob](https://developers.google.com/admob/ios/troubleshooting)

---

## 📝 Notes Importantes

1. **Ne jamais** cliquer sur vos propres publicités en production
2. **Toujours** utiliser les IDs de test pendant le développement
3. Les publicités AdMob peuvent prendre jusqu'à **24-48h** pour être actives après la création
4. Vérifiez que votre application respecte les [politiques AdMob](https://support.google.com/admob/answer/6128543)

---

## ✅ Checklist Finale

- [ ] `GADApplicationIdentifier` ajouté dans `Info.plist`
- [ ] `NSUserTrackingUsageDescription` ajouté dans `Info.plist`
- [ ] `SKAdNetworkItems` ajoutés dans `Info.plist`
- [ ] IDs d'unités publicitaires vérifiés dans `AdManager.swift`
- [ ] Tests effectués avec les IDs de test
- [ ] Logs de débogage vérifiés dans la console
- [ ] Publicités testées en mode Debug
- [ ] IDs de production configurés pour la release
- [ ] Application testée en mode Release avant soumission

---

**Date de création** : 08/03/2026  
**Version** : 1.0  
**Auteur** : Support Technique PointBoard
