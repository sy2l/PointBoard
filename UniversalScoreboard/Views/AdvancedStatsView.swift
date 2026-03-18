/*
 * AdvancedStatsView.swift
 * PointBoard
 *
 * Vue des statistiques avancées de la partie
 *
 * Fonctionnalités :
 * - Statistiques détaillées par joueur
 * - Evolution des scores tour par tour
 * - Graphiques et visualisations
 * - Réservé aux utilisateurs Pro ou après visionnage d'une pub
 *
 * Created on 08/03/2026
 */

import SwiftUI
import Charts

struct AdvancedStatsView: View {
    
    let game: Game
    let themeColor: Color
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // MARK: - Résumé de la partie
                    gameSummarySection
                    
                    // MARK: - Statistiques par joueur
                    playersStatsSection
                    
                    // MARK: - Distribution des scores
                    scoreDistributionSection
                    
                    // MARK: - Informations de partie
                    gameInfoSection
                }
                .padding(Spacing.lg)
            }
            .background(Color.appBackground)
            .navigationTitle("Stats Avancées")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Game Summary Section
    
    private var gameSummarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(themeColor)
                Text("Résumé de la Partie")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            HStack(spacing: Spacing.lg) {
                statCard(
                    title: "Tours Joués",
                    value: "\(game.currentRound - 1)",
                    icon: "arrow.clockwise"
                )
                
                statCard(
                    title: "Joueurs",
                    value: "\(game.players.count)",
                    icon: "person.2.fill"
                )
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeColor)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.md)
    }
    
    // MARK: - Players Stats Section
    
    private var playersStatsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(themeColor)
                Text("Statistiques des Joueurs")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            ForEach(sortedPlayers) { player in
                playerStatRow(player: player)
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
    }
    
    private func playerStatRow(player: Player) -> some View {
        HStack(spacing: Spacing.md) {
            // Nom du joueur
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(playerStatus(player))
                    .font(.caption)
                    .foregroundColor(playerStatusColor(player))
            }
            
            Spacer()
            
            // Score final
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text("\(player.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Score Final")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.md)
    }
    
    private func playerStatus(_ player: Player) -> String {
        if player.hasReachedTarget { return "🏆 Vainqueur" }
        if player.isEliminated { return "❌ Éliminé" }
        return "🎮 En jeu"
    }
    
    private func playerStatusColor(_ player: Player) -> Color {
        if player.hasReachedTarget { return .success }
        if player.isEliminated { return .error }
        return .textSecondary
    }
    
    private var sortedPlayers: [Player] {
        let lowestIsBest = game.settings.lowestScoreIsBest
        
        return game.players.sorted { a, b in
            // Gagnants d'abord
            if a.hasReachedTarget != b.hasReachedTarget {
                return a.hasReachedTarget
            }
            
            // Ensuite actifs
            if a.isActive != b.isActive {
                return a.isActive
            }
            
            // Enfin par score
            if lowestIsBest {
                return a.score < b.score
            } else {
                return a.score > b.score
            }
        }
    }
    
    // MARK: - Score Distribution Section
    
    private var scoreDistributionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(themeColor)
                Text("Distribution des Scores")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Chart {
                ForEach(game.players) { player in
                    BarMark(
                        x: .value("Joueur", player.name),
                        y: .value("Score", player.score)
                    )
                    .foregroundStyle(
                        player.hasReachedTarget ? Color.success :
                        player.isEliminated ? Color.error :
                        themeColor
                    )
                    .cornerRadius(CornerRadius.sm)
                }
            }
            .frame(height: 250)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { value in
                    if let name = value.as(String.self) {
                        AxisValueLabel {
                            Text(name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
    }
    
    // MARK: - Game Info Section
    
    private var gameInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(themeColor)
                Text("Informations de Partie")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: Spacing.sm) {
                infoRow(
                    title: "Mode de Jeu",
                    value: game.settings.mode == .points ? "Points" : "Manches"
                )
                
                infoRow(
                    title: "Valeur Initiale",
                    value: "\(game.settings.initialValue)"
                )
                
                infoRow(
                    title: "Cible",
                    value: "\(game.settings.target.value)"
                )
                
                infoRow(
                    title: "Objectif",
                    value: game.settings.lowestScoreIsBest ? "Score le plus bas" : "Score le plus haut"
                )
                
                infoRow(
                    title: "Conséquence Cible",
                    value: game.settings.target.consequence == .eliminated ? "Élimination" : "Victoire"
                )
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.bodyText)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.bodyText)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.sm)
    }
}

// MARK: - Preview
#Preview {
    AdvancedStatsView(
        game: Game(
            id: UUID().uuidString,
            presetId: .skyjo,
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: true
            ),
            players: [
                Player(id: "1", name: "Alice", score: 45, isEliminated: false, hasReachedTarget: false, profileId: nil),
                Player(id: "2", name: "Bob", score: 78, isEliminated: false, hasReachedTarget: false, profileId: nil),
                Player(id: "3", name: "Charlie", score: 105, isEliminated: true, hasReachedTarget: false, profileId: nil),
                Player(id: "4", name: "Diana", score: 62, isEliminated: false, hasReachedTarget: false, profileId: nil)
            ],
            currentRound: 8,
            isOver: true
        ),
        themeColor: .blue
    )
}
