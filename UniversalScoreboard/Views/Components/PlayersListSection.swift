//
//  PlayersListSection.swift
//  PointBoard
//
//  Created by sy2l on 02/09/2026
//  -----------------------------------------------------------------------------
//  PlayersListSection — Liste détaillée des joueurs (affichage seul)
//  -----------------------------------------------------------------------------
//  Affiche la liste complète des joueurs avec:
//  - Nom du joueur
//  - Profil assigné (si existant)
//  - Style card simple et clean
//  - Pas d'édition ici (géré dans la sheet)
//  -----------------------------------------------------------------------------

import SwiftUI

struct PlayersListSection: View {
    let playerSlots: [PlayerSlot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.textSecondary)
                Text("Liste des joueurs")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(playerSlots.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentGreen)
                    .clipShape(Capsule())
            }
            .padding(.bottom, Spacing.xs)
            
            // Liste
            ForEach(playerSlots) { slot in
                HStack(spacing: Spacing.md) {
                    // Avatar/Icône
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(slot.displayName.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.accentGreen)
                        )
                    
                    // Infos
                    VStack(alignment: .leading, spacing: 2) {
                        Text(slot.displayName)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        if let profile = slot.profile {
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.textSecondary)
                                Text(profile.name)
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        } else {
                            Text("Pas de profil")
                                .font(.caption)
                                .foregroundColor(.textSecondary.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.md)
                .shadow(color: AppShadow.card.color, radius: 2)
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius)
    }
}

// MARK: - Preview

#Preview("PlayersListSection") {
    VStack(spacing: Spacing.md) {
        PlayersListSection(playerSlots: [
            PlayerSlot(name: "Alice"),
            PlayerSlot(name: "Bob"),
            PlayerSlot(name: "Charlie"),
        ])
    }
    .padding()
    .background(Color.appBackground)
}
