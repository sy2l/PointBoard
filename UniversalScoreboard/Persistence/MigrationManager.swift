//
//  MigrationManager.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  -----------------------------------------------------------------------------
//  MigrationManager — Gestion des migrations de données entre versions
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Migrer les données des anciennes versions vers le nouveau modèle
//    - Protéger les utilisateurs existants lors des changements majeurs
//    - Exécuter une seule fois par version (flag UserDefaults)
//
//  ► Migration V1 → V2 (Ancien Pro → Bundle All Packs)
//    - Détecte si l'utilisateur avait acheté "Pro" (ancien système)
//    - Convertit en "Bundle All Packs" (nouveau système)
//    - Annule les notifications (plus besoin si Bundle)
//    - Nettoie l'ancienne clé UserDefaults
//
//  ► Intégration
//    - Appelé au lancement de l'app (UniversalScoreboardApp ou SplashScreenView)
//    - Exécuté avant tout autre manager (pour garantir données cohérentes)
//  -----------------------------------------------------------------------------

import Foundation

struct MigrationManager {
    
    // MARK: - Migration V1 → V2
    
    /// Migre du système "Pro" vers le système "Bundle All Packs".
    /// - Important : À appeler au lancement de l'app (une seule fois)
    static func migrateV1toV2() {
        let defaults = UserDefaults.standard
        
        // Vérifier si migration déjà effectuée
        if defaults.bool(forKey: "migration.v2.completed") {
            #if DEBUG
            print("ℹ️ [MigrationManager] Migration V2 déjà effectuée, skip")
            #endif
            return
        }
        
        #if DEBUG
        print("🔄 [MigrationManager] Démarrage migration V1 → V2...")
        #endif
        
        // MIGRATION : Ancien Pro → Bundle All Packs
        if defaults.bool(forKey: "store.isProUser") {
            // L'utilisateur avait acheté Pro (ancien système)
            // → On lui donne le Bundle All Packs (nouveau système)
            
            defaults.set(true, forKey: "store.hasAllPacksBundle")
            defaults.removeObject(forKey: "store.isProUser")
            
            // Annuler toutes les notifications (plus besoin si Bundle)
            Task { @MainActor in
                NotificationManager.shared.cancelAllNotifications()
            }
            
            #if DEBUG
            print("✅ [MigrationManager] Ancien utilisateur Pro → Bundle All Packs")
            #endif
        } else {
            #if DEBUG
            print("ℹ️ [MigrationManager] Pas d'ancien Pro détecté")
            #endif
        }
        
        // NETTOYAGE : Anciennes clés obsolètes (si nécessaire)
        // Exemple : si tu veux nettoyer d'autres anciennes clés
        // defaults.removeObject(forKey: "old.unused.key")
        
        // Marquer la migration comme terminée
        defaults.set(true, forKey: "migration.v2.completed")
        
        #if DEBUG
        print("✅ [MigrationManager] Migration V2 terminée")
        #endif
    }
    
    // MARK: - Reset (Debug uniquement)
    
    #if DEBUG
    /// Reset la migration (pour tester à nouveau).
    /// - Warning : À utiliser uniquement en debug !
    static func resetMigration() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "migration.v2.completed")
        print("🔄 [MigrationManager] Migration reset (debug)")
    }
    
    /// Reset complet de toutes les données (debug).
    /// - Warning : Supprime TOUT (achats, streak, progression)
    static func resetAllData() {
        let defaults = UserDefaults.standard
        
        // Store
        defaults.removeObject(forKey: "store.hasAllPacksBundle")
        defaults.removeObject(forKey: "store.unlockedPacks")
        defaults.removeObject(forKey: "store.isProUser") // ancien
        
        // Streak
        defaults.removeObject(forKey: "daily.streak.current")
        defaults.removeObject(forKey: "daily.streak.lastOpenDate")
        defaults.removeObject(forKey: "daily.streak.totalDaysOpened")
        defaults.removeObject(forKey: "daily.streak.lastJokerUsedDate")
        
        // Unlock Progress
        for pack in GamePack.allCases {
            defaults.removeObject(forKey: "unlock.progress.\(pack.rawValue).adsWatched")
        }
        defaults.removeObject(forKey: "unlock.progress.streakUnlockUsed")
        
        // Migration
        defaults.removeObject(forKey: "migration.v2.completed")
        
        print("🗑️ [MigrationManager] Toutes les données ont été supprimées (debug)")
    }
    #endif
}
