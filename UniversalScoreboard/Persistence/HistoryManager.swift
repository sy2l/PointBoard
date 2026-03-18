/*
 HistoryManager.swift
 PointBoard
 
 Gestionnaire de l'historique des parties terminées.
 Sprint 1 - V3.0
 */

import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    private let fileManager = FileManager.default
    private let historyDirectory: URL
    private let freeLimit = 10 // Limite freemium
    
    private init() {
        // Créer le dossier History dans Documents
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        historyDirectory = documentsPath.appendingPathComponent("History")
        
        // Créer le dossier s'il n'existe pas
        if !fileManager.fileExists(atPath: historyDirectory.path) {
            try? fileManager.createDirectory(at: historyDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: - Archive
    
    /// Vérifie si l'utilisateur peut sauvegarder une partie
    @MainActor
    func canSaveGame() -> Bool {
        // Si Bundle acheté, pas de limite
        if StoreManager.shared.hasAllPacksBundle {
            return true
        }
        // Limite de 10 parties pour utilisateurs gratuits
        return loadHistory().count < freeLimit
    }
    
    /// Archive une partie terminée après avoir vu une pub si nécessaire
    @MainActor
    func archiveGameWithAdCheck(_ game: Game, completion: @escaping (Bool) -> Void) {
        if canSaveGame() {
            // Sauvegarder directement
            archiveGame(game)
            completion(true)
        } else {
            // Afficher une pub récompensée avant de sauvegarder
            AdManager.shared.showRewardedAd { [weak self] success in
                if success {
                    self?.archiveGame(game)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    /// Archive une partie terminée
    @MainActor
    func archiveGame(_ game: Game) {
        let result = GameResult(from: game)
        
        // Sauvegarder le fichier JSON
        let filename = "\(result.id).json"
        let fileURL = historyDirectory.appendingPathComponent(filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(result)
            try data.write(to: fileURL)
            
            print("✅ Partie archivée : \(filename)")
            
            // Vérifier la limite freemium
            enforceFreemiumLimit()
        } catch {
            print("❌ Erreur lors de l'archivage : \(error)")
        }
    }
    
    // MARK: - Load
    
    /// Charge toutes les parties archivées (triées par date décroissante)
    func loadHistory() -> [GameResult] {
        var results: [GameResult] = []
        
        do {
            let files = try fileManager.contentsOfDirectory(at: historyDirectory, includingPropertiesForKeys: [.creationDateKey])
            
            for fileURL in files where fileURL.pathExtension == "json" {
                if let data = try? Data(contentsOf: fileURL) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let result = try? decoder.decode(GameResult.self, from: data) {
                        results.append(result)
                    }
                }
            }
        } catch {
            print("❌ Erreur lors du chargement de l'historique : \(error)")
        }
        
        // Trier par date décroissante
        return results.sorted { $0.date > $1.date }
    }
    
    // MARK: - Freemium Logic
    
    /// Vérifie si la limite freemium est atteinte
    @MainActor
    func isLimitReached() -> Bool {
        let hasBundle = StoreManager.shared.hasAllPacksBundle
        return !hasBundle && loadHistory().count >= freeLimit
    }
    
    /// Vérifie et applique la limite freemium (3 parties max)
    @MainActor
    private func enforceFreemiumLimit() {
        let hasBundle = StoreManager.shared.hasAllPacksBundle
        
        if !hasBundle {
            let history = loadHistory()
            
            // Si plus de 10 parties, supprimer les plus anciennes
            if history.count > freeLimit {
                let toDelete = history.suffix(from: freeLimit)
                for result in toDelete {
                    deleteGame(result.id)
                }
                print("🗑️ Suppression automatique : \(toDelete.count) partie(s) supprimée(s)")
            }
        }
    }
    
    // MARK: - Delete
    
    /// Supprime une partie archivée
    func deleteGame(_ id: String) {
        let filename = "\(id).json"
        let fileURL = historyDirectory.appendingPathComponent(filename)
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("🗑️ Partie supprimée : \(filename)")
        } catch {
            print("❌ Erreur lors de la suppression : \(error)")
        }
    }
    
    /// Supprime tout l'historique
    func deleteAllHistory() {
        do {
            let files = try fileManager.contentsOfDirectory(at: historyDirectory, includingPropertiesForKeys: nil)
            for fileURL in files {
                try? fileManager.removeItem(at: fileURL)
            }
            print("🗑️ Historique complet supprimé")
        } catch {
            print("❌ Erreur lors de la suppression de l'historique : \(error)")
        }
    }
}
