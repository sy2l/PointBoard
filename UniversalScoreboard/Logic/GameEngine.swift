/*
 * GameEngine.swift
 * PointBoard
 *
 * Moteur de logique métier du jeu
 *
 * Fonctionnalités:
 * - Création de nouvelle partie avec validation
 * - Validation des tours avec mise à jour des scores
 * - Vérification des conditions de seuil (élimination/victoire)
 * - Vérification des conditions de fin de partie
 * - Gestion des égalités (ex-aequo)
 *
 * Technique:
 * - Struct sans état (stateless) pour la logique pure
 * - Fonctions pures qui retournent un nouvel état
 * - Pas d'effets de bord
 * - Testable unitairement
 */

import Foundation

// MARK: - Game Engine
struct GameEngine {
    
    // MARK: - Public Methods
    
    /// Validates and applies a round of score changes
    /// - Parameters:
    ///   - game: The current game state
    ///   - deltas: Dictionary mapping player IDs to score changes
    /// - Returns: Updated game state after applying deltas and checking end conditions
    func validateTurn(game: Game, deltas: [String: Int]) -> Game {
        var updatedGame = game
        
        // Apply deltas to players
        for (playerId, delta) in deltas {
            if let index = updatedGame.players.firstIndex(where: { $0.id == playerId }) {
                updatedGame.players[index].score += delta
            }
        }
        
        // Check target conditions for each player
        updatedGame = checkTargetConditions(game: updatedGame)
        
        // Check if game is over
        updatedGame = checkGameEndCondition(game: updatedGame)
        
        // Increment round if game is not over
        if !updatedGame.isOver {
            updatedGame.currentRound += 1
        }
        
        return updatedGame
    }
    
    /// Creates a new game with the given settings and players
    /// - Parameters:
    ///   - settings: Game configuration
    ///   - presetId: The ID of the preset used (added for theming persistence)
    ///   - playerNames: List of player names (minimum 2)
    ///   - profileIds: Optional list of profile IDs for registered players
    /// - Returns: A new Game instance
    func createGame(settings: GameSettings, presetId: PresetID, playerNames: [String], profileIds: [UUID?] = []) -> Game? {
        guard playerNames.count >= 2 else { return nil }
        
        let players = playerNames.enumerated().map { (index, name) in
            let profileId = index < profileIds.count ? profileIds[index] : nil
            return Player.create(id: "p\(index + 1)", name: name, initialScore: settings.initialValue, profileId: profileId)
        }
        
        return Game(
            id: UUID().uuidString,
            presetId: presetId, // <-- On stocke l'ID ici
            settings: settings,
            players: players,
            currentRound: 1,
            dateCreated: Date(),
            isOver: false
        )
    }
    
    /// Checks if a player meets the target condition
    /// - Parameters:
    ///   - player: The player to check
    ///   - target: The target configuration
    /// - Returns: True if the player meets the target condition
    func playerMeetsTarget(player: Player, target: Target) -> Bool {
        switch target.comparator {
        case .greaterThanOrEqual:
            return player.score >= target.value
        case .lessThanOrEqual:
            return player.score <= target.value
        }
    }
    
    // MARK: - Private Methods
    
    private func checkTargetConditions(game: Game) -> Game {
        var updatedGame = game
        let target = game.settings.target
        
        for (index, player) in updatedGame.players.enumerated() {
            if player.isActive && playerMeetsTarget(player: player, target: target) {
                switch target.consequence {
                case .winner:
                    updatedGame.players[index].hasReachedTarget = true
                case .eliminated:
                    updatedGame.players[index].isEliminated = true
                case .none:
                    // Cas "Compteur simple" : Atteindre la cible ne déclenche rien de spécial
                    // On ne marque pas le joueur comme vainqueur ou éliminé
                    break
                }
            }
        }
        
        return updatedGame
    }
    
    private func checkGameEndCondition(game: Game) -> Game {
        var updatedGame = game
        let endCondition = game.settings.endCondition
        
        switch endCondition.type {
        case .remainingPlayers:
            // Fin quand il ne reste que X joueurs (ex: Battle Royale)
            if updatedGame.remainingPlayersCount <= endCondition.value {
                updatedGame.isOver = true
            }
            
        case .targetReached:
            // Fin quand X joueurs ont atteint la cible (ex: Course aux points)
            if updatedGame.winners.count >= endCondition.value {
                updatedGame.isOver = true
            }
            
        case .manual:
            // La partie ne se termine jamais automatiquement via une règle mathématique.
            // L'utilisateur doit appuyer sur "Terminer la partie" dans l'UI.
            break
        }
        
        return updatedGame
    }
    
    // MARK: - Winner Determination
    
    /// NOUVEAU : Détermine les gagnants d'une partie terminée
    /// - Parameter game: La partie terminée
    /// - Returns: Liste des joueurs gagnants
    static func determineWinners(game: Game) -> [Player] {
        // Si la partie n'est pas terminée, retourner vide
        guard game.isOver else { return [] }
        
        let settings = game.settings
        
        // Cas 1 : Mode victoire par cible atteinte
        if settings.target.consequence == .winner {
            return game.winners
        }
        
        // Cas 2 : Mode élimination (dernier survivant)
        if settings.target.consequence == .eliminated {
            let survivors = game.players.filter { !$0.isEliminated }
            return survivors
        }
        
        // Cas 3 : Mode compteur simple (score le plus haut/bas)
        if settings.lowestScoreIsBest {
            // Score le plus bas gagne
            let minScore = game.players.map { $0.score }.min() ?? 0
            return game.players.filter { $0.score == minScore }
        } else {
            // Score le plus haut gagne
            let maxScore = game.players.map { $0.score }.max() ?? 0
            return game.players.filter { $0.score == maxScore }
        }
    }
}
