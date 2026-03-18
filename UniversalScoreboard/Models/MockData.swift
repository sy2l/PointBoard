/*
 MockData.swift
 PointBoard
 
 Données de test pour les Previews SwiftUI.
 
 Fonctionnalités :
 - Profils joueurs avec statistiques variées
 - Parties archivées complètes
 - Facilite le développement et les tests visuels
 
 Technique :
 - Extension sur PlayerProfile et GameResult
 - Données réalistes pour les graphiques
 */

import Foundation

// MARK: - Mock Game Settings
// Cette extension est UNIQUEMENT pour les mocks/tests.
// Elle permet de simuler des configurations sans dépendre du fichier de presets externe.
extension GameSettings {
    static let skyjoPreset = GameSettings(
        mode: .points,
        initialValue: 0,
        target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
        endCondition: EndCondition(type: .remainingPlayers, value: 1),
        lowestScoreIsBest: true
    )
    
    static let winsPreset = GameSettings(
        mode: .wins,
        initialValue: 0,
        target: Target(value: 5, comparator: .greaterThanOrEqual, consequence: .winner),
        endCondition: EndCondition(type: .targetReached, value: 1),
        lowestScoreIsBest: false
    )
}

// MARK: - Mock Player Profiles

extension PlayerProfile {
    static let mockProfiles: [PlayerProfile] = [
        // Joueur expérimenté avec bonnes stats
        PlayerProfile(
            id: UUID(),
            name: "Alice",
            avatar: "crown.fill",
            stats: PlayerStats(
                gamesPlayed: 25,
                wins: 12,
                eliminations: 5,
                totalScore: 2450,
                highestScore: 150,
                lowestScore: 45
            ),
            createdAt: Date().addingTimeInterval(-30*24*3600), // 30 jours
            lastPlayedAt: Date().addingTimeInterval(-2*3600) // 2 heures
        ),
        
        // Joueur moyen
        PlayerProfile(
            id: UUID(),
            name: "Bob",
            avatar: "gamecontroller.fill",
            stats: PlayerStats(
                gamesPlayed: 15,
                wins: 5,
                eliminations: 8,
                totalScore: 1200,
                highestScore: 120,
                lowestScore: 30
            ),
            createdAt: Date().addingTimeInterval(-20*24*3600), // 20 jours
            lastPlayedAt: Date().addingTimeInterval(-24*3600) // 1 jour
        ),
        
        // Débutant
        PlayerProfile(
            id: UUID(),
            name: "Charlie",
            avatar: "person.circle.fill",
            stats: PlayerStats(
                gamesPlayed: 5,
                wins: 1,
                eliminations: 3,
                totalScore: 350,
                highestScore: 95,
                lowestScore: 25
            ),
            createdAt: Date().addingTimeInterval(-7*24*3600), // 7 jours
            lastPlayedAt: Date().addingTimeInterval(-3*24*3600) // 3 jours
        ),
        
        // Champion
        PlayerProfile(
            id: UUID(),
            name: "Diana",
            avatar: "trophy.fill",
            stats: PlayerStats(
                gamesPlayed: 40,
                wins: 28,
                eliminations: 3,
                totalScore: 4200,
                highestScore: 180,
                lowestScore: 60
            ),
            createdAt: Date().addingTimeInterval(-60*24*3600), // 60 jours
            lastPlayedAt: Date().addingTimeInterval(-1*3600) // 1 heure
        ),
        
        // Joueur malchanceux
        PlayerProfile(
            id: UUID(),
            name: "Ethan",
            avatar: "flame.fill",
            stats: PlayerStats(
                gamesPlayed: 20,
                wins: 2,
                eliminations: 15,
                totalScore: 800,
                highestScore: 85,
                lowestScore: 15
            ),
            createdAt: Date().addingTimeInterval(-45*24*3600), // 45 jours
            lastPlayedAt: Date().addingTimeInterval(-5*24*3600) // 5 jours
        )
    ]
    
    // Profil unique pour les tests
    static var mockAlice: PlayerProfile {
        mockProfiles[0]
    }
    
    static var mockBob: PlayerProfile {
        mockProfiles[1]
    }
    
    static var mockDiana: PlayerProfile {
        mockProfiles[3]
    }
}

// MARK: - Mock Game Results

extension GameResult {
    static let mockResults: [GameResult] = [
        // Partie récente - Alice gagne
        GameResult(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-2*3600),
            settings: GameSettings.skyjoPreset, // Utilise l'extension locale définie plus haut
            players: [
                PlayerResult(id: "p1", name: "Alice", score: 45, isEliminated: false, hasReachedTarget: true),
                PlayerResult(id: "p2", name: "Bob", score: 78, isEliminated: false, hasReachedTarget: false),
                PlayerResult(id: "p3", name: "Charlie", score: 92, isEliminated: false, hasReachedTarget: false)
            ],
            totalTurns: 8
        ),
        
        // Partie hier - Diana gagne
        GameResult(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-24*3600),
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            ),
            players: [
                PlayerResult(id: "p1", name: "Diana", score: 100, isEliminated: false, hasReachedTarget: true),
                PlayerResult(id: "p2", name: "Bob", score: 85, isEliminated: false, hasReachedTarget: false),
                PlayerResult(id: "p3", name: "Ethan", score: 70, isEliminated: false, hasReachedTarget: false)
            ],
            totalTurns: 12
        ),
        
        // Partie il y a 3 jours - Partie à 4 joueurs
        GameResult(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-3*24*3600),
            settings: GameSettings.winsPreset, // Utilise l'extension locale définie plus haut
            players: [
                PlayerResult(id: "p1", name: "Alice", score: 5, isEliminated: false, hasReachedTarget: true),
                PlayerResult(id: "p2", name: "Bob", score: 3, isEliminated: false, hasReachedTarget: false),
                PlayerResult(id: "p3", name: "Charlie", score: 2, isEliminated: false, hasReachedTarget: false),
                PlayerResult(id: "p4", name: "Diana", score: 4, isEliminated: false, hasReachedTarget: false)
            ],
            totalTurns: 15
        )
    ]
}

// MARK: - Mock Player Stats
// Note: PlayerStats et PlayerProfile utilisent leurs initialiseurs par défaut
