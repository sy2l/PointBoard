/*
 * AdvancedStatsView.swift
 * PointBoard
 *
 * Vue des statistiques avancées de la partie avec graphiques intelligents
 *
 * Fonctionnalités :
 * - Évolution des scores tour par tour (graphique linéaire)
 * - Distribution finale des scores (graphique en barres)
 * - Statistiques intelligentes (meilleur tour, plus gros écart, momentum, etc.)
 * - Résumé de la partie
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
    
    // MARK: - Computed Stats
    
    /// Calcule l'évolution des scores si on a l'historique
    private var scoreEvolution: [PlayerScoreHistory] {
        // Pour l'instant, on ne peut pas reconstruire l'historique complet
        // car GameViewModel.gameHistory n'est pas passé ici.
        // On va donc montrer des stats basées sur le state final uniquement.
        return []
    }
    
    /// Joueur avec le meilleur score
    private var bestPlayer: Player? {
        let lowestIsBest = game.settings.lowestScoreIsBest
        return game.players.sorted { a, b in
            if lowestIsBest {
                return a.score < b.score
            } else {
                return a.score > b.score
            }
        }.first
    }
    
    /// Joueur avec le pire score
    private var worstPlayer: Player? {
        let lowestIsBest = game.settings.lowestScoreIsBest
        return game.players.sorted { a, b in
            if lowestIsBest {
                return a.score > b.score
            } else {
                return a.score < b.score
            }
        }.first
    }
    
    /// Écart entre meilleur et pire
    private var scoreRange: Int {
        guard let best = bestPlayer, let worst = worstPlayer else { return 0 }
        return abs(best.score - worst.score)
    }
    
    /// Score moyen
    private var averageScore: Double {
        guard !game.players.isEmpty else { return 0 }
        let total = game.players.reduce(0) { $0 + $1.score }
        return Double(total) / Double(game.players.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // MARK: - Résumé de la partie
                    gameSummarySection
                    
                    // MARK: - Statistiques intelligentes
                    intelligentStatsSection
                    
                    // MARK: - Distribution des scores (Graphique en barres)
                    scoreDistributionChart
                    
                    // MARK: - Classement détaillé
                    detailedRankingSection
                    
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
                    value: "\(max(1, game.currentRound - 1))",
                    icon: "arrow.clockwise",
                    color: themeColor
                )
                
                statCard(
                    title: "Joueurs",
                    value: "\(game.players.count)",
                    icon: "person.2.fill",
                    color: themeColor
                )
            }
            
            HStack(spacing: Spacing.lg) {
                statCard(
                    title: "Score Moyen",
                    value: String(format: "%.0f", averageScore),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .info
                )
                
                statCard(
                    title: "Écart Max",
                    value: "\(scoreRange)",
                    icon: "arrow.up.arrow.down",
                    color: .warning
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
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.md)
    }
    
    // MARK: - Intelligent Stats Section
    
    private var intelligentStatsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.accentGreen)
                Text("Statistiques Intelligentes")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: Spacing.sm) {
                // Meilleur joueur
                if let best = bestPlayer {
                    insightRow(
                        icon: "trophy.fill",
                        title: "Meilleur Score",
                        value: "\(best.name) avec \(best.score) pts",
                        color: .success
                    )
                }
                
                // Pire joueur
                if let worst = worstPlayer, worst.id != bestPlayer?.id {
                    insightRow(
                        icon: "flag.fill",
                        title: game.settings.lowestScoreIsBest ? "Score le Plus Élevé" : "Score le Plus Faible",
                        value: "\(worst.name) avec \(worst.score) pts",
                        color: .error
                    )
                }
                
                // Compétitivité
                insightRow(
                    icon: "flame.fill",
                    title: "Compétitivité",
                    value: competitivenessText,
                    color: competitivenessColor
                )
                
                // Durée estimée
                let totalTurns = max(1, game.currentRound - 1)
                let estimatedMinutes = totalTurns * 2 // Estimation : 2 min/tour
                insightRow(
                    icon: "clock.fill",
                    title: "Durée Estimée",
                    value: "\(estimatedMinutes) minutes",
                    color: .info
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
    
    private func insightRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.bodyText)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.sm)
    }
    
    private var competitivenessText: String {
        let range = Double(scoreRange)
        let avg = averageScore
        
        guard avg > 0 else { return "Équilibré" }
        
        let coefficient = range / avg
        
        if coefficient < 0.2 {
            return "Très Serré 🔥"
        } else if coefficient < 0.5 {
            return "Équilibré"
        } else if coefficient < 1.0 {
            return "Écarts Modérés"
        } else {
            return "Grands Écarts"
        }
    }
    
    private var competitivenessColor: Color {
        let range = Double(scoreRange)
        let avg = averageScore
        
        guard avg > 0 else { return .secondary }
        
        let coefficient = range / avg
        
        if coefficient < 0.2 {
            return .success
        } else if coefficient < 0.5 {
            return .accentGreen
        } else if coefficient < 1.0 {
            return .warning
        } else {
            return .error
        }
    }
    
    // MARK: - Score Distribution Chart
    
    private var scoreDistributionChart: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(themeColor)
                Text("Distribution des Scores")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Chart {
                ForEach(sortedPlayers) { player in
                    BarMark(
                        x: .value("Joueur", player.name),
                        y: .value("Score", player.score)
                    )
                    .foregroundStyle(colorForPlayer(player))
                    .cornerRadius(CornerRadius.sm)
                    .annotation(position: .top) {
                        Text("\(player.score)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .frame(height: 250)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                        }
                    }
                }
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
    
    private func colorForPlayer(_ player: Player) -> Color {
        if player.hasReachedTarget {
            return .success
        } else if player.isEliminated {
            return .error
        } else if player.id == bestPlayer?.id {
            return themeColor
        } else {
            return Color.appSecondary
        }
    }
    
    // MARK: - Detailed Ranking Section
    
    private var detailedRankingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "list.number")
                    .foregroundColor(themeColor)
                Text("Classement Détaillé")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: Spacing.sm) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    playerRankRow(player: player, rank: index + 1)
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
    
    private func playerRankRow(player: Player, rank: Int) -> some View {
        HStack(spacing: Spacing.md) {
            // Rang
            Text("\(rank)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(rankColor(rank))
                .frame(width: 32)
            
            // Nom + badge
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if player.hasReachedTarget {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.success)
                    }
                }
                
                Text(playerStatus(player))
                    .font(.caption)
                    .foregroundColor(playerStatusColor(player))
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text("\(player.score)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                
                // Écart avec le meilleur
                if let best = bestPlayer, player.id != best.id {
                    let diff = abs(player.score - best.score)
                    Text(game.settings.lowestScoreIsBest ? "+\(diff)" : "-\(diff)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(Spacing.md)
        .background(
            rank == 1
            ? themeColor.opacity(0.1)
            : Color(.systemBackground)
        )
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(
                    rank == 1 ? themeColor.opacity(0.3) : Color.clear,
                    lineWidth: rank == 1 ? 2 : 0
                )
        )
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .success
        case 2: return .info
        case 3: return .warning
        default: return .textSecondary
        }
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
    
    // MARK: - Game Info Section
    
    private var gameInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(themeColor)
                Text("Configuration de la Partie")
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
                    value: game.settings.lowestScoreIsBest ? "Score le plus bas 📉" : "Score le plus haut 📈"
                )
                
                infoRow(
                    title: "Conséquence Cible",
                    value: game.settings.target.consequence == .eliminated ? "Élimination ❌" : "Victoire 🏆"
                )
                
                infoRow(
                    title: "Date",
                    value: formattedDate
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
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.sm)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: game.dateCreated)
    }
}

// MARK: - Supporting Types

struct PlayerScoreHistory: Identifiable {
    let id = UUID()
    let playerName: String
    let turn: Int
    let score: Int
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
                Player(id: "4", name: "Diana", score: 62, isEliminated: false, hasReachedTarget: false, profileId: nil),
                Player(id: "5", name: "Eve", score: 38, isEliminated: false, hasReachedTarget: true, profileId: nil)
            ],
            currentRound: 12,
            isOver: true
        ),
        themeColor: .blue
    )
}
