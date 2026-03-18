//
//  UnlockProgressManager.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  -----------------------------------------------------------------------------
//  UnlockProgressManager — Gestion de la progression de déblocage des packs
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Tracker le nombre de publicités visionnées par pack (0-10)
//    - Gérer les déblocages via publicités (10 pubs = 1 pack)
//    - Gérer les déblocages via streak (5 jours consécutifs)
//    - Persister toutes les progressions dans UserDefaults
//
//  ► Méthodes de déblocage par pack
//    1. Achat direct (0,99€) → géré par StoreManager
//    2. 10 publicités → géré ici (incrementAdCount + unlockWithAds)
//    3. 5 jours consécutifs → géré ici (unlockWithStreak)
//
//  ► Intégration
//    - Appelé par AdManager (après chaque pub regardée)
//    - Utilisé par PackUnlockSheet (affichage progression + déblocage)
//    - Communique avec StoreManager (ajouter pack débloqué)
//    - Lit DailyStreakManager (vérifier streak >= 5)
//  -----------------------------------------------------------------------------

import Foundation
import Combine

@MainActor
final class UnlockProgressManager: ObservableObject {
    
    static let shared = UnlockProgressManager()
    
    // MARK: - État observable
    
    /// Nombre de publicités regardées par pack (0-10)
    @Published private(set) var adsWatchedPerPack: [GamePack: Int] = [:]
    
    /// Packs déjà débloqués via streak (ne peut débloquer qu'une fois par pack)
    @Published private(set) var streakUnlockUsed: Set<GamePack> = []
    
    // MARK: - UserDefaults Keys
    
    private let adsWatchedPrefix = "unlock.progress."
    private let streakUnlockUsedKey = "unlock.progress.streakUnlockUsed"
    
    // MARK: - Constants
    
    private let adsRequiredForUnlock = 10 // 10 pubs = déblocage
    private let streakRequiredForUnlock = 5 // 5 jours = déblocage
    
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Publicités (Ads)
    
    /// Incrémente le compteur de publicités pour un pack.
    /// - Parameter pack: Le pack concerné
    /// - Note : Appelé par AdManager après chaque pub regardée
    func incrementAdCount(for pack: GamePack) {
        let currentCount = adsWatchedPerPack[pack, default: 0]
        
        // Ne pas dépasser 10
        guard currentCount < adsRequiredForUnlock else {
            #if DEBUG
            print("⚠️ [UnlockProgressManager] \(pack.displayName) déjà à 10 pubs")
            #endif
            return
        }
        
        adsWatchedPerPack[pack] = currentCount + 1
        persistToUserDefaults()
        
        #if DEBUG
        print("📺 [UnlockProgressManager] \(pack.displayName) : \(adsWatchedPerPack[pack]!)/10 pubs")
        #endif
        
        // Auto-déblocage si atteint 10
        if adsWatchedPerPack[pack] == adsRequiredForUnlock {
            #if DEBUG
            print("🎉 [UnlockProgressManager] \(pack.displayName) prêt à être débloqué via pubs !")
            #endif
        }
    }
    
    /// Vérifie si un pack peut être débloqué via publicités.
    /// - Parameter pack: Le pack à vérifier
    /// - Returns: true si >= 10 pubs regardées
    func canUnlockWithAds(_ pack: GamePack) -> Bool {
        let count = adsWatchedPerPack[pack, default: 0]
        return count >= adsRequiredForUnlock
    }
    
    /// Débloque un pack via publicités.
    /// - Parameter pack: Le pack à débloquer
    /// - Note : Reset le compteur après déblocage
    func unlockWithAds(_ pack: GamePack) {
        guard canUnlockWithAds(pack) else {
            #if DEBUG
            print("⚠️ [UnlockProgressManager] Impossible de débloquer \(pack.displayName) (pubs insuffisantes)")
            #endif
            return
        }
        
        // Débloque dans StoreManager
        StoreManager.shared.unlockPack(pack)
        
        // Reset compteur
        adsWatchedPerPack[pack] = 0
        persistToUserDefaults()
        
        #if DEBUG
        print("🎉 [UnlockProgressManager] \(pack.displayName) débloqué via 10 pubs !")
        #endif
    }
    
    // MARK: - Streak (5 jours consécutifs)
    
    /// Vérifie si un pack peut être débloqué via streak.
    /// - Parameter pack: Le pack à vérifier
    /// - Returns: true si streak >= 5 ET pas encore utilisé pour ce pack
    func canUnlockWithStreak(_ pack: GamePack) -> Bool {
        let streak = DailyStreakManager.shared.currentStreak
        let alreadyUsed = streakUnlockUsed.contains(pack)
        
        return streak >= streakRequiredForUnlock && !alreadyUsed
    }
    
    /// Débloque un pack via streak (5 jours consécutifs).
    /// - Parameter pack: Le pack à débloquer
    /// - Note : Marque le pack comme "utilisé" (ne peut débloquer qu'une fois)
    func unlockWithStreak(_ pack: GamePack) {
        guard canUnlockWithStreak(pack) else {
            #if DEBUG
            let streak = DailyStreakManager.shared.currentStreak
            if streak < streakRequiredForUnlock {
                print("⚠️ [UnlockProgressManager] Streak insuffisant : \(streak)/5 jours")
            } else {
                print("⚠️ [UnlockProgressManager] Streak déjà utilisé pour \(pack.displayName)")
            }
            #endif
            return
        }
        
        // Débloque dans StoreManager
        StoreManager.shared.unlockPack(pack)
        
        // Marque comme utilisé
        streakUnlockUsed.insert(pack)
        persistToUserDefaults()
        
        // Annule notifs streak (si plus de packs à débloquer)
        if shouldCancelStreakNotifications() {
            NotificationManager.shared.cancelStreakNotifications()
        }
        
        #if DEBUG
        print("🎉 [UnlockProgressManager] \(pack.displayName) débloqué via streak de 5 jours !")
        #endif
    }
    
    /// Détermine si on doit annuler les notifications streak.
    /// - Returns: true si tous les packs payants sont débloqués OU si Bundle acheté
    private func shouldCancelStreakNotifications() -> Bool {
        // Si Bundle acheté, tout est débloqué
        if StoreManager.shared.hasAllPacksBundle {
            return true
        }
        
        // Sinon, vérifie si tous les packs payants sont débloqués
        let paidPacks = GamePack.paidPacks
        let allUnlocked = paidPacks.allSatisfy { StoreManager.shared.isPackUnlocked($0) }
        
        return allUnlocked
    }
    
    // MARK: - Helpers UI (Textes formatés)
    
    /// Texte de progression pour les publicités (ex: "3/10 pubs 📺")
    func adProgressText(for pack: GamePack) -> String {
        let count = adsWatchedPerPack[pack, default: 0]
        return "\(count)/10 pubs 📺"
    }
    
    /// Texte de progression pour le streak (ex: "🔥 2/5 jours")
    func streakProgressText() -> String {
        return DailyStreakManager.shared.streakProgressText()
    }
    
    /// Texte de statut du joker (ex: "⭐ Joker disponible")
    func jokerStatusText() -> String {
        return DailyStreakManager.shared.jokerStatusText()
    }
    
    /// Pourcentage de progression pubs (pour progress bar)
    func adProgressPercentage(for pack: GamePack) -> Double {
        let count = adsWatchedPerPack[pack, default: 0]
        return Double(count) / Double(adsRequiredForUnlock)
    }
    
    /// Nombre de pubs restantes pour débloquer un pack
    func adsRemaining(for pack: GamePack) -> Int {
        let count = adsWatchedPerPack[pack, default: 0]
        return max(0, adsRequiredForUnlock - count)
    }
    
    /// Nombre de jours restants pour débloquer via streak
    func streakDaysRemaining() -> Int {
        let current = DailyStreakManager.shared.currentStreak
        return max(0, streakRequiredForUnlock - current)
    }
    
    // MARK: - Reset (Admin/Debug)
    
    /// Reset la progression d'un pack spécifique.
    func resetProgress(for pack: GamePack) {
        adsWatchedPerPack[pack] = 0
        streakUnlockUsed.remove(pack)
        persistToUserDefaults()
        
        #if DEBUG
        print("🔄 [UnlockProgressManager] Progression reset pour \(pack.displayName)")
        #endif
    }
    
    /// Reset toutes les progressions (debug/admin).
    func resetAllProgress() {
        adsWatchedPerPack.removeAll()
        streakUnlockUsed.removeAll()
        persistToUserDefaults()
        
        #if DEBUG
        print("🔄 [UnlockProgressManager] Toutes progressions reset")
        #endif
    }
    
    // MARK: - Persistance (UserDefaults)
    
    private func persistToUserDefaults() {
        let defaults = UserDefaults.standard
        
        // Sauvegarder compteurs pubs par pack
        for pack in GamePack.allCases {
            let key = adsWatchedPrefix + pack.rawValue + ".adsWatched"
            defaults.set(adsWatchedPerPack[pack, default: 0], forKey: key)
        }
        
        // Sauvegarder packs débloqués via streak
        let streakUnlockArray = Array(streakUnlockUsed).map { $0.rawValue }
        defaults.set(streakUnlockArray, forKey: streakUnlockUsedKey)
    }
    
    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        // Charger compteurs pubs par pack
        for pack in GamePack.allCases {
            let key = adsWatchedPrefix + pack.rawValue + ".adsWatched"
            let count = defaults.integer(forKey: key)
            if count > 0 {
                adsWatchedPerPack[pack] = count
            }
        }
        
        // Charger packs débloqués via streak
        if let streakUnlockArray = defaults.stringArray(forKey: streakUnlockUsedKey) {
            streakUnlockUsed = Set(streakUnlockArray.compactMap { GamePack(rawValue: $0) })
        }
        
        #if DEBUG
        print("📂 [UnlockProgressManager] Chargé : \(adsWatchedPerPack.count) packs avec progression")
        #endif
    }
    
    // MARK: - Debug
    
    #if DEBUG
    /// Affiche l'état complet de progression (debug).
    func printStatus() {
        print("📊 [UnlockProgressManager] État actuel :")
        
        for pack in GamePack.allCases where pack != .coreFree {
            let adsCount = adsWatchedPerPack[pack, default: 0]
            let streakUsed = streakUnlockUsed.contains(pack) ? "✅" : "❌"
            let unlocked = StoreManager.shared.isPackUnlocked(pack) ? "🔓" : "🔒"
            
            print("   \(unlocked) \(pack.displayName):")
            print("      - Pubs : \(adsCount)/10")
            print("      - Streak utilisé : \(streakUsed)")
        }
        
        print("   Streak actuel : \(DailyStreakManager.shared.currentStreak)/5 jours")
    }
    
    /// Simule des publicités regardées (debug).
    func simulateAdsWatched(for pack: GamePack, count: Int) {
        for _ in 0..<count {
            incrementAdCount(for: pack)
        }
    }
    #endif
}
