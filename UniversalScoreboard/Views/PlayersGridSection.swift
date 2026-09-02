//
//  PlayersGridSection.swift
//  PointBoard
//
//  Created by sy2l on 02/09/2026
//  -----------------------------------------------------------------------------
//  PlayersGridSection — Grille de joueurs (3 par ligne max)
//  -----------------------------------------------------------------------------
//  Affiche les joueurs en cartes carrées style e-commerce:
//  - Image/Avatar en haut (carré)
//  - Nom du joueur en bas
//  - 3 cartes par ligne (LazyVGrid)
//  - Design minimaliste
//  -----------------------------------------------------------------------------

import SwiftUI

struct PlayersGridSection: View {
    @Binding var playerSlots: [PlayerSlot]
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach($playerSlots) { $slot in
                PlayerGridCard(slot: $slot, onDelete: {
                    if let index = playerSlots.firstIndex(where: { $0.id == slot.id }) {
                        playerSlots.remove(at: index)
                    }
                })
            }
        }
    }
}

// MARK: - Player Grid Card (carte individuelle)
struct PlayerGridCard: View {
    @Binding var slot: PlayerSlot
    @State private var showEditSheet: Bool = false
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Carte principale (cliquable pour éditer)
            Button(action: {
                showEditSheet = true
            }) {
                VStack(spacing: Spacing.xs) {
                    // Avatar carré (image ou initiale) avec effet 3D
                    ZStack {
                        // Fond coloré avec dégradé vertical (gaming)
                        LinearGradient(
                            colors: [
                                Color.accentGreen.opacity(0.9),
                                Color.accentGreen
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Initiale
                        Text(String(slot.displayName.prefix(1)).uppercased())
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        // Bordure intérieure brillante (PLUS ÉPAISSE)
                        RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: 4
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous))
                    .shadow(
                        color: Color.accentGreen.opacity(0.5),
                        radius: 8,
                        x: 0,
                        y: 6
                    )
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 4,
                        x: 0,
                        y: 3
                    )
                    
                    // Nom du joueur
                    Text(slot.displayName)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .buttonStyle(.plain)
            
            // Bouton "-" de suppression (en haut à gauche, JAUNE)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    onDelete()
                }
            }) {
                ZStack {
                    // Cercle jaune
                    Circle()
                        .fill(Color.accentYellow)
                    
                    // Bordure blanche
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                    
                    // Icône "-"
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 28, height: 28)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            .buttonStyle(.plain)
            .offset(x: -8, y: -8)
        }
        .sheet(isPresented: $showEditSheet) {
            PlayerEditSheet(slot: $slot)
        }
    }
}

// MARK: - Preview

#Preview("PlayersGridSection - 3 par ligne") {
    struct PreviewWrapper: View {
        @State private var slots = [
            PlayerSlot(name: "Alice"),
            PlayerSlot(name: "Bob"),
            PlayerSlot(name: "Charlie"),
            PlayerSlot(name: "Diana"),
            PlayerSlot(name: "Ethan"),
            PlayerSlot(name: "Fanny"),
            PlayerSlot(name: "George")
        ]
        
        var body: some View {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    PlayersGridSection(playerSlots: $slots)
                }
                .padding()
            }
            .background(Color.appBackground)
        }
    }
    
    return PreviewWrapper()
}

