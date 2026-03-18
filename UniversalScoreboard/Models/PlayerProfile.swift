/*
 PlayerProfile.swift
 PointBoard

 Modèle de profil joueur avec statistiques.

 Fonctionnalités :
 - Stocke les informations du joueur (nom, avatar)
 - Statistiques cumulées (victoires, défaites, parties jouées)
 - Identifiable et Codable pour la persistance

 Technique :
 - struct Codable pour la sérialisation JSON
 - UUID pour l'identification unique
 - Propriétés calculées pour les ratios
 */

import Foundation

struct PlayerProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var avatar: String  // SF Symbol name
    var stats: PlayerStats
    var createdAt: Date
    var lastPlayedAt: Date?

    init(name: String, avatar: String = "person.circle.fill") {
        self.id = UUID()
        self.name = name
        self.avatar = avatar
        self.stats = PlayerStats()
        self.createdAt = Date()
        self.lastPlayedAt = nil
    }

    init(
        id: UUID,
        name: String,
        avatar: String,
        stats: PlayerStats,
        createdAt: Date,
        lastPlayedAt: Date
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.stats = stats
        self.createdAt = createdAt
        self.lastPlayedAt = lastPlayedAt
    }

    // MARK: - Computed Properties

    var winRate: Double {
        guard stats.gamesPlayed > 0 else { return 0.0 }
        return Double(stats.wins) / Double(stats.gamesPlayed)
    }

    var winRatePercentage: String {
        String(format: "%.1f%%", winRate * 100)
    }

    var averageScore: Double {
        guard stats.gamesPlayed > 0 else { return 0.0 }
        return Double(stats.totalScore) / Double(stats.gamesPlayed)
    }
}

struct PlayerStats: Codable, Hashable {
    var gamesPlayed: Int = 0
    var wins: Int = 0
    var eliminations: Int = 0
    var totalScore: Int = 0
    var highestScore: Int = 0
    var lowestScore: Int = 0

    // MARK: - Update Methods

    mutating func recordGame(won: Bool, eliminated: Bool, finalScore: Int) {
        gamesPlayed += 1

        if won {
            wins += 1
        }

        if eliminated {
            eliminations += 1
        }

        totalScore += finalScore

        // Update highest/lowest scores
        if gamesPlayed == 1 {
            highestScore = finalScore
            lowestScore = finalScore
        } else {
            if finalScore > highestScore {
                highestScore = finalScore
            }
            if finalScore < lowestScore {
                lowestScore = finalScore
            }
        }
    }
}

// MARK: - Default Avatars

extension PlayerProfile {
    static let defaultAvatars = [
        "person.circle.fill",
        "person.crop.circle.fill",
        "person.crop.circle.badge.checkmark",
        "person.crop.circle.badge.plus",
        "person.crop.square.fill",
        "person.2.circle.fill",
        "gamecontroller.fill",
        "star.circle.fill",
        "crown.fill",
        "trophy.fill",
        "flame.fill",
        "bolt.circle.fill",
    ]
}
