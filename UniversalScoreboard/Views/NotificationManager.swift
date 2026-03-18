//
//  NotificationManager.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  -----------------------------------------------------------------------------
//  NotificationManager — Gestion des notifications locales
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Demander permission notifications (au 2e lancement)
//    - Scheduler notifications récurrentes (10h17 + 19h43)
//    - Scheduler notification spéciale si streak = 4
//    - Annuler toutes notifications (si Bundle acheté)
//
//  ► Types de notifications
//    1. DAILY_MYSTERY (10h17 & 19h43) : Messages mystérieux rotatifs
//    2. STREAK_REMINDER (18h00) : Si streak = 4, rappel "plus qu'un jour !"
//
//  ► Intégration
//    - Appelé par DailyStreakManager (si streak = 4)
//    - Appelé par StoreManager (annulation après achat Bundle)
//    - Appelé au launch (scheduling quotidien)
//  -----------------------------------------------------------------------------

import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    // MARK: - État observable
    
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    // MARK: - Notification IDs (pour gérer annulations)
    
    private let morningNotificationID = "daily.mystery.morning"
    private let eveningNotificationID = "daily.mystery.evening"
    private let streakReminderID = "streak.reminder.4days"
    
    // MARK: - Categories
    
    private let dailyMysteryCategory = "DAILY_MYSTERY"
    private let streakReminderCategory = "STREAK_REMINDER"
    
    // MARK: - Messages (pools rotatifs pour éviter lassitude)
    
    private let morningMessages: [String] = [
        "Une surprise t'attend... 🎁 Viens voir !",
        "Pssst... Un cadeau se cache dans l'app 👀",
        "Quelque chose de spécial pour toi aujourd'hui ✨",
        "Ta récompense quotidienne est prête ! 🎉",
        "Petit cadeau du jour ? 🎁 C'est par ici !"
    ]
    
    private let eveningMessages: [String] = [
        "Bientôt le cadeau... 🎁 N'oublie pas de revenir demain !",
        "Ton cadeau arrive... ⏰ Reviens demain pour le découvrir !",
        "Plus qu'un jour avant la surprise 🎉",
        "Demain, un cadeau t'attend ! Ne rate pas ça 🎁",
        "Continue ta série ! 🔥 Un pack gratuit à portée de main !"
    ]
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Permission
    
    /// Demande l'autorisation d'envoyer des notifications.
    /// - Note : À appeler au 2e lancement (pas le 1er, taux refus trop élevé)
    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                isAuthorized = granted
            }
            
            if granted {
                await checkAuthorizationStatus()
                #if DEBUG
                print("✅ [NotificationManager] Permission accordée")
                #endif
            } else {
                #if DEBUG
                print("⚠️ [NotificationManager] Permission refusée")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ [NotificationManager] Erreur permission:", error.localizedDescription)
            #endif
        }
    }
    
    /// Vérifie l'état actuel de l'autorisation.
    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            authorizationStatus = settings.authorizationStatus
            isAuthorized = settings.authorizationStatus == .authorized
        }
        
        #if DEBUG
        print("🔔 [NotificationManager] Status:", settings.authorizationStatus.rawValue)
        #endif
    }
    
    // MARK: - Daily Mystery Notifications (10h17 & 19h43)
    
    /// Schedule les 2 notifications quotidiennes récurrentes.
    /// - Annule les anciennes avant de re-scheduler (évite doublons)
    func scheduleDailyMysteryNotifications() {
        guard isAuthorized else {
            #if DEBUG
            print("⚠️ [NotificationManager] Pas autorisé, skip scheduling")
            #endif
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        // Annuler anciennes notifs mystery
        center.removePendingNotificationRequests(withIdentifiers: [
            morningNotificationID,
            eveningNotificationID
        ])
        
        // Schedule matin (10h17)
        scheduleMorningNotification()
        
        // Schedule soir (19h43)
        scheduleEveningNotification()
        
        #if DEBUG
        print("✅ [NotificationManager] Daily mystery notifications schedulées (10h17 & 19h43)")
        #endif
    }
    
    private func scheduleMorningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "PointBoard"
        content.body = morningMessages.randomElement() ?? morningMessages[0]
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = dailyMysteryCategory
        content.userInfo = ["category": dailyMysteryCategory]
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 17
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: morningNotificationID,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                #if DEBUG
                print("❌ [NotificationManager] Erreur scheduling matin:", error.localizedDescription)
                #endif
            }
        }
    }
    
    private func scheduleEveningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "PointBoard"
        content.body = eveningMessages.randomElement() ?? eveningMessages[0]
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = dailyMysteryCategory
        content.userInfo = ["category": dailyMysteryCategory]
        
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 43
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: eveningNotificationID,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                #if DEBUG
                print("❌ [NotificationManager] Erreur scheduling soir:", error.localizedDescription)
                #endif
            }
        }
    }
    
    // MARK: - Streak Reminder (si currentStreak = 4)
    
    /// Schedule une notification spéciale si le streak = 4.
    /// - Délivrée à 18h00 (pic d'engagement)
    /// - Message : "Plus qu'un jour pour débloquer un pack GRATUIT !"
    func scheduleStreakReminder(currentStreak: Int) {
        guard isAuthorized, currentStreak == 4 else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // Annuler ancienne notif streak (si existe)
        center.removePendingNotificationRequests(withIdentifiers: [streakReminderID])
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak de 4 jours !"
        content.body = "Plus qu'un jour pour débloquer un pack GRATUIT ! 🎁"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = streakReminderCategory
        content.userInfo = [
            "category": streakReminderCategory,
            "streakValue": currentStreak
        ]
        
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: streakReminderID,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error {
                #if DEBUG
                print("❌ [NotificationManager] Erreur scheduling streak reminder:", error.localizedDescription)
                #endif
            } else {
                #if DEBUG
                print("✅ [NotificationManager] Streak reminder schedulée (18h00)")
                #endif
            }
        }
    }
    
    // MARK: - Annulation
    
    /// Annule TOUTES les notifications (pending + delivered).
    /// - Appelé après achat du Bundle (plus besoin de notifs)
    /// - Reset également le badge de l'app icon
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        resetBadge()
        
        #if DEBUG
        print("✅ [NotificationManager] Toutes notifications annulées")
        #endif
    }
    
    /// Annule uniquement les notifications streak (ex: après déblocage pack)
    func cancelStreakNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [streakReminderID]
        )
        
        #if DEBUG
        print("✅ [NotificationManager] Streak notifications annulées")
        #endif
    }
    
    // MARK: - Badge
    
    /// Reset le badge de l'app icon.
    /// - À appeler au launch de l'app (user a ouvert → "vu" les notifs)
    func resetBadge() {
        Task {
            let center = UNUserNotificationCenter.current()
            try? await center.setBadgeCount(0)
        }
    }
    
    // MARK: - Helpers
    
    /// Ouvre les Settings iOS (section Notifications de l'app).
    /// - Utilisé si user refuse permission et veut la réactiver
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Debug
    
    #if DEBUG
    /// Liste toutes les notifications en attente (debug)
    func listPendingNotifications() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        
        print("📋 [NotificationManager] Pending notifications (\(requests.count)):")
        for request in requests {
            print("  - \(request.identifier) | \(request.content.title)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("    Trigger:", trigger.dateComponents)
            }
        }
    }
    #endif
}
