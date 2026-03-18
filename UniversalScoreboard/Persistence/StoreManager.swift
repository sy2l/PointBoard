//
//  StoreManager.swift
//  PointBoard
//
//  Created by sy2l on 06/01/2026.
//  Updated by sy2l on 06/01/2026 — V4.0.4 (Option A + garde-fou Pro/achats individuels)
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
    @Published private(set) var unlockedPacks: Set<GamePack> = []

    // MARK: - IDs StoreKit

    private let bundleProductID: String = "com.universalscoreboard.bundle.allpacks"

    private init() {
        loadEntitlements()
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
    
    // MARK: - Déblocage manuel
    
    func unlockPack(_ pack: GamePack) {
        guard pack != .coreFree else { return }
        unlockedPacks.insert(pack)
        persistEntitlements()
        
        #if DEBUG
        print("✅ [StoreManager] Pack débloqué : \(pack.displayName)")
        #endif
    }

    // MARK: - Achats

    func purchasePack(_ pack: GamePack) async {
        guard let productID = pack.productID else { return }
        
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return }
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                unlockedPacks.insert(pack)
                persistEntitlements()
                
                #if DEBUG
                print("✅ [StoreManager] Pack acheté : \(pack.displayName)")
                #endif

            default:
                break
            }
        } catch {
            print("❌ [StoreManager] purchasePack error: \(error)")
        }
    }

    func purchaseBundle() async {
        do {
            let products = try await Product.products(for: [bundleProductID])
            guard let product = products.first else { return }
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                hasAllPacksBundle = true
                persistEntitlements()
                NotificationManager.shared.cancelAllNotifications()
                
                #if DEBUG
                print("✅ [StoreManager] Bundle acheté !")
                #endif

            default:
                break
            }
        } catch {
            print("❌ [StoreManager] purchaseBundle error: \(error)")
        }
    }

    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try Self.checkVerified(result)

                if transaction.productID == bundleProductID {
                    hasAllPacksBundle = true
                }

                if let pack = GamePack.allCases.first(where: { $0.productID == transaction.productID }) {
                    unlockedPacks.insert(pack)
                }
            }

            persistEntitlements()
            
            if hasAllPacksBundle {
                NotificationManager.shared.cancelAllNotifications()
            }
            
            #if DEBUG
            print("✅ [StoreManager] Achats restaurés")
            #endif
        } catch {
            print("❌ [StoreManager] restorePurchases error: \(error)")
        }
    }

    // MARK: - Persistance

    private func persistEntitlements() {
        let defaults = UserDefaults.standard
        defaults.set(hasAllPacksBundle, forKey: "store.hasAllPacksBundle")
        defaults.set(unlockedPacks.map(\.rawValue), forKey: "store.unlockedPacks")
    }

    func loadEntitlements() {
        let defaults = UserDefaults.standard
        hasAllPacksBundle = defaults.bool(forKey: "store.hasAllPacksBundle")
        let packIDs = defaults.stringArray(forKey: "store.unlockedPacks") ?? []
        unlockedPacks = Set(packIDs.compactMap { GamePack(rawValue: $0) })
        
        #if DEBUG
        print("📂 [StoreManager] Chargé : Bundle=\(hasAllPacksBundle), Packs=\(unlockedPacks.count)")
        #endif
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

