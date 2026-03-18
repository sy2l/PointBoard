//
//  AdManager.swift
//  PointBoard
//
//  Created on 28/01/2026.
//  -----------------------------------------------------------------------------
//  AdManager — Gestion des publicités (AdMob)
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Centraliser la gestion des publicités (récompensées, interstitielles, bannières)
//    - Exposer des méthodes pour afficher les publicités
//    - Vérifier si l'utilisateur est Pro avant d'afficher une pub
//
//  ► Types (MVP / Fake):
//    - Récompensées : Déblocage de fonctionnalités
//    - Interstitielles : Tous les 5 tours de jeu
//    - Statique (Gate) : Accès à une action (ex: ajout joueur 7..12)
//    - Bannières natives : Écrans Historique et Stats (en bas)
//
//  Updated on 23/02/2026 — Add Static Gate Ad (for freemium gating)
//  Updated on 24/02/2026 — Real AdMob (rewarded/interstitial) + fallback Fake
//  -----------------------------------------------------------------------------

import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

@MainActor
final class AdManager: ObservableObject {

    static let shared = AdManager()

    // MARK: - État observable (UI)

    @Published private(set) var isAdLoading: Bool = false
    @Published private(set) var lastAdShownDate: Date? = nil

    @Published var showFakeAd: Bool = false
    @Published var fakeAdDuration: Int = 15
    @Published var fakeAdCompletion: (() -> Void)? = nil

    // MARK: - Configuration

    // ⚠️ IMPORTANT : Utilisez vos vrais IDs AdMob ici
    // Pour tester, vous pouvez utiliser les IDs de test d'AdMob :
    // Rewarded test ID : "ca-app-pub-3940256099942544/1712485313"
    // Interstitial test ID : "ca-app-pub-3940256099942544/4411468910"
    
    private let rewardedAdUnitID = "ca-app-pub-1225865230141398/7076087654" // Production
    private let interstitialAdUnitID = "ca-app-pub-1225865230141398/2861510474" // Production
    private let bannerAdUnitID = "ca-app-pub-1225865230141398/VOTRE_BANNER_ID" // À configurer
    
    // IDs de test (décommenter pour tester)
    // private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    // private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    // MARK: - AdMob instances

    private var rewardedAd: RewardedAd? = nil
    private var interstitialAd: InterstitialAd? = nil

    private init() { }

    // MARK: - Vérification Pro

    private func canShowAd() -> Bool {
        // Ne pas afficher de pub si l'utilisateur est Pro ou en essai Pro
        return !StoreManager.shared.isProUser && !ProTrialManager.shared.isTrialActive
    }

    // MARK: - Préchargement (à appeler au launch + après chaque affichage)

    func preloadAds() {
        guard canShowAd() else { return }
        loadRewarded()
        loadInterstitial()
    }

    private func loadRewarded() {
        guard rewardedAd == nil else { return }

        isAdLoading = true
        let request = Request()

        #if DEBUG
        print("🔄 [AdManager] Loading rewarded ad...")
        #endif

        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            Task { @MainActor in
                self.isAdLoading = false

                if let error {
                    #if DEBUG
                    print("❌ [AdManager] Rewarded load error:", error.localizedDescription)
                    print("   Code:", (error as NSError).code)
                    print("   Domain:", (error as NSError).domain)
                    #endif
                    self.rewardedAd = nil
                    return
                }

                self.rewardedAd = ad
                #if DEBUG
                print("✅ [AdManager] Rewarded loaded successfully")
                #endif
            }
        }
    }

    private func loadInterstitial() {
        guard interstitialAd == nil else { return }

        isAdLoading = true
        let request = Request()

        #if DEBUG
        print("🔄 [AdManager] Loading interstitial ad...")
        #endif

        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            Task { @MainActor in
                self.isAdLoading = false

                if let error {
                    #if DEBUG
                    print("❌ [AdManager] Interstitial load error:", error.localizedDescription)
                    print("   Code:", (error as NSError).code)
                    print("   Domain:", (error as NSError).domain)
                    #endif
                    self.interstitialAd = nil
                    return
                }

                self.interstitialAd = ad
                #if DEBUG
                print("✅ [AdManager] Interstitial loaded successfully")
                #endif
            }
        }
    }

    // MARK: - Publicités Récompensées

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard canShowAd() else {
            completion(true)
            return
        }

        // MARK: - Real rewarded ad
        if let ad = rewardedAd,
           let rootVC = UIApplication.shared.topMostViewController() {

            rewardedAd = nil // on consomme, on reload après
            ad.present(from: rootVC) { [weak self] in
                guard let self else { return }

                Task { @MainActor in
                    self.lastAdShownDate = Date()
                    ProTrialManager.shared.incrementRewardedAdViewCount()
                    completion(true)
                    self.loadRewarded()
                }
            }
            return
        }

        // MARK: - Fallback Fake rewarded ad
        fakeAdDuration = 15
        fakeAdCompletion = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.lastAdShownDate = Date()
                ProTrialManager.shared.incrementRewardedAdViewCount()
                completion(true)
                self.loadRewarded()
            }
        }
        showFakeAd = true
        loadRewarded()
    }

    // MARK: - Publicités Interstitielles

    func showInterstitialAd() {
        guard canShowAd() else { return }

        // MARK: - Real interstitial ad
        if let ad = interstitialAd,
           let rootVC = UIApplication.shared.topMostViewController() {

            interstitialAd = nil // on consomme, on reload après
            ad.present(from: rootVC)

            Task { @MainActor in
                self.lastAdShownDate = Date()
                self.loadInterstitial()
            }
            return
        }

        // MARK: - Fallback Fake interstitial ad
        fakeAdDuration = 15
        fakeAdCompletion = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.lastAdShownDate = Date()
                self.loadInterstitial()
            }
        }
        showFakeAd = true
        loadInterstitial()
    }

    // MARK: - Publicités Statique (Gate)

    /// Pub "statique" pour autoriser une action (ex: ajout joueur 7..12).
    /// - Note: En Pro / essai Pro => pas de pub, on exécute direct.
    func showStaticGateAd(duration: Int = 15, onComplete: @escaping () -> Void) {
        guard canShowAd() else {
            onComplete()
            return
        }

        // MARK: - Prefer rewarded if available
        showRewardedAd { success in
            if success { onComplete() }
        }
    }

    // MARK: - Bannières Natives

    func shouldShowBanner() -> Bool {
        return canShowAd()
    }

    func loadBannerAd() {
        guard canShowAd() else { return }
        // La bannière se gère via un View (UIViewRepresentable) plutôt qu’ici.
        _ = bannerAdUnitID
    }
}

// MARK: - UIKit helper (top VC)
private extension UIApplication {
    func topMostViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
