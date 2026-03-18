//
//  ProTrialManager.swift
//  PointBoard
//
//  Created on 28/01/2026.
//  -----------------------------------------------------------------------------
//  ProTrialManager — Gestion des essais Pro et déblocages temporaires
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Gérer l'activation et la durée des essais Pro (7 jours après 5 parties)
//    - Gérer les déblocages temporaires (1h après 3 pubs récompensées)
//    - Gérer le système de parrainage (codes uniques, validation)
//    - Exposer un état observable pour l'UI (isTrialActive, trialEndDate)
//
//  ► Règles business
//    - Essai Pro : 7 jours après 5 parties jouées (une seule fois)
//    - Déblocage temporaire : 1h après 3 pubs récompensées (renouvelable)
//    - Parrainage : 1 mois après 3 amis parrainés (cumulable)
//
//  ► Persistance
//    - UserDefaults pour stocker les états (trialEndDate, rewardedAdCount, etc.)
//    - Vérification à chaque lancement de l'app
//  -----------------------------------------------------------------------------

import Foundation
import SwiftUI

@MainActor
final class ProTrialManager: ObservableObject {
    
    static let shared = ProTrialManager()
    
    // MARK: - État observable (UI)
    
    @Published private(set) var isTrialActive: Bool = false
    @Published private(set) var trialEndDate: Date? = nil
    @Published private(set) var referralCode: String = ""
    
    // MARK: - Clés UserDefaults
    
    private let trialEndDateKey = "proTrialEndDate"
    private let hasUsedTrialKey = "hasUsedProTrial"
    private let gamesPlayedCountKey = "gamesPlayedCount"
    private let rewardedAdCountKey = "rewardedAdViewCount"
    private let referralCodeKey = "userReferralCode"
    private let referredByCountKey = "referredByCount"
    
    // MARK: - Configuration
    
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 jours
    private let temporaryProDuration: TimeInterval = 60 * 60 // 1 heure
    private let referralProDuration: TimeInterval = 30 * 24 * 60 * 60 // 30 jours
    
    private init() {
        loadState()
        generateReferralCodeIfNeeded()
    }
    
    // MARK: - Chargement de l'état
    
    private func loadState() {
        // Charger la date de fin d'essai
        if let endDate = UserDefaults.standard.object(forKey: trialEndDateKey) as? Date {
            trialEndDate = endDate
            isTrialActive = endDate > Date()
        } else {
            isTrialActive = false
        }
        
        // Charger le code de parrainage
        if let code = UserDefaults.standard.string(forKey: referralCodeKey) {
            referralCode = code
        }
    }
    
    // MARK: - Essai Pro Gratuit (7 jours après 5 parties)
    
    /// Incrémente le compteur de parties jouées et vérifie si l'essai doit être proposé
    func incrementGamesPlayedCount() {
        let count = UserDefaults.standard.integer(forKey: gamesPlayedCountKey) + 1
        UserDefaults.standard.set(count, forKey: gamesPlayedCountKey)
        
        // Vérifier si l'essai doit être proposé
        checkAndOfferProTrial()
    }
    
    /// Vérifie si l'utilisateur a joué 5 parties et n'a pas encore utilisé l'essai
    func checkAndOfferProTrial() {
        let gamesPlayed = UserDefaults.standard.integer(forKey: gamesPlayedCountKey)
        let hasUsedTrial = UserDefaults.standard.bool(forKey: hasUsedTrialKey)
        
        if gamesPlayed >= 5 && !hasUsedTrial && !StoreManager.shared.isProUser {
            // Activer l'essai automatiquement
            activateProTrial(duration: trialDuration)
            UserDefaults.standard.set(true, forKey: hasUsedTrialKey)
            
            print("[ProTrialManager] Essai Pro de 7 jours activé !")
        }
    }
    
    // MARK: - Déblocage Temporaire (1h après 3 pubs récompensées)
    
    /// Incrémente le compteur de pubs récompensées vues
    func incrementRewardedAdViewCount() {
        let count = UserDefaults.standard.integer(forKey: rewardedAdCountKey) + 1
        UserDefaults.standard.set(count, forKey: rewardedAdCountKey)
        
        // Vérifier si le déblocage temporaire doit être proposé
        checkAndOfferTemporaryPro()
    }
    
    /// Vérifie si l'utilisateur a vu 3 pubs récompensées
    func checkAndOfferTemporaryPro() {
        let adCount = UserDefaults.standard.integer(forKey: rewardedAdCountKey)
        
        if adCount >= 3 && !StoreManager.shared.isProUser && !isTrialActive {
            // Activer le déblocage temporaire
            activateProTrial(duration: temporaryProDuration)
            
            // Réinitialiser le compteur
            UserDefaults.standard.set(0, forKey: rewardedAdCountKey)
            
            print("[ProTrialManager] Déblocage temporaire de 1h activé !")
        }
    }
    
    // MARK: - Parrainage (1 mois après 3 amis parrainés)
    
    /// Génère un code de parrainage unique si nécessaire
    private func generateReferralCodeIfNeeded() {
        if referralCode.isEmpty {
            referralCode = generateReferralCode()
            UserDefaults.standard.set(referralCode, forKey: referralCodeKey)
        }
    }
    
    /// Génère un code de parrainage unique (6 caractères alphanumériques)
    func generateReferralCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    /// Valide un code de parrainage saisi par l'utilisateur
    func validateReferralCode(_ code: String) -> Bool {
        // TODO: Implémenter la validation via un backend (Firebase, etc.)
        // Pour l'instant, simuler une validation réussie
        
        guard code != referralCode else {
            print("[ProTrialManager] Erreur : impossible d'utiliser son propre code")
            return false
        }
        
        // Incrémenter le compteur de parrainages pour le parrain (via backend)
        print("[ProTrialManager] Code de parrainage validé : \(code)")
        
        // Activer 1 mois de Pro pour le filleul
        activateProTrial(duration: referralProDuration)
        
        return true
    }
    
    /// Vérifie si l'utilisateur a parrainé 3 amis
    func checkReferralReward() {
        let referredCount = UserDefaults.standard.integer(forKey: referredByCountKey)
        
        if referredCount >= 3 {
            // Activer 1 mois de Pro
            activateProTrial(duration: referralProDuration)
            
            // Réinitialiser le compteur
            UserDefaults.standard.set(0, forKey: referredByCountKey)
            
            print("[ProTrialManager] Récompense parrainage : 1 mois de Pro activé !")
        }
    }
    
    // MARK: - Activation d'un essai Pro
    
    /// Active un essai Pro pour une durée donnée
    func activateProTrial(duration: TimeInterval) {
        let endDate = Date().addingTimeInterval(duration)
        trialEndDate = endDate
        isTrialActive = true
        
        UserDefaults.standard.set(endDate, forKey: trialEndDateKey)
        
        print("[ProTrialManager] Essai Pro activé jusqu'au \(endDate)")
    }
    
    /// Vérifie si l'essai est toujours actif
    func checkTrialExpiration() {
        if let endDate = trialEndDate, endDate < Date() {
            isTrialActive = false
            trialEndDate = nil
            UserDefaults.standard.removeObject(forKey: trialEndDateKey)
            
            print("[ProTrialManager] Essai Pro expiré")
        }
    }
}
