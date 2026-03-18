/*
 * Enums.swift
 * PointBoard
 *
 * Énumérations pour la configuration du jeu
 *
 * Fonctionnalités:
 * - GameMode: Mode de jeu (Points ou Victoires)
 * - TargetComparator: Comparateur pour le seuil (>= ou <=)
 * - TargetConsequence: Conséquence d'atteindre le seuil (Victoire ou Élimination)
 * - EndConditionType: Type de condition de fin (Joueurs restants ou Cible atteinte)
 * - PlayerStatus: Statut d'un joueur (Actif, Éliminé, Vainqueur)
 *
 * Technique:
 * - Tous les enums sont Codable pour la sérialisation JSON
 * - Raw values en majuscules pour compatibilité avec le format JSON frozen
 */

import Foundation

// MARK: - Game Mode
enum GameMode: String, Codable, CaseIterable {
    case points = "POINTS"
    case wins = "WINS"
}

// MARK: - Target Comparator
enum TargetComparator: String, Codable, CaseIterable {
    case greaterThanOrEqual = "GREATER_THAN_OR_EQUAL"
    case lessThanOrEqual = "LESS_THAN_OR_EQUAL"
}

// MARK: - Target Consequence
enum TargetConsequence: String, Codable, CaseIterable {
    case winner = "WINNER"
    case eliminated = "ELIMINATED"
    case none = "NONE" // Ajouté pour corriger l'erreur (ex: simple compteur)
}

// MARK: - End Condition Type
enum EndConditionType: String, Codable, CaseIterable {
    case remainingPlayers = "REMAINING_PLAYERS"
    case targetReached = "TARGET_REACHED"
    case manual = "MANUAL" // Ajouté pour corriger l'erreur (pas de fin auto)
}

// MARK: - Player Status
enum PlayerStatus: String, Codable, CaseIterable {
    case active = "ACTIVE"
    case eliminated = "ELIMINATED"
    case winner = "WINNER"
}
