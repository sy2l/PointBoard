/*
 PlayerStatsView.swift
 PointBoard
 
 Vue détaillée des statistiques d'un joueur.
 
 Fonctionnalités :
 - Affichage des stats globales (parties, victoires, taux de victoire)
 - Graphique en barres des victoires/défaites/éliminations
 - Graphique linéaire de l'évolution (placeholder pour Sprint 5)
 - Scores min/max/moyen
 
 Technique :
 - Swift Charts pour les graphiques
 - Données réactives via PlayerProfile
 - Preview avec mock data
 */

import SwiftUI
import Charts

struct PlayerStatsView: View {
    let profile: PlayerProfile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // En-tête avec avatar et nom
                profileHeader
                
                // Stats globales
                statsOverview
                
                // Graphique victoires/défaites/éliminations
                winLossChart
                
                // Scores
                scoresSection
            }
            .padding()
        }
        .navigationTitle("Statistiques")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: profile.avatar)
                .font(.system(size: 80))
                .foregroundColor(.appPrimary)
            
            Text(profile.name)
                .font(.title)
                .fontWeight(.bold)
            
            if let lastPlayed = profile.lastPlayedAt {
                Text("Dernière partie : \(lastPlayed, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appPrimary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Stats Overview
    
    private var statsOverview: some View {
        VStack(spacing: 16) {
            Text("Vue d'ensemble")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Parties",
                    value: "\(profile.stats.gamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Victoires",
                    value: "\(profile.stats.wins)",
                    icon: "trophy.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Taux",
                    value: profile.winRatePercentage,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Win/Loss Chart
    
    private var winLossChart: some View {
        VStack(spacing: 16) {
            Text("Résultats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if profile.stats.gamesPlayed > 0 {
                Chart {
                    BarMark(
                        x: .value("Type", "Victoires"),
                        y: .value("Nombre", profile.stats.wins)
                    )
                    .foregroundStyle(.green)
                    .annotation(position: .top) {
                        Text("\(profile.stats.wins)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    
                    BarMark(
                        x: .value("Type", "Défaites"),
                        y: .value("Nombre", profile.stats.gamesPlayed - profile.stats.wins - profile.stats.eliminations)
                    )
                    .foregroundStyle(.orange)
                    .annotation(position: .top) {
                        Text("\(profile.stats.gamesPlayed - profile.stats.wins - profile.stats.eliminations)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    
                    BarMark(
                        x: .value("Type", "Éliminations"),
                        y: .value("Nombre", profile.stats.eliminations)
                    )
                    .foregroundStyle(.red)
                    .annotation(position: .top) {
                        Text("\(profile.stats.eliminations)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                Text("Aucune donnée disponible")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Scores Section
    
    private var scoresSection: some View {
        VStack(spacing: 16) {
            Text("Scores")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if profile.stats.gamesPlayed > 0 {
                VStack(spacing: 12) {
                    ScoreRow(
                        label: "Score moyen",
                        value: String(format: "%.1f", profile.averageScore),
                        icon: "chart.bar.fill",
                        color: .blue
                    )
                    
                    Divider()
                    
                    ScoreRow(
                        label: "Score maximum",
                        value: "\(profile.stats.highestScore)",
                        icon: "arrow.up.circle.fill",
                        color: .green
                    )
                    
                    Divider()
                    
                    ScoreRow(
                        label: "Score minimum",
                        value: "\(profile.stats.lowestScore)",
                        icon: "arrow.down.circle.fill",
                        color: .red
                    )
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
            } else {
                Text("Aucune donnée disponible")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Score Row Component

struct ScoreRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview

#Preview("Alice - Expérimentée") {
    NavigationStack {
        PlayerStatsView(profile: .mockAlice)
    }
}

#Preview("Bob - Moyen") {
    NavigationStack {
        PlayerStatsView(profile: .mockBob)
    }
}

#Preview("Diana - Championne") {
    NavigationStack {
        PlayerStatsView(profile: .mockDiana)
    }
}

#Preview("Débutant - Aucune partie") {
    NavigationStack {
        PlayerStatsView(profile: PlayerProfile(name: "Nouveau", avatar: "person.circle.fill"))
    }
}
