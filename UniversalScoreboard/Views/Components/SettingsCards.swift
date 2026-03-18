/*
 SettingsCards.swift
 PointBoard
 
 Composants cards pour la vue Settings.
 
 Composants :
 - ProfileSettingsCard : Card pour afficher un profil dans les réglages
 - ProStatusCard : Card pour afficher le statut Pro
 - AboutCard : Card pour les informations à propos
 
 Created on 29/01/2026
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

// MARK: - ProStatusCard
struct ProStatusCard: View {
    let isPro: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            if isPro {
                // Utilisateur Pro
                Image(systemName: "crown.fill")
                    .foregroundColor(.accentGreen)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Version Pro activée")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text("Merci pour votre soutien !")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentGreen)
                    .font(.title2)
            } else {
                // Utilisateur gratuit
                VStack(alignment: .leading, spacing: 4) {
                    Text("PointBoard Pro")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text("Historique illimité • Statistiques avancées")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: onUpgrade) {
                    Text("Passer Pro")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentGreen)
                        .cornerRadius(CornerRadius.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.md)
        .background(isPro ? Color.accentGreen.opacity(0.1) : Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isPro ? Color.accentGreen.opacity(0.3) : Color.clear, lineWidth: 1)
        )
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
                Text("5.0.1")
                    .foregroundColor(.textSecondary)
            }
            
            Divider()
            
            // Site Internet
            Link(destination: URL(string: "https://google.fr")!) {
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
