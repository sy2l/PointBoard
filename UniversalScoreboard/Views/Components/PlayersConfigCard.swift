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
        HStack(spacing: Spacing.sm) {
            // -----------------------------------------------------------------
            // MARK: - Carte affichage joueurs (gauche) - Style 3D non cliquable
            // -----------------------------------------------------------------
            HStack(spacing: Spacing.md) {
                // Icône joueurs
                Image(systemName: "person.2.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
                
                // Nombre de joueurs
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(playerSlots.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("joueur\(playerSlots.count > 1 ? "s" : "")")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(
                // Dégradé vert (gaming)
                LinearGradient(
                    colors: [
                        Color.accentGreen.opacity(0.9),
                        Color.accentGreen
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            .shadow(
                color: Color.accentGreen.opacity(0.5),
                radius: 12,
                x: 0,
                y: 8
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: 6,
                x: 0,
                y: 4
            )
            
            // -----------------------------------------------------------------
            // MARK: - Bouton ajouter joueur (droite) - Rouge avec effet 3D
            // -----------------------------------------------------------------
            Button(action: {
                // Ajoute directement un nouveau joueur
                addNewPlayer()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Ajouter")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 100)
                .padding(.vertical, Spacing.lg)
                .background(
                    // Dégradé rouge
                    LinearGradient(
                        colors: [
                            Color.accentRed.opacity(0.9),
                            Color.accentRed
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.6),
                                    .white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 3
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
                .shadow(
                    color: Color.accentRed.opacity(0.5),
                    radius: 12,
                    x: 0,
                    y: 8
                )
                .shadow(
                    color: Color.black.opacity(0.25),
                    radius: 6,
                    x: 0,
                    y: 4
                )
            }
            .buttonStyle(.plain)
            .disabled(!canAddPlayer)
            .opacity(canAddPlayer ? 1.0 : 0.5)
        }
    }
    
    // MARK: - Helpers
    
    private func addNewPlayer() {
        guard canAddPlayer else { return }
        
        let newPlayerNumber = playerSlots.count + 1
        let newPlayer = PlayerSlot(name: "Joueur \(newPlayerNumber)")
        playerSlots.append(newPlayer)
    }
    
    // MARK: - Sheet 2 builder (conservé pour compatibilité)
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
