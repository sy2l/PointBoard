//
//  MigrationManager.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  Updated by sy2l on 12/05/2026 — Migration V6.0.0 : Nettoyage références IAP obsolètes
//  -----------------------------------------------------------------------------
//  MigrationManager — Gestion des migrations de données entre versions
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Migrer les données des anciennes versions vers le nouveau modèle
//    - Protéger les utilisateurs existants lors des changements majeurs
//    - Exécuter une seule fois par version (flag UserDefaults)
//
//  ► Migration V1 → V2 (Ancien Pro → Bundle All Packs)
//    - ⚠️ CONSERVÉE pour compatibilité utilisateurs existants
//    - Note : Dans la V6.0.0, l'app est 100% gratuite mais on garde cette
//      migration pour ne pas perdre les données des anciens utilisateurs
//
//  ► Intégration
//    - Appelé au lancement de l'app (UniversalScoreboardApp)
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
        
        // MIGRATION : Ancien Pro → Bundle All Packs (V6.0.0 : conservé pour compatibilité)
        if defaults.bool(forKey: "store.isProUser") {
            // L'utilisateur avait acheté Pro (ancien système)
            // Note : Dans V6.0.0, l'app est gratuite, mais on garde cette clé
            // pour éviter de perdre les données des anciens utilisateurs
            
            defaults.removeObject(forKey: "store.isProUser")
            
            #if DEBUG
            print("✅ [MigrationManager] Ancien utilisateur Pro détecté → migration nettoyée")
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
    
    // MARK: - Migration V2 → V3 (V6.0.0 : App gratuite)
    
    /// Nettoie les anciennes clés IAP devenues obsolètes.
    /// - Important : À appeler au lancement de l'app (une seule fois)
    static func migrateV2toV3() {
        let defaults = UserDefaults.standard
        
        // Vérifier si migration déjà effectuée
        if defaults.bool(forKey: "migration.v3.completed") {
            #if DEBUG
            print("ℹ️ [MigrationManager] Migration V3 déjà effectuée, skip")
            #endif
            return
        }
        
        #if DEBUG
        print("🔄 [MigrationManager] Démarrage migration V2 → V3 (App gratuite)...")
        #endif
        
        // NETTOYAGE : Anciennes clés IAP obsolètes (app gratuite)
        defaults.removeObject(forKey: "store.hasAllPacksBundle")
        defaults.removeObject(forKey: "store.hasPremiumNoAds")
        defaults.removeObject(forKey: "store.unlockedPacks")
        defaults.removeObject(forKey: "store.isProUser") // ancien (par sécurité)
        
        #if DEBUG
        print("✅ [MigrationManager] Anciennes clés IAP nettoyées")
        #endif
        
        // Message de bienvenue (optionnel)
        #if DEBUG
        print("🎉 [MigrationManager] Bienvenue dans PointBoard V6.0.0 - 100% gratuite !")
        #endif
        
        // Marquer la migration comme terminée
        defaults.set(true, forKey: "migration.v3.completed")
        
        #if DEBUG
        print("✅ [MigrationManager] Migration V3 terminée")
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
    /// - Warning : Supprime TOUT
    static func resetAllData() {
        let defaults = UserDefaults.standard
        
        // Migration
        defaults.removeObject(forKey: "migration.v2.completed")
        
        // App State
        defaults.removeObject(forKey: "app.launchCount")
        defaults.removeObject(forKey: "notif.permissionAsked")
        
        print("🗑️ [MigrationManager] Toutes les données ont été supprimées (debug)")
    }
    #endif
}
