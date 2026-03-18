/*
 * Player.swift
 * PointBoard
 *
 * Modèle de données pour un joueur
 *
 * Fonctionnalités:
 * - Identifiant unique (String)
 * - Nom du joueur
 * - Score actuel
 * - Statut d'élimination
 * - Indicateur d'atteinte de la cible
 * - Propriétés calculées pour le statut et l'activité
 *
 * Technique:
 * - Struct conforme à Codable pour la sérialisation
 * - Identifiable pour SwiftUI ForEach
 * - Equatable et Hashable pour les comparaisons
 * - Factory method pour la création simplifiée
 */

import Foundation

// MARK: - Player Model
struct Player: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var score: Int
    var isEliminated: Bool = false
    var hasReachedTarget: Bool = false
    var profileId: UUID?  // ID du profil si joueur enregistré, nil si invité
    
    init(id: String, name: String, score: Int, isEliminated: Bool = false, hasReachedTarget: Bool = false, profileId: UUID? = nil) {
        self.id = id
        self.name = name
        self.score = score
        self.isEliminated = isEliminated
        self.hasReachedTarget = hasReachedTarget
        self.profileId = profileId
    }
    
    // MARK: - Factory Methods
    static func create(id: String, name: String, initialScore: Int, profileId: UUID? = nil) -> Player {
        return Player(
            id: id,
            name: name,
            score: initialScore,
            isEliminated: false,
            hasReachedTarget: false,
            profileId: profileId
        )
    }
    
    // MARK: - Computed Properties
    var status: PlayerStatus {
        if hasReachedTarget {
            return .winner
        } else if isEliminated {
            return .eliminated
        } else {
            return .active
        }
    }
    
    var isActive: Bool {
        return !isEliminated && !hasReachedTarget
    }
}
