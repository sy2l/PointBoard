//
// SetupViewModel.swift
// PointBoard
//
// Created on 20/01/2026.
//

import Foundation
import SwiftUI

@MainActor
final class SetupViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var selectedPresetID: PresetID = .generic
    @Published var customSettings: GameSettings
    @Published var playerSlots: [PlayerSlot] = []

    // MARK: - UI State
    @Published var isGameConfigExpanded: Bool = false
    @Published var isPlayersConfigExpanded: Bool = false
    @Published var showingGameSelection: Bool = false
    @Published var showingRules: Bool = false
    @Published var showingProfileCreation: Bool = false
    @Published var editingSlotId: UUID? = nil
    @Published var showingAdOrProAlert: Bool = false

    // MARK: - Dependencies
    private let profileManager: ProfileManager

    // MARK: - Computed Properties
    var selectedPreset: GamePreset {
        PresetManager.availablePresets.first { $0.id == selectedPresetID }
        ?? PresetManager.availablePresets[0]
    }

    var gameConfigSummary: String {
        let mode = customSettings.mode == .points ? "Points" : "Victoires"
        let start = customSettings.initialValue
        let end = customSettings.target.value

        if customSettings.lowestScoreIsBest {
            return "\(mode) - \(end)→\(start)"
        } else {
            return "\(mode) - \(start)→\(end)"
        }
    }

    var playersCountSummary: String {
        "\(playerSlots.count)/6 joueurs"
    }

    var playersNamesSummary: String {
        let names = playerSlots.prefix(2).map { $0.name }
        if playerSlots.count > 2 {
            return names.joined(separator: ", ") + ", ..."
        } else {
            return names.joined(separator: ", ")
        }
    }

    var usedProfileIDs: Set<UUID> {
        Set(playerSlots.compactMap { $0.profile?.id })
    }

    var canStartGame: Bool {
        playerSlots.count >= 2 && playerSlots.allSatisfy { !$0.name.isEmpty }
    }

    var defaultProfile: PlayerProfile? {
        profileManager.profiles.first
    }

    // MARK: - Initialization
    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
        self.customSettings = PresetConfiguration.presets[0].settings
        self.playerSlots = [
            PlayerSlot(name: ""),
            PlayerSlot(name: "")
        ]
    }

    // MARK: - Convenience
    convenience init() {
        self.init(profileManager: ProfileManager.shared)
    }

    // MARK: - Actions
    func selectPreset(_ presetID: PresetID) {
        selectedPresetID = presetID
        customSettings = selectedPreset.settings
    }

    func toggleGameConfig() {
        isGameConfigExpanded.toggle()
    }

    func togglePlayersConfig() {
        isPlayersConfigExpanded.toggle()
    }

    func addPlayerSlot() {
        // Limite free = 6 joueurs
        if playerSlots.count >= 6 && !StoreManager.shared.hasAllPacksBundle {
            showingAdOrProAlert = true
            return
        }
        playerSlots.append(PlayerSlot(name: ""))
    }

    func addPlayerSlotAfterAd() {
        // IMPORTANT Swift 6:
        // le callback peut être nonisolated -> on rebascule explicitement sur MainActor.
        AdManager.shared.showRewardedAd { [weak self] success in
            guard success else { return }
            guard let self else { return }

            Task { @MainActor in
                self.playerSlots.append(PlayerSlot(name: ""))
            }
        }
    }

    func removePlayerSlot(at index: Int) {
        guard playerSlots.count > 2 else { return }
        playerSlots.remove(at: index)
    }

    func selectProfile(_ profile: PlayerProfile, for slotId: UUID) {
        guard let index = playerSlots.firstIndex(where: { $0.id == slotId }) else { return }
        playerSlots[index].profile = profile
        playerSlots[index].name = profile.name
    }

    func removeProfile(from slotId: UUID) {
        guard let index = playerSlots.firstIndex(where: { $0.id == slotId }) else { return }
        playerSlots[index].profile = nil
        playerSlots[index].name = ""
    }

    func updatePlayerName(_ name: String, for slotId: UUID) {
        guard let index = playerSlots.firstIndex(where: { $0.id == slotId }) else { return }
        playerSlots[index].name = name
    }

    // MARK: - Game Creation
    func createGame() -> Game? {
        guard canStartGame else { return nil }

        let profileIds: [UUID?] = playerSlots.map { $0.profile?.id }
        let playerNames: [String] = playerSlots.map { $0.name }

        let gameEngine = GameEngine()

        return gameEngine.createGame(
            settings: customSettings,
            presetId: selectedPresetID,
            playerNames: playerNames,
            profileIds: profileIds
        )
    }
}
