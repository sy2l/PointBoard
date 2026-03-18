/*
 HistoryCard.swift
 PointBoard
 
 Composant card pour afficher une partie dans l'historique.
 
 Fonctionnalités :
 - Affichage de la date et du nombre de tours
 - Affichage des gagnants avec icône couronne
 - Tap pour voir les détails
 
 Created on 29/01/2026
 */

import SwiftUI

// MARK: - HistoryCard
struct HistoryCard: View {
    let result: GameResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header : Date + Tours
            HStack {
                Text(result.formattedDate)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                    Text("\(result.totalTurns) tours")
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appSecondary.opacity(0.1))
                .cornerRadius(CornerRadius.sm)
            }
            
            // Winners
            if !result.winners.isEmpty {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.accentGreen)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Gagnant\(result.winners.count > 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text(result.winners.map { $0.name }.joined(separator: ", "))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            
            // Chevron pour indiquer la navigation
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}


