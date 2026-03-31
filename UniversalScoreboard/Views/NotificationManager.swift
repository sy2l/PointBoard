//
//  NotificationManager.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  Updated on 26/03/2026 — Simplifié après suppression du système Streak
//  -----------------------------------------------------------------------------
//  NotificationManager — Gestion des notifications locales
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Demander permission notifications (au 2e lancement)
//    - Reset du badge de l'app icon
//
//  ► Note : Système de notifications streak/mystery supprimé (refus Apple)
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
}
