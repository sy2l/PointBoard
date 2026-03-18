# Intégration du SDK Google AdMob - PointBoard

Ce document décrit la démarche à suivre pour brancher le SDK Google AdMob au projet PointBoard et remplacer les stubs de `AdManager.swift` par de vraies publicités.

---

## 📋 Prérequis

1. **Compte AdMob** : Créez un compte sur [Google AdMob](https://admob.google.com/) et enregistrez votre application iOS.
2. **Blocs d'annonces** : Créez 3 blocs d'annonces dans votre compte AdMob :
   - **Récompensée** (Rewarded)
   - **Interstitielle** (Interstitial)
   - **Bannière** (Banner)
3. **IDs d'annonces** : Notez les IDs de chaque bloc d'annonces. Vous en aurez besoin pour l'étape 3.

---

## 🛠️ Étape 1 : Intégrer le SDK Google Mobile Ads

La méthode recommandée est d'utiliser **Swift Package Manager (SPM)**.

1. Dans Xcode, ouvrez votre projet PointBoard.
2. Allez dans `File` > `Add Packages...`
3. Dans la barre de recherche, collez l'URL du dépôt du SDK :
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
4. Cliquez sur `Add Package`.
5. Sélectionnez la target `UniversalScoreboard` et cliquez sur `Add Package`.

---

## ⚙️ Étape 2 : Configurer le `Info.plist`

Pour que le SDK AdMob fonctionne, vous devez ajouter des informations à votre fichier `Info.plist`.

1. Ouvrez `Info.plist`.
2. Ajoutez une nouvelle clé `GADApplicationIdentifier` de type `String`.
3. La valeur de cette clé est votre **ID d'application AdMob** (disponible dans votre compte AdMob).

   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
   ```

4. Ajoutez également la clé `SKAdNetworkItems` pour l'attribution des installations.

   ```xml
   <key>SKAdNetworkItems</key>
   <array>
     <dict>
       <key>SKAdNetworkIdentifier</key>
       <string>cstr6suwn9.skadnetwork</string>
     </dict>
   </array>
   ```
   (La liste complète des identifiants est disponible dans la documentation Google AdMob).

---

## 🚀 Étape 3 : Mettre à jour `AdManager.swift`

Maintenant, vous allez remplacer les stubs par le vrai code AdMob.

### 1. Importer le SDK

Ajoutez `import GoogleMobileAds` en haut du fichier `AdManager.swift`.

### 2. Initialiser le SDK

Dans la méthode `init()` de `AdManager`, décommentez la ligne d'initialisation :

```swift
private init() {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
}
```

### 3. Remplacer les IDs de test

Remplacez les IDs de test par vos propres IDs de blocs d'annonces :

```swift
private let rewardedAdUnitID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx" // Votre ID
private let interstitialAdUnitID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx" // Votre ID
private let bannerAdUnitID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx" // Votre ID
```

### 4. Implémenter les publicités récompensées

Modifiez la méthode `showRewardedAd` pour charger et afficher une vraie publicité :

```swift
func showRewardedAd(completion: @escaping (Bool) -> Void) {
    guard canShowAd() else {
        completion(true)
        return
    }
    
    isAdLoading = true
    
    GADRewardedAd.load(withAdUnitID: rewardedAdUnitID, request: GADRequest()) { [weak self] ad, error in
        self?.isAdLoading = false
        
        if let error = error {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        guard let ad = ad else {
            completion(false)
            return
        }
        
        ad.present(fromRootViewController: nil) { [weak self] in
            // La pub a été vue jusqu'au bout
            self?.lastAdShownDate = Date()
            ProTrialManager.shared.incrementRewardedAdViewCount()
            completion(true)
        }
    }
}
```

### 5. Implémenter les publicités interstitielles

Modifiez la méthode `showInterstitialAd` :

```swift
func showInterstitialAd() {
    guard canShowAd() else {
        return
    }
    
    isAdLoading = true
    
    GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest()) { [weak self] ad, error in
        self?.isAdLoading = false
        
        if let error = error {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            return
        }
        
        guard let ad = ad else {
            return
        }
        
        ad.present(fromRootViewController: nil)
        self?.lastAdShownDate = Date()
    }
}
```

### 6. Implémenter les bannières natives

Modifiez `AdBannerView.swift` pour afficher une vraie bannière :

```swift
import SwiftUI
import GoogleMobileAds

struct AdBannerView: View {
    @ObservedObject private var adManager = AdManager.shared
    
    var body: some View {
        if adManager.shouldShowBanner() {
            GADBannerViewController()
                .frame(height: 50)
        }
    }
}

// Helper pour intégrer la bannière AdMob dans SwiftUI
struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        bannerView.adUnitID = AdManager.shared.bannerAdUnitID
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        bannerView.load(GADRequest())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
```

---

## ✅ Étape 4 : Tester

1. Lancez l'application sur un **appareil physique** (les publicités ne s'affichent pas toujours sur le simulateur).
2. Vérifiez que les publicités s'affichent aux bons moments :
   - **Récompensées** : Ajout de joueur > 6, ajout de profil > 3, etc.
   - **Interstitielles** : Tous les 5 tours.
   - **Bannières** : Écrans Historique et Stats.
3. Vérifiez qu'**aucune publicité** ne s'affiche si vous êtes en mode Pro ou en essai.

---

## 🚀 Étape 5 : Lancement en Production

Avant de publier sur l'App Store, assurez-vous de :

- Remplacer les **IDs de test** par vos **vrais IDs AdMob**.
- Respecter les politiques de Google AdMob concernant l'affichage des publicités.

Félicitations, votre application est maintenant monétisée avec Google AdMob ! 🎉
