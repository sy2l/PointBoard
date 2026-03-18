/*
 GameDetailView.swift
 PointBoard

 Vue détail d'une partie archivée (lecture seule).

 Fonctionnalités :
 - Affiche les informations de la partie
 - Classement final des joueurs
 - Statistiques de la partie

 Technique :
 - Vue en lecture seule (pas d'édition)
 - Similaire à ResultsView mais pour l'historique
 - NavigationStack pour le retour
 - Utilise PresetID pour le theming
 */

import SwiftUI

struct GameDetailView: View {
    let result: GameResult
    @ObservedObject private var storeManager = StoreManager.shared

    var themeColor: Color {
        return Color.appPrimary
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête
                headerSection

                // Vainqueurs
                if !result.winners.isEmpty {
                    winnersSection
                }

                // Joueurs éliminés
                if !result.eliminated.isEmpty {
                    eliminatedSection
                }

                // Joueurs actifs
                if !result.activePlayers.isEmpty {
                    activePlayersSection
                }

                // Statistiques
                statsSection
            }
            .padding()
        }
        .navigationTitle("Détails de la partie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareMenu
            }
        }
    }

    // MARK: - Sections

    private var shareMenu: some View {
        Menu {
            Button(action: {
                ShareManager.shared.shareStory(result: result)
            }) {
                Label("Partager", systemImage: "square.and.arrow.up")
            }

            if storeManager.hasAllPacksBundle {
                Button(action: {
                    ShareManager.shared.exportCSV(result: result)
                }) {
                    Label("Exporter CSV", systemImage: "doc.text")
                }
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(result.formattedDate)
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Label("\(result.players.count) joueurs", systemImage: "person.2.fill")
                Label("\(result.totalTurns) tours", systemImage: "arrow.clockwise")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Divider()
        }
    }

    private var winnersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 Vainqueurs")
                .font(.headline)
                .foregroundColor(themeColor)

            ForEach(result.winners) { player in
                PlayerResultDetailRow(player: player, highlight: true, color: themeColor)
            }
        }
    }

    private var eliminatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("❌ Éliminés")
                .font(.headline)

            ForEach(result.eliminated) { player in
                PlayerResultDetailRow(player: player, highlight: false, color: .gray)
            }
        }
    }

    private var activePlayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👥 Classement")
                .font(.headline)

            ForEach(sortedActivePlayers) { player in
                PlayerResultDetailRow(player: player, highlight: false, color: .primary)
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Statistiques")
                .font(.headline)

            VStack(spacing: 8) {
                StatRow(label: "Mode", value: result.settings.mode == .points ? "Points" : "Victoires")
                StatRow(label: "Seuil", value: "\(result.settings.target.value)")
                StatRow(label: "Score initial", value: "\(result.settings.initialValue)")
                StatRow(label: "Direction", value: result.settings.target.comparator == .greaterThanOrEqual ? "Ascendant ⬆️" : "Descendant ⬇️")
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }

    // MARK: - Helpers

    private var sortedActivePlayers: [PlayerResult] {
        result.activePlayers.sorted { player1, player2 in
            result.settings.lowestScoreIsBest ? player1.score < player2.score : player1.score > player2.score
        }
    }
}

// MARK: - Subviews

struct PlayerResultDetailRow: View {
    let player: PlayerResult
    let highlight: Bool
    let color: Color

    var body: some View {
        HStack {
            Text(player.name)
                .font(.body)
                .fontWeight(highlight ? .bold : .regular)

            Spacer()

            Text("\(player.score)")
                .font(.title3)
                .fontWeight(highlight ? .bold : .regular)
                .foregroundColor(highlight ? color : .primary)
        }
        .padding()
        .background(highlight ? color.opacity(0.1) : Color.secondary.opacity(0.05))
        .cornerRadius(10)
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameDetailView(
            result: GameResult(
                from: Game(
                    id: UUID().uuidString,
                    presetId: .generic, // <-- AJOUT DE LA CORRECTION
                    settings: GameSettings(
                        mode: .points,
                        initialValue: 0,
                        target: Target(
                            value: 100, comparator: .greaterThanOrEqual,
                            consequence: .eliminated),
                        endCondition: EndCondition(
                            type: .remainingPlayers, value: 1),
                        lowestScoreIsBest: false
                    ),
                    players: [
                        Player(
                            id: UUID().uuidString, name: "Alice", score: 105,
                            isEliminated: true),
                        Player(
                            id: UUID().uuidString, name: "Bob", score: 85,
                            isEliminated: false),
                    ],
                    currentRound: 12,
                    isOver: true
                )
            ))
    }
}
