//
// PlayersCard.swift
// PointBoard
//
// Extracted from ModernCards.swift
//
// Rôle :
// - Affiche la card "Joueurs" (style météo)
// - CTA "Ajouter joueur" top-right -> ouvre sheet add (onAdd)
// - CTA "Profil" (partie basse, à droite) -> ouvre sheet profils (onProfile)
//
// NOTE IMPORTANT :
// - On évite un Button imbriqué dans un Button (ça casse les taps).
// - Donc la card n'est PAS un Button : c'est une View + onTapGesture.
//   Le CTA reste un Button indépendant.
//
// Created by sy2l
// Updated on 23/01/2026 — Fix taps (no nested Button)
// Updated on 23/01/2026 — Make "Profil" CTA more visible (without bigger button)
//

import SwiftUI

// MARK: - Players Card (Style météo) — CTA "Ajouter joueur" top-right
struct PlayersCard: View {

    // MARK: - Inputs
    let playerCount: Int
    let maxPlayers: Int
    let playerNames: [String]
    let onAdd: () -> Void
    let onProfile: () -> Void

    // MARK: - Computed
    private var displayNames: String {
        let cleaned = playerNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let names = cleaned.prefix(2)
        if cleaned.count > 2 {
            return names.joined(separator: ", ") + ", ..."
        } else {
            return names.joined(separator: ", ")
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {

            // MARK: Partie haute (comme GameCard)
            ZStack(alignment: .topTrailing) {
                Color.gameGradient(for: Color.textSecondary)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.md) {

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)

                        Text("Joueurs")
                            .font(.cardTitle)
                            .foregroundColor(.white)

                        Text("\(playerCount)/\(maxPlayers) joueurs")
                            .font(.cardSubtitle)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // MARK: CTA "Ajouter joueur" (haut droite)
                    Button(action: onAdd) {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(.white)

                            Text("Ajouter\njoueur")
                                .font(.cardSubtitle)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 120, height: 120)
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(Spacing.lg)
            }
            .frame(height: 150)

            // MARK: Partie basse (grise/blanche) -> noms + CTA profil
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.2")
                    .foregroundColor(.textSecondary)

                if !displayNames.isEmpty {
                    Text(displayNames)
                        .font(.cardSubtitle)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                } else {
                    Text("—")
                        .font(.cardSubtitle)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // ✅ CTA Profil plus visible, sans grossir
                Button(action: onProfile) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle")
                            .font(.caption)

                        Text("Profil")
                            .font(.cardSubtitle)

                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .opacity(0.8)
                    }
                    .foregroundColor(.appPrimary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.cardBackground.opacity(0.35))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.appPrimary.opacity(0.25), lineWidth: 0.7)
                    )
                }
                .buttonStyle(.plain)
            }
            .font(.cardSubtitle)
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(Color.cardBackground)
        }
        .modernElevatedCardStyle()
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview("PlayersCard — 2 joueurs") {
    PlayersCard(
        playerCount: 2,
        maxPlayers: 6,
        playerNames: ["Joueur 1", "Joueur 2"],
        onAdd: {},
        onProfile: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PlayersCard — 4 joueurs") {
    PlayersCard(
        playerCount: 4,
        maxPlayers: 6,
        playerNames: ["Alice", "Bob", "Chloé", "David"],
        onAdd: {},
        onProfile: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
