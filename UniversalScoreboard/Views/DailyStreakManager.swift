//
//  DailyStreakManager.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  -----------------------------------------------------------------------------
//  DailyStreakManager — Gestion du streak quotidien (jours consécutifs)
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Tracker les ouvertures consécutives de l'app (streak)
//    - Gérer le système de "joker" (1 tous les 10 jours)
//    - Déclencher notification spéciale si streak = 4
//    - Persister toutes les données dans UserDefaults
//
//  ► Logique Streak
//    - Ouverture même jour : rien (déjà compté)
//    - Ouverture jour suivant : currentStreak += 1
//    - Ouverture avec gap > 1 jour : reset streak à 1
//    - Joker disponible tous les 10 jours (rattrape 1 jour manqué)
//
//  ► Intégration
//    - Appelé au launch de l'app (checkAndUpdateStreak)
//    - Utilisé par UnlockProgressManager (vérifier streak >= 5)
//    - Déclenche NotificationManager si streak = 4
//  -----------------------------------------------------------------------------

import Foundation
import Combine

@MainActor
final class DailyStreakManager: ObservableObject {
    
    static let shared = DailyStreakManager()
    
    // MARK: - État observable
    
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var jokerAvailable: Bool = false
    @Published private(set) var lastOpenDate: Date? = nil
    @Published private(set) var totalDaysOpened: Int = 0
    @Published private(set) var lastJokerUsedDate: Date? = nil
    
    // MARK: - UserDefaults Keys
    
    private let streakKey = "daily.streak.current"
    private let lastOpenDateKey = "daily.streak.lastOpenDate"
    private let totalDaysKey = "daily.streak.totalDaysOpened"
    private let lastJokerUsedKey = "daily.streak.lastJokerUsedDate"
    
    // MARK: - Constants
    
    private let jokerCooldownDays = 10 // Joker disponible tous les 10 jours
    
    private init() {
        loadFromUserDefaults()
        updateJokerAvailability()
    }
    
    // MARK: - Streak Update (appelé au launch)
    
    /// Vérifie et met à jour le streak en fonction de la date actuelle.
    /// - Important : À appeler au lancement de l'app (dans UniversalScoreboardApp ou SplashScreenView)
    func checkAndUpdateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Si lastOpenDate n'existe pas : premier lancement
        guard let lastOpen = lastOpenDate else {
            // Premier lancement de l'app
            currentStreak = 1
            lastOpenDate = today
            totalDaysOpened = 1
            persistToUserDefaults()
            
            #if DEBUG
            print("✅ [DailyStreakManager] Premier lancement : streak = 1")
            #endif
            return
        }
        
        let lastOpenDay = Calendar.current.startOfDay(for: lastOpen)
        let daysDifference = Calendar.current.dateComponents([.day], from: lastOpenDay, to: today).day ?? 0
        
        switch daysDifference {
        case 0:
            // Même jour : rien à faire (déjà compté)
            #if DEBUG
            print("🔄 [DailyStreakManager] Même jour, streak inchangé : \(currentStreak)")
            #endif
            
        case 1:
            // Jour suivant : incrémente le streak
            currentStreak += 1
            lastOpenDate = today
            totalDaysOpened += 1
            persistToUserDefaults()
            
            #if DEBUG
            print("✅ [DailyStreakManager] Streak +1 : \(currentStreak) jours")
            #endif
            
            // Notification spéciale si streak = 4
            if currentStreak == 4 {
                NotificationManager.shared.scheduleStreakReminder(currentStreak: 4)
            }
            
        default:
            // Gap > 1 jour : reset streak à 1
            #if DEBUG
            print("⚠️ [DailyStreakManager] Gap de \(daysDifference) jours, reset streak")
            #endif
            
            currentStreak = 1
            lastOpenDate = today
            totalDaysOpened += 1
            persistToUserDefaults()
        }
        
        updateJokerAvailability()
    }
    
    // MARK: - Joker System
    
    /// Utilise le joker pour rattraper 1 jour manqué.
    /// - Conditions : jokerAvailable = true
    /// - Effet : currentStreak += 1, consomme le joker
    func useJoker() {
        guard jokerAvailable else {
            #if DEBUG
            print("⚠️ [DailyStreakManager] Joker non disponible")
            #endif
            return
        }
        
        // Rattrape 1 jour
        currentStreak += 1
        lastJokerUsedDate = Date()
        jokerAvailable = false
        
        persistToUserDefaults()
        
        #if DEBUG
        print("⭐ [DailyStreakManager] Joker utilisé ! Streak = \(currentStreak)")
        #endif
    }
    
    /// Met à jour la disponibilité du joker (1 tous les 10 jours).
    private func updateJokerAvailability() {
        guard let lastUsed = lastJokerUsedDate else {
            // Jamais utilisé : disponible après 10 jours depuis le début
            jokerAvailable = totalDaysOpened >= jokerCooldownDays
            return
        }
        
        let daysSinceLastUse = Calendar.current.dateComponents([.day], from: lastUsed, to: Date()).day ?? 0
        jokerAvailable = daysSinceLastUse >= jokerCooldownDays
        
        #if DEBUG
        if jokerAvailable {
            print("⭐ [DailyStreakManager] Joker disponible !")
        } else {
            let daysRemaining = jokerCooldownDays - daysSinceLastUse
            print("⏳ [DailyStreakManager] Joker dans \(daysRemaining) jours")
        }
        #endif
    }
    
    /// Retourne le nombre de jours restants avant le prochain joker.
    func daysUntilNextJoker() -> Int {
        guard let lastUsed = lastJokerUsedDate else {
            let remaining = jokerCooldownDays - totalDaysOpened
            return max(0, remaining)
        }
        
        let daysSinceLastUse = Calendar.current.dateComponents([.day], from: lastUsed, to: Date()).day ?? 0
        return max(0, jokerCooldownDays - daysSinceLastUse)
    }
    
    // MARK: - Reset (Debug/Admin)
    
    /// Reset complet du streak (debug ou admin).
    func resetStreak() {
        currentStreak = 0
        lastOpenDate = nil
        totalDaysOpened = 0
        lastJokerUsedDate = nil
        jokerAvailable = false
        
        persistToUserDefaults()
        
        #if DEBUG
        print("🔄 [DailyStreakManager] Streak reset à 0")
        #endif
    }
    
    // MARK: - Persistance (UserDefaults)
    
    private func persistToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(currentStreak, forKey: streakKey)
        defaults.set(lastOpenDate, forKey: lastOpenDateKey)
        defaults.set(totalDaysOpened, forKey: totalDaysKey)
        defaults.set(lastJokerUsedDate, forKey: lastJokerUsedKey)
    }
    
    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        currentStreak = defaults.integer(forKey: streakKey)
        lastOpenDate = defaults.object(forKey: lastOpenDateKey) as? Date
        totalDaysOpened = defaults.integer(forKey: totalDaysKey)
        lastJokerUsedDate = defaults.object(forKey: lastJokerUsedKey) as? Date
        
        #if DEBUG
        print("📂 [DailyStreakManager] Chargé : streak=\(currentStreak), totalDays=\(totalDaysOpened)")
        #endif
    }
    
    // MARK: - Helpers UI
    
    /// Texte formaté pour afficher le streak (ex: "🔥 3/5 jours")
    func streakProgressText() -> String {
        return "🔥 \(currentStreak)/5 jours"
    }
    
    /// Texte formaté pour afficher le statut du joker.
    func jokerStatusText() -> String {
        if jokerAvailable {
            return "⭐ Joker disponible"
        } else {
            let daysRemaining = daysUntilNextJoker()
            if daysRemaining == 1 {
                return "⏳ Joker dans 1 jour"
            } else {
                return "⏳ Joker dans \(daysRemaining) jours"
            }
        }
    }
    
    // MARK: - Debug
    
    #if DEBUG
    /// Simule un changement de date (pour tester le streak).
    /// - Warning : À utiliser uniquement en debug !
    func simulateDateChange(daysOffset: Int) {
        guard let lastOpen = lastOpenDate else { return }
        
        let newDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: lastOpen) ?? Date()
        lastOpenDate = newDate
        persistToUserDefaults()
        
        print("🧪 [DailyStreakManager] Date simulée : \(newDate)")
        checkAndUpdateStreak()
    }
    
    /// Affiche l'état complet du streak (debug).
    func printStatus() {
        print("""
        📊 [DailyStreakManager] État actuel :
           - Streak actuel : \(currentStreak) jours
           - Total jours ouverts : \(totalDaysOpened)
           - Dernière ouverture : \(lastOpenDate?.description ?? "jamais")
           - Joker disponible : \(jokerAvailable ? "✅" : "❌")
           - Dernier joker utilisé : \(lastJokerUsedDate?.description ?? "jamais")
        """)
    }
    #endif
}
