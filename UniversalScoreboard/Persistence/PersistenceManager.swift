/*
 * PersistenceManager.swift
 * PointBoard
 *
 * Gestionnaire de persistance des données
 *
 * Fonctionnalités:
 * - Sauvegarde de la partie en cours dans UserDefaults
 * - Chargement de la partie sauvegardée
 * - Sauvegarde de l'historique des tours (snapshots)
 * - Suppression des données sauvegardées
 * - Encodage/décodage JSON avec dates ISO8601
 *
 * Technique:
 * - Singleton pattern (shared instance)
 * - UserDefaults pour le stockage local
 * - JSONEncoder/Decoder pour la sérialisation
 * - Gestion des erreurs avec throws
 */

import Foundation

// MARK: - Persistence Manager
class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults = UserDefaults.standard
    private let gameKey = "currentGame"
    private let historyKey = "gameHistory"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        // Configure decoder for ISO8601 dates
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Save Operations
    
    /// Saves the current game state
    func saveGame(_ game: Game) throws {
        let data = try encoder.encode(game)
        userDefaults.set(data, forKey: gameKey)
    }
    
    /// Saves a game snapshot to history
    func saveGameSnapshot(_ game: Game) throws {
        var history = try loadGameHistory()
        history.append(game)
        let data = try encoder.encode(history)
        userDefaults.set(data, forKey: historyKey)
    }
    
    // MARK: - Load Operations
    
    /// Loads the current game state
    func loadGame() -> Game? {
        guard let data = userDefaults.data(forKey: gameKey) else {
            return nil
        }
        
        do {
            return try decoder.decode(Game.self, from: data)
        } catch {
            print("Error decoding game: \(error)")
            return nil
        }
    }
    
    /// Loads the game history
    func loadGameHistory() throws -> [Game] {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return []
        }
        
        return try decoder.decode([Game].self, from: data)
    }
    
    // MARK: - Delete Operations
    
    /// Deletes the current game state
    func deleteGame() {
        userDefaults.removeObject(forKey: gameKey)
    }
    
    /// Deletes all saved data
    func deleteAll() {
        userDefaults.removeObject(forKey: gameKey)
        userDefaults.removeObject(forKey: historyKey)
    }
    
    // MARK: - Utility Methods
    
    /// Checks if a game is currently saved
    func hasGame() -> Bool {
        return userDefaults.data(forKey: gameKey) != nil
    }
}
