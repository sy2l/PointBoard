/*
 SettingsCards.swift
 PointBoard
 
 Composants cards pour la vue Settings.
 
 Composants :
 - ProfileSettingsCard : Card pour afficher un profil dans les réglages
 - AboutCard : Card pour les informations à propos
 
 Created on 29/01/2026
 Updated on 31/03/2026 - Suppression ProStatusCard obsolète (remplacé par PremiumCard/BundleCard)
 Updated on 01/04/2026 - Version bump 5.4.2 (ajout bouton "Restaurer les achats")
 Updated on 08/04/2026 - Version bump 5.4.3 (chargement produits + alertes erreurs)
 */

import SwiftUI

// MARK: - ProfileSettingsCard
struct ProfileSettingsCard: View {
    let profile: PlayerProfile
    let isRecentlyActive: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: profile.avatar)
                .font(.title2)
                .foregroundColor(.appPrimary)
                .frame(width: 50, height: 50)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(CornerRadius.md)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: Spacing.sm) {
                    Label("\(profile.stats.gamesPlayed)", systemImage: "gamecontroller.fill")
                    Label("\(profile.stats.wins)", systemImage: "trophy.fill")
                    Text(profile.winRatePercentage)
                }
                .font(.caption)
                .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Badge si joueur actif récemment
            if isRecentlyActive {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                    .foregroundColor(.accentGreen)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - AboutCard
struct AboutCard: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Version
            HStack {
                Text("Version")
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("5.4.3")
                    .foregroundColor(.textSecondary)
            }
            
            Divider()
            
            // Site Internet
            Link(destination: URL(string: "http://pb.bmstudio.fr")!) {
                HStack {
                    Text("Site Internet")
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}
