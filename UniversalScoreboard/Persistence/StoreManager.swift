//
//  StoreManager.swift
//  PointBoard
//
//  Created by sy2l on 06/01/2026.
//  Updated by sy2l on 06/01/2026 — V4.0.4 (Option A + garde-fou Pro/achats individuels)
//  Updated by sy2l on 08/04/2026 — V5.4.3 (Chargement produits + Gestion erreurs + Production ready)
//  -----------------------------------------------------------------------------
//  StoreManager — Gestion des achats (StoreKit 2)
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Centraliser les achats IAP (packs individuels + produit PRO).
//    - Exposer un état observable à l’UI (isProUser, unlockedPacks).
//    - Fournir des helpers de déverrouillage :
//        - isPackUnlocked(_:)    -> règle pack-level (source de vérité)
//        - isPresetUnlocked(_:)  -> règle preset-level (utilisée par SetupView)
//
//  ► Règles business (Pro = packs de base seulement)
//    - coreFree : toujours accessible.
//    - Achat pack individuel -> déverrouille ce pack (même si Pro).
//    - Achat Pro -> déverrouille UNIQUEMENT : classicCards, funCardsDice, boardFamily, outdoorSport.
//    - Les packs ajoutés plus tard restent vendus séparément (même si Pro).
//
//  ► Garde-fou important
//    - Un utilisateur Pro peut quand même acheter un pack hors bundle (ex: partyNight).
//      Donc : "achat individuel" doit être prioritaire sur "scope Pro".
//
//  ► Notes maintenance
//    - isPresetUnlocked(_:) ne contient AUCUNE logique business complexe :
//      il mappe preset -> pack puis délègue à isPackUnlocked(_:) (source de vérité).
//    - Persistance locale simple (UserDefaults) pour V1.
//  -----------------------------------------------------------------------------

import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {

    static let shared = StoreManager()

    // MARK: - État observable (UI)

    @Published private(set) var hasAllPacksBundle: Bool = false
    @Published private(set) var hasPremiumNoAds: Bool = false
    @Published private(set) var unlockedPacks: Set<GamePack> = []
    
    // MARK: - État de chargement (Option C - Fix iPad)
    
    @Published private(set) var isLoadingProducts: Bool = true
    @Published private(set) var productsLoadError: String? = nil
    @Published private(set) var availableProducts: [Product] = []
    @Published var lastPurchaseError: String? = nil

    // MARK: - IDs StoreKit

    private let bundleProductID: String = "com.universalscoreboard.bundle.allpacks"
    private let premiumProductID: String = "com.universalscoreboard.premium.noads"
    
    private var allProductIDs: [String] {
        var ids = [bundleProductID, premiumProductID]
        ids.append(contentsOf: GamePack.paidPacks.compactMap { $0.productID })
        return ids
    }

    private init() {
        loadEntitlements()
        
        // Charger les produits au démarrage (Option C)
        Task {
            await loadProducts()
        }
    }
    
    // MARK: - Chargement des produits (Option C)
    
    func loadProducts() async {
        isLoadingProducts = true
        productsLoadError = nil
        
        do {
            let products = try await Product.products(for: allProductIDs)
            availableProducts = products
            isLoadingProducts = false
            
        } catch {
            isLoadingProducts = false
            productsLoadError = "Impossible de charger les produits. Vérifiez votre connexion Internet."
        }
    }

    // MARK: - Règle de déblocage PACK

    func isPackUnlocked(_ pack: GamePack) -> Bool {
        if pack == .coreFree { return true }
        if hasAllPacksBundle { return true }
        if unlockedPacks.contains(pack) { return true }
        return false
    }

    func isPresetUnlocked(_ presetID: PresetID) -> Bool {
        let pack = GamePack.packContaining(presetID)
        return isPackUnlocked(pack)
    }
    
    // MARK: - Premium Helpers
    
    /// Vérifie si l'utilisateur a un accès "premium" (Premium No Ads OU Bundle)
    var isPremiumUser: Bool {
        return hasPremiumNoAds || hasAllPacksBundle
    }
    
    /// Vérifie si les publicités doivent être affichées
    var shouldShowAds: Bool {
        return !isPremiumUser
    }
    
    /// Nombre maximum de joueurs autorisés
    var maxPlayersAllowed: Int {
        return isPremiumUser ? 12 : 6
    }
    
    // MARK: - Déblocage manuel
    
    func unlockPack(_ pack: GamePack) {
        guard pack != .coreFree else { return }
        unlockedPacks.insert(pack)
        persistEntitlements()
    }

    // MARK: - Achats

    func purchasePack(_ pack: GamePack) async {
        guard let productID = pack.productID else {
            lastPurchaseError = "Produit invalide"
            return
        }
        
        if isLoadingProducts {
            lastPurchaseError = "Chargement des produits en cours..."
            return
        }
        
        guard let product = availableProducts.first(where: { $0.id == productID }) else {
            lastPurchaseError = "Produit \(pack.displayName) non disponible. Vérifiez votre connexion."
            return
        }
        
        lastPurchaseError = nil
        
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                unlockedPacks.insert(pack)
                persistEntitlements()

            case .userCancelled:
                lastPurchaseError = nil
                
            case .pending:
                lastPurchaseError = "Achat en attente d'approbation"
                
            @unknown default:
                lastPurchaseError = "Erreur inconnue lors de l'achat"
            }
        } catch {
            lastPurchaseError = "Erreur : \(error.localizedDescription)"
        }
    }

    func purchaseBundle() async {
        if isLoadingProducts {
            lastPurchaseError = "Chargement des produits en cours..."
            return
        }
        
        guard let product = availableProducts.first(where: { $0.id == bundleProductID }) else {
            lastPurchaseError = "Bundle non disponible. Vérifiez votre connexion."
            return
        }
        
        lastPurchaseError = nil
        
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                hasAllPacksBundle = true
                persistEntitlements()

            case .userCancelled:
                lastPurchaseError = nil
                
            case .pending:
                lastPurchaseError = "Achat en attente d'approbation"
                
            @unknown default:
                lastPurchaseError = "Erreur inconnue lors de l'achat"
            }
        } catch {
            lastPurchaseError = "Erreur : \(error.localizedDescription)"
        }
    }
    
    func purchasePremium() async {
        if isLoadingProducts {
            lastPurchaseError = "Chargement des produits en cours..."
            return
        }
        
        guard let product = availableProducts.first(where: { $0.id == premiumProductID }) else {
            lastPurchaseError = "Premium non disponible. Vérifiez votre connexion."
            return
        }
        
        lastPurchaseError = nil
        
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                hasPremiumNoAds = true
                persistEntitlements()

            case .userCancelled:
                lastPurchaseError = nil
                
            case .pending:
                lastPurchaseError = "Achat en attente d'approbation"
                
            @unknown default:
                lastPurchaseError = "Erreur inconnue lors de l'achat"
            }
        } catch {
            lastPurchaseError = "Erreur : \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try Self.checkVerified(result)

                if transaction.productID == bundleProductID {
                    hasAllPacksBundle = true
                }
                
                if transaction.productID == premiumProductID {
                    hasPremiumNoAds = true
                }

                if let pack = GamePack.allCases.first(where: { $0.productID == transaction.productID }) {
                    unlockedPacks.insert(pack)
                }
            }

            persistEntitlements()
        } catch {
            // Erreur silencieuse pour ne pas perturber l'utilisateur
        }
    }

    // MARK: - Persistance

    private func persistEntitlements() {
        let defaults = UserDefaults.standard
        defaults.set(hasAllPacksBundle, forKey: "store.hasAllPacksBundle")
        defaults.set(hasPremiumNoAds, forKey: "store.hasPremiumNoAds")
        defaults.set(unlockedPacks.map(\.rawValue), forKey: "store.unlockedPacks")
    }

    func loadEntitlements() {
        let defaults = UserDefaults.standard
        hasAllPacksBundle = defaults.bool(forKey: "store.hasAllPacksBundle")
        hasPremiumNoAds = defaults.bool(forKey: "store.hasPremiumNoAds")
        let packIDs = defaults.stringArray(forKey: "store.unlockedPacks") ?? []
        unlockedPacks = Set(packIDs.compactMap { GamePack(rawValue: $0) })
    }

    // MARK: - Vérification

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notEntitled
        case .verified(let safe):
            return safe
        }
    }
}

