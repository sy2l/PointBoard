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

    @Published private(set) var isProUser: Bool = false
    @Published private(set) var unlockedPacks: Set<GamePack> = []

    // MARK: - IDs StoreKit

    /// Produit "Pro" (débloque uniquement les packs de base).
    private let proProductID: String = "com.universalscoreboard.pro.basepacks"

    // MARK: - Scope Pro (4 packs de base)

    /// Liste figée : Pro ne débloque pas les packs ajoutés ultérieurement.
    private let proIncludedPacks: Set<GamePack> = [
        .classicCards,
        .funCardsDice,
        .boardFamily,
        .outdoorSport
    ]

    private init() {
        // Garde-fou : charge l’état au démarrage (évite l’oubli ailleurs).
        loadEntitlements()
    }

    // MARK: - Règle de déblocage PACK (Source de vérité)

    /// Détermine si un pack est accessible pour l’utilisateur courant.
    /// - Important : c’est LA règle utilisée partout.
    func isPackUnlocked(_ pack: GamePack) -> Bool {
        // 1) Le pack gratuit est toujours disponible.
        if pack == .coreFree { return true }

        // 2) Achat individuel : toujours prioritaire (même si Pro).
        if unlockedPacks.contains(pack) { return true }

        // 3) Si PRO : déverrouille uniquement les 4 packs de base.
        if isProUser {
            return proIncludedPacks.contains(pack)
        }

        return false
    }

    // MARK: - Règle de déblocage PRESET (Option A)

    /// Détermine si un preset (jeu) est accessible.
    /// - Rôle : helper UI (SetupView) pour afficher 🔒 / autoriser la sélection.
    /// - Implémentation : preset -> pack -> isPackUnlocked(pack)
    func isPresetUnlocked(_ presetID: PresetID) -> Bool {
        let pack = GamePack.packContaining(presetID)
        return isPackUnlocked(pack)
    }

    // MARK: - Achat pack individuel

    /// Achète un pack individuel via StoreKit 2.
    /// - Ne fait rien si productID est nil (pack gratuit).
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

            default:
                break
            }
        } catch {
            print("❌ purchasePack error: \(error)")
        }
    }

    // MARK: - Achat Pro

    /// Achète le produit Pro via StoreKit 2.
    /// - Après achat : isProUser = true (mais ne débloque que les 4 packs de base via isPackUnlocked).
    func purchasePro() async {
        do {
            let products = try await Product.products(for: [proProductID])
            guard let product = products.first else { return }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()

                isProUser = true
                persistEntitlements()

            default:
                break
            }
        } catch {
            print("❌ purchasePro error: \(error)")
        }
    }

    // MARK: - Restore

    /// Restaure les achats (utile après changement d'appareil / réinstallation).
    /// - Scanne currentEntitlements et reconstruit l’état (Pro + packs).
    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try Self.checkVerified(result)

                if transaction.productID == proProductID {
                    isProUser = true
                }

                if let pack = GamePack.allCases.first(where: { $0.productID == transaction.productID }) {
                    unlockedPacks.insert(pack)
                }
            }

            persistEntitlements()
        } catch {
            print("❌ restorePurchases error: \(error)")
        }
    }

    // MARK: - Persistance locale

    /// Sauvegarde l’état courant en local (UserDefaults).
    private func persistEntitlements() {
        let defaults = UserDefaults.standard
        defaults.set(isProUser, forKey: "store.isProUser")
        defaults.set(unlockedPacks.map(\.rawValue), forKey: "store.unlockedPacks")
    }

    /// Recharge l’état local au lancement.
    func loadEntitlements() {
        let defaults = UserDefaults.standard
        isProUser = defaults.bool(forKey: "store.isProUser")

        let packIDs = defaults.stringArray(forKey: "store.unlockedPacks") ?? []
        unlockedPacks = Set(packIDs.compactMap { GamePack(rawValue: $0) })
    }

    // MARK: - Vérification StoreKit

    /// Vérifie la transaction (StoreKit 2) et rejette les résultats non vérifiés.
    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notEntitled
        case .verified(let safe):
            return safe
        }
    }
}
