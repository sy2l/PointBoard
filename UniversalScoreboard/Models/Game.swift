/*
 * Game.swift
 * PointBoard
 *
 * Modèle de données principal pour une partie
 *
 * Fonctionnalités:
 * - Identifiant unique de la partie
 * - Configuration du jeu (GameSettings)
 * - Liste des joueurs avec leurs scores
 * - Numéro du tour actuel
 * - Date de création
 * - Indicateur de fin de partie
 * - Propriétés calculées pour les joueurs actifs, gagnants, éliminés
 *
 * Technique:
 * - Struct Codable pour la sérialisation JSON
 * - Gestion de la compatibilité ascendante (Migration des anciennes sauvegardes)
 */

import Foundation

// MARK: - Game Model
struct Game: Codable, Equatable, Identifiable {
    let id: String
    let presetId: PresetID
    var settings: GameSettings
    var players: [Player]
    var currentRound: Int = 1
    let dateCreated: Date
    var isOver: Bool = false
    
    // Init standard pour la création
    init(
        id: String = UUID().uuidString,
        presetId: PresetID,
        settings: GameSettings,
        players: [Player],
        currentRound: Int = 1,
        dateCreated: Date = Date(),
        isOver: Bool = false
    ) {
        self.id = id
        self.presetId = presetId
        self.settings = settings
        self.players = players
        self.currentRound = currentRound
        self.dateCreated = dateCreated
        self.isOver = isOver
    }
    
    // MARK: - Init pour le Décodage (Correction du bug de sauvegarde)
    // Cela permet de lire les anciennes sauvegardes qui n'avaient pas encore de "presetId"
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        // C'EST ICI QUE LA MAGIE OPÈRE :
        // Si 'presetId' n'existe pas (vieux fichier), on met .generic par défaut.
        presetId = try container.decodeIfPresent(PresetID.self, forKey: .presetId) ?? .generic
        
        settings = try container.decode(GameSettings.self, forKey: .settings)
        players = try container.decode([Player].self, forKey: .players)
        currentRound = try container.decode(Int.self, forKey: .currentRound)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        isOver = try container.decode(Bool.self, forKey: .isOver)
    }
    
    // MARK: - Computed Properties
    var activePlayers: [Player] {
        return players.filter { $0.isActive }
    }
    
    var winners: [Player] {
        return players.filter { $0.hasReachedTarget }
    }
    
    var eliminatedPlayers: [Player] {
        return players.filter { $0.isEliminated }
    }
    
    var remainingPlayersCount: Int {
        return players.filter { !$0.isEliminated }.count
    }
    
    // MARK: - Codable Configuration
    enum CodingKeys: String, CodingKey {
        case id
        case presetId
        case settings
        case players
        case currentRound
        case dateCreated
        case isOver
    }
}
