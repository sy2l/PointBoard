//
//  PlayersConfigCard.swift
//  PointBoard
//
//  Composant de configuration des joueurs
//
//  Règles UX:
//  - App 100% gratuite : pas de limite de joueurs (max 99)
//  - Gestion des profils et des slots
//
//  Created by sy2l
//  Updated on 20/05/2026 — V6.2.0 : Suppression du freemium, app 100% gratuite
//

import SwiftUI

// MARK: - PlayersConfigCard
struct PlayersConfigCard: View {

    // MARK: - Bindings
    @Binding var playerSlots: [PlayerSlot]

    // MARK: - Dependencies
    @ObservedObject private var profileManager = ProfileManager.shared

    // MARK: - Sheet routing (2 sheets only)
    private enum ActiveSheet: Identifiable {
        case playersEditor
        case profiles(slotId: UUID?) // nil => page profils globale | non-nil => assignation à un slot

        var id: String {
            switch self {
            case .playersEditor:
                return "playersEditor"
            case .profiles(let slotId):
                if let slotId { return "profiles_picker_\(slotId.uuidString)" }
                return "profiles_global"
            }
        }
    }

    @State private var activeSheet: ActiveSheet? = nil

    // MARK: - Computed (App 100% gratuite - 20 joueurs max)
    private var maxPlayers: Int {
        20 // Limite app gratuite (cohérent avec AddPlayerSheet)
    }

    private var canAddPlayer: Bool {
        playerSlots.count < maxPlayers
    }

    private var playerNames: [String] {
        playerSlots.map { $0.name }
    }

    private var usedProfileIDs: Set<UUID> {
        Set(playerSlots.compactMap { $0.profileId })
    }

    private var availableProfiles: [PlayerProfile] {
        profileManager.profiles.filter { !usedProfileIDs.contains($0.id) }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: Spacing.md) {
            PlayersCard(
                playerCount: playerSlots.count,
                maxPlayers: maxPlayers,
                playerNames: playerNames,
                onAdd: { activeSheet = .playersEditor },
                onProfile: { activeSheet = .profiles(slotId: nil) }
            )
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {

            // MARK: - Sheet 1 — Joueurs (AddPlayerSheet)
            case .playersEditor:
                AddPlayerSheet(
                    playerSlots: $playerSlots,
                    canAddPlayer: canAddPlayer,
                    availableProfiles: availableProfiles,
                    onTapPickProfile: { slotId in
                        activeSheet = .profiles(slotId: slotId)
                    },
                    onClose: { activeSheet = nil }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)

            // MARK: - Sheet 2 — Profils (global ou picker)
            case .profiles(let slotId):
                profilesSheet(slotId: slotId)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Sheet 2 builder
    @ViewBuilder
    private func profilesSheet(slotId: UUID?) -> some View {
        if let slotId = slotId {
            if let slotIndex = playerSlots.firstIndex(where: { $0.id == slotId }) {
                ProfileSelectionView(
                    selectedProfile: Binding(
                        get: { playerSlots[slotIndex].profile },
                        set: { newProfile in
                            guard let profile = newProfile else { return }
                            playerSlots[slotIndex].profile = profile
                            playerSlots[slotIndex].name = profile.name
                            activeSheet = .playersEditor
                        }
                    ),
                    disabledProfileIDs: usedProfileIDs
                )
            } else {
                VStack(spacing: 12) {
                    Text("Impossible d'ouvrir la sélection de profil.")
                    Button("Fermer") { activeSheet = nil }
                }
                .padding()
            }
        } else {
            ProfileSelectionView(
                selectedProfile: .constant(nil),
                disabledProfileIDs: []
            )
        }
    }
}

// MARK: - Preview

#Preview("PlayersConfigCard — interactive (2 sheets)") {
    PlayersConfigCardPreviewWrapper()
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct PlayersConfigCardPreviewWrapper: View {

    @State private var playerSlots: [PlayerSlot] = [
        PlayerSlot(name: "Alice"),
        PlayerSlot(name: "Bob"),
        PlayerSlot(name: "Charlie"),
        PlayerSlot(name: "Diana"),
        PlayerSlot(name: "Ethan"),
        PlayerSlot(name: "Fanny") // 6
    ]

    var body: some View {
        PlayersConfigCard(playerSlots: $playerSlots)
    }
}
