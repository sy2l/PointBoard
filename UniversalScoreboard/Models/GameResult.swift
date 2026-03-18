/*
 GameResult.swift
 PointBoard
 
 Modèle allégé pour l'archivage des parties terminées.
 Sprint 1 - V3.0
 */

import Foundation

struct GameResult: Codable, Identifiable {
    let id: String
    let date: Date
    let settings: GameSettings
    let players: [PlayerResult]
    let totalTurns: Int
    
    init(from game: Game) {
        self.id = game.id
        self.date = Date()
        self.settings = game.settings
        self.players = game.players.map { PlayerResult(from: $0) }
        self.totalTurns = game.currentRound
    }
    
    init(
            id: String,
            date: Date,
            settings: GameSettings,
            players: [PlayerResult],
            totalTurns: Int
        ) {
            self.id = id
            self.date = date
            self.settings = settings
            self.players = players
            self.totalTurns = totalTurns
        }
    
    // Propriétés calculées pour l'affichage
    var winners: [PlayerResult] {
        players.filter { $0.hasReachedTarget }
    }
    
    var eliminated: [PlayerResult] {
        players.filter { $0.isEliminated }
    }
    
    var activePlayers: [PlayerResult] {
        players.filter { !$0.isEliminated && !$0.hasReachedTarget }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PlayerResult: Codable, Identifiable {
    let id: String
    let name: String
    let score: Int
    let isEliminated: Bool
    let hasReachedTarget: Bool
    var finalScore: Int { score }
    
    init(from player: Player) {
        self.id = player.id
        self.name = player.name
        self.score = player.score
        self.isEliminated = player.isEliminated
        self.hasReachedTarget = player.hasReachedTarget
    }
    
    // Initializer pour les mocks et tests
    init(id: String, name: String, score: Int, isEliminated: Bool, hasReachedTarget: Bool) {
        self.id = id
        self.name = name
        self.score = score
        self.isEliminated = isEliminated
        self.hasReachedTarget = hasReachedTarget
    }
}
