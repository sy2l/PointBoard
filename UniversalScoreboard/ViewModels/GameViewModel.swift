/*
 * GameViewModel.swift
 * PointBoard
 *
 * ViewModel principal pour la gestion de l'état du jeu
 *
 * Fonctionnalités:
 * - Création de nouvelle partie
 * - Validation des tours avec mise à jour des scores
 * - Annulation du dernier tour (undo)
 * - Fin manuelle de la partie
 * - Sauvegarde et chargement de la partie en cours
 * - Gestion de l'historique des tours
 * - Création de revanche
 *
 * Technique:
 * - Classe ObservableObject pour la réactivité SwiftUI
 * - @Published pour les propriétés observées
 * - Utilise GameEngine pour la logique métier
 * - Utilise PersistenceManager pour la sauvegarde
 * - Pattern MVVM (Model-View-ViewModel)
 *
 * Updated on 03/02/2026 — Fix Undo: history should not depend on snapshot persistence
 */

import Foundation

// MARK: - Game View Model
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published State
    @Published var game: Game?
    @Published var gameHistory: [Game] = []
    @Published var errorMessage: String?
    @Published var turnCount: Int = 0

    // MARK: - Dependencies
    private let engine = GameEngine()
    private let persistence = PersistenceManager.shared

    // MARK: - Initialization
    init() {
        loadSavedGame()
    }

    // MARK: - Game Creation

    /// Creates a new game with the given settings and player names
    /// Ajout : profileIds pour lier les joueurs aux profils
    func createGame(
        settings: GameSettings,
        presetId: PresetID,
        playerNames: [String],
        profileIds: [UUID?] = []
    ) {
        guard let newGame = engine.createGame(
            settings: settings,
            presetId: presetId,
            playerNames: playerNames,
            profileIds: profileIds
        ) else {
            errorMessage = "Invalid game configuration. Minimum 2 players required."
            return
        }

        game = newGame
        gameHistory = []
        turnCount = 0

        do {
            try persistence.saveGame(newGame)
        } catch {
            errorMessage = "Failed to save game: \(error.localizedDescription)"
        }
    }

    // MARK: - Players Management (legacy)

    func updatePlayers(names: [String]) {
        guard var currentGame = game else { return }

        let sanitizedNames: [String] = names
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard sanitizedNames.count >= 2 else { return }

        var updatedPlayers: [Player] = []
        updatedPlayers.reserveCapacity(sanitizedNames.count)

        // Map existing players by name to preserve their scores
        var existingPlayersByName: [String: Player] = [:]
        for player in currentGame.players {
            existingPlayersByName[player.name] = player
        }

        for index in sanitizedNames.indices {
            let name = sanitizedNames[index]

            if let existingPlayer = existingPlayersByName[name] {
                var updatedPlayer = existingPlayer
                updatedPlayer.name = name
                updatedPlayers.append(updatedPlayer)
            } else if index < currentGame.players.count {
                var existingPlayer = currentGame.players[index]
                existingPlayer.name = name
                updatedPlayers.append(existingPlayer)
            } else {
                let newPlayer = Player(
                    id: UUID().uuidString,
                    name: name,
                    score: currentGame.settings.initialValue,
                    isEliminated: false,
                    hasReachedTarget: false,
                    profileId: nil
                )
                updatedPlayers.append(newPlayer)
            }
        }

        currentGame.players = updatedPlayers
        game = currentGame

        do {
            try persistence.saveGame(currentGame)
        } catch {
            errorMessage = "Failed to save game: \(error.localizedDescription)"
        }
    }

    // MARK: - Game Actions

    /// Validates the current round with the given score deltas
    func validateTurn(deltas: [String: Int]) {
        guard let currentGame = game else {
            errorMessage = "No active game"
            return
        }

        // MARK: - Undo snapshot (local-first)
        // ✅ IMPORTANT:
        // L'undo ne doit PAS dépendre de l'écriture disque.
        // On push l'historique d'abord, et la sauvegarde snapshot est best-effort.
        gameHistory.append(currentGame)

        // MARK: - Snapshot persistence (best effort)
        do {
            try persistence.saveGameSnapshot(currentGame)
        } catch {
            // On conserve l'undo local même si le snapshot disque échoue.
            #if DEBUG
            print("⚠️ saveGameSnapshot failed (undo still works): \(error.localizedDescription)")
            #endif
            errorMessage = "Failed to save game snapshot: \(error.localizedDescription)"
        }

        // MARK: - Apply turn validation (engine)
        let updatedGame = engine.validateTurn(game: currentGame, deltas: deltas)
        game = updatedGame

        // MARK: - Turn counter
        turnCount += 1

        // MARK: - Ads gating (every 5 turns)
        if turnCount % 5 == 0 {
            let isProUser = StoreManager.shared.isProUser
            let isTrialActive = ProTrialManager.shared.isTrialActive
            if !isProUser && !isTrialActive {
                AdManager.shared.showInterstitialAd()
            }
        }

        // MARK: - Persist current game
        do {
            try persistence.saveGame(updatedGame)
        } catch {
            errorMessage = "Failed to save game: \(error.localizedDescription)"
        }

        #if DEBUG
        print("✅ validateTurn -> history:", gameHistory.count, "turnCount:", turnCount, "round:", updatedGame.currentRound)
        #endif
    }

    /// Undoes the last turn
    func undoLastTurn() {
        guard !gameHistory.isEmpty else {
            errorMessage = "No moves to undo"
            return
        }

        // MARK: - Restore previous snapshot
        let previousGame = gameHistory.removeLast()
        game = previousGame

        // MARK: - Turn counter sync
        turnCount = max(0, turnCount - 1)

        // MARK: - Persist restored game
        do {
            try persistence.saveGame(previousGame)
        } catch {
            errorMessage = "Failed to save game: \(error.localizedDescription)"
        }

        #if DEBUG
        print("↩️ undoLastTurn -> history:", gameHistory.count, "turnCount:", turnCount, "round:", previousGame.currentRound)
        #endif
    }

    /// Ends the game manually
    func endGame() {
        guard var currentGame = game else {
            errorMessage = "No active game"
            return
        }

        currentGame.isOver = true
        game = currentGame

        // Archive history
        HistoryManager.shared.archiveGame(currentGame)

        // Update profiles stats
        updateProfileStats(for: currentGame)

        // Pro trial progression
        ProTrialManager.shared.incrementGamesPlayedCount()

        do {
            try persistence.saveGame(currentGame)
        } catch {
            errorMessage = "Failed to save game: \(error.localizedDescription)"
        }
    }

    // MARK: - Profiles stats

    /// Met à jour les stats des profils après une partie
    private func updateProfileStats(for game: Game) {
        let participantProfileIDs = game.players.compactMap { $0.profileId }
        guard !participantProfileIDs.isEmpty else {
            print("ℹ️ Aucun profil enregistré dans cette partie")
            return
        }

        let winners = GameEngine.determineWinners(game: game)

        let winnerProfileIDs: [UUID] = winners.compactMap { winner in
            game.players.first(where: { $0.id == winner.id })?.profileId
        }

        ProfileManager.shared.recordGame(
            participantProfileIDs: participantProfileIDs,
            winnerProfileIDs: winnerProfileIDs
        )

        print("🏆 Stats mises à jour : \(participantProfileIDs.count) profils, \(winnerProfileIDs.count) gagnant(s)")
    }

    // MARK: - Players Management (Edit in-game)

    func updatePlayers(playerSlots: [PlayerSlot]) {
        guard var currentGame = game else { return }

        // MARK: - Sanitize
        let sanitizedSlots: [PlayerSlot] = playerSlots
            .map { slot in
                var updatedSlot = slot
                updatedSlot.name = slot.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return updatedSlot
            }
            .filter { !$0.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        // MARK: - Min 2 players
        guard sanitizedSlots.count >= 2 else {
            errorMessage = "Il faut au moins 2 joueurs."
            return
        }

        // MARK: - Rebuild players (keep state by index)
        var updatedPlayers: [Player] = []
        updatedPlayers.reserveCapacity(sanitizedSlots.count)

        for index in sanitizedSlots.indices {
            let slot = sanitizedSlots[index]

            if index < currentGame.players.count {
                var existingPlayer = currentGame.players[index]
                existingPlayer.name = slot.displayName
                existingPlayer.profileId = slot.profileId
                updatedPlayers.append(existingPlayer)
            } else {
                let newPlayer = Player(
                    id: UUID().uuidString,
                    name: slot.displayName,
                    score: currentGame.settings.initialValue,
                    isEliminated: false,
                    hasReachedTarget: false,
                    profileId: slot.profileId
                )
                updatedPlayers.append(newPlayer)
            }
        }

        currentGame.players = updatedPlayers
        game = currentGame

        // MARK: - Reset undo history (sinon incohérent)
        gameHistory = []

        do {
            try persistence.saveGame(currentGame)
        } catch {
            errorMessage = "Failed to save game: \(error.localizedDescription)"
        }
    }

    // MARK: - Undo availability
    var canUndo: Bool {
        !gameHistory.isEmpty
    }

    // MARK: - Game State

    func resetGame() {
        game = nil
        gameHistory = []
        errorMessage = nil
        turnCount = 0
        persistence.deleteGame()
    }

    private func loadSavedGame() {
        if let savedGame = persistence.loadGame() {
            game = savedGame

            // MARK: - Sync turnCount from saved game
            // Hypothèse: currentRound démarre à 1.
            turnCount = max(0, savedGame.currentRound - 1)

            #if DEBUG
            print("📦 loadSavedGame -> round:", savedGame.currentRound, "turnCount:", turnCount)
            #endif
        }
    }

    func createRematch() {
        guard let currentGame = game else {
            errorMessage = "No game to rematch"
            return
        }

        let playerNames = currentGame.players.map { $0.name }
        let profileIds = currentGame.players.map { $0.profileId }

        createGame(
            settings: currentGame.settings,
            presetId: currentGame.presetId,
            playerNames: playerNames,
            profileIds: profileIds
        )
    }
}
