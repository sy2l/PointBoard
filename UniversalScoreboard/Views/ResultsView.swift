/*
 * ResultsView.swift
 * PointBoard
 *
 * Vue d'affichage des résultats finaux
 *
 * Fonctionnalités :
 * - Header identité du jeu terminé (icône + nom + couleur preset)
 * - Section Vainqueurs (get-only)
 * - Tri Survie / Score + Liste
 * - Footer actions : Partage -> icon picker -> SharePreviewView (fiable)
 * - Menu / Revanche
 *
 * Fix IMPORTANT (bug écran bloqué "Préparation du partage…") :
 * - On n’utilise PLUS un bool + optional pour présenter la preview.
 * - On utilise `.fullScreenCover(item:)` avec un payload non-nil => 100% fiable.
 *
 * Fix navigation (23/02/2026):
 * - ResultsView NE DOIT PAS embarquer son propre NavigationStack
 *   si elle est poussée depuis un NavigationStack parent (ex: GameView -> navigationDestination).
 * - Conserver NavigationStack uniquement pour les sheets/modals (ex: icon picker).
 *
 * Updated on 12/02/2026 — Share flow reliability (item-based routing)
 */

import SwiftUI

// MARK: - Results View
struct ResultsView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeManager = StoreManager.shared

    // MARK: - State
    @State private var sortBy: SortMode = .survival

    // Share flow
    @State private var selectedShareIcon: ShareManager.ShareIcon = .trophy
    @State private var showIconPicker: Bool = false
    @State private var sharePayload: SharePayload? = nil

    // Ads / advanced stats
    @State private var showStatsAdAlert: Bool = false
    @State private var showAdvancedStats: Bool = false

    enum SortMode {
        case survival
        case score
    }

    // MARK: - Payload
    struct SharePayload: Identifiable {
        let id = UUID()
        let result: GameResult
        let icon: ShareManager.ShareIcon
        let themeColor: Color
    }

    // MARK: - Theme
    private var currentTheme: PresetID { viewModel.game?.presetId ?? .generic }
    private var themeColor: Color { currentTheme.themeColor }
    private var gameName: String { PresetManager.preset(for: currentTheme).displayName }

    // MARK: - Body
    var body: some View {
        if let game = viewModel.game {
            VStack(spacing: 20) {

                header

                winnersSection(game: game)

                sortAndList(game: game)

                footer(game: game)
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .tint(themeColor)
            .background(Color.appBackground.ignoresSafeArea())

            // MARK: - Icon picker
            .sheet(isPresented: $showIconPicker) {
                ShareIconPickerView(
                    selectedIcon: $selectedShareIcon,
                    primaryColor: themeColor,
                    onContinue: { openSharePreview(game: game) }
                )
                .presentationDetents([.medium])
            }

            // MARK: - Share preview (FIABLE)
            .fullScreenCover(item: $sharePayload) { payload in
                SharePreviewView(
                    result: payload.result,
                    icon: payload.icon,
                    themeColor: payload.themeColor
                )
            }

            // MARK: - Advanced Stats Sheet
            .sheet(isPresented: $showAdvancedStats) {
                if let game = viewModel.game {
                    AdvancedStatsView(game: game, themeColor: themeColor)
                }
            }

        } else {
            ContentUnavailableView("Aucune partie", systemImage: "gamecontroller.fill")
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("Résultats Finaux")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack(spacing: Spacing.sm) {
                Image(systemName: currentTheme.iconName)
                Text(gameName)
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(themeColor)
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - Winners
    @ViewBuilder
    private func winnersSection(game: Game) -> some View {
        let winners = game.winners
        if !winners.isEmpty {
            VStack(spacing: 12) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(themeColor)
                    Text("Vainqueurs")
                        .font(.headline)
                }

                ForEach(winners) { player in
                    HStack {
                        Text(player.name)
                            .font(.title3)

                        Spacer()

                        Text("\(player.score)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    .padding()
                    .background(themeColor.opacity(0.15))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeColor, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    // MARK: - Sort + List
    private func sortAndList(game: Game) -> some View {
        VStack(spacing: 0) {
            Picker("Trier par", selection: $sortBy) {
                Text("Survie").tag(SortMode.survival)
                Text("Score").tag(SortMode.score)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.sm)

            List {
                ForEach(sortedPlayers(game)) { player in
                    PlayerResultRow(player: player)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
    }

    // MARK: - Footer
    private func footer(game: Game) -> some View {
        VStack(spacing: 12) {

            Button {
                showIconPicker = true
            } label: {
                Label("Partager les résultats", systemImage: "square.and.arrow.up")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeColor.opacity(0.10))
                    .foregroundColor(themeColor)
                    .cornerRadius(12)
            }

            if !storeManager.isProUser && !ProTrialManager.shared.isTrialActive {
                Button {
                    showStatsAdAlert = true
                } label: {
                    Label("Voir les stats avancées", systemImage: "chart.bar.fill")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.info.opacity(0.1))
                        .foregroundColor(Color.info)
                        .cornerRadius(12)
                }
                .alert("Stats avancées", isPresented: $showStatsAdAlert) {
                    Button("Devenir Pro", role: .none) {
                        // TODO: ouvrir paywall Pro
                    }
                    Button("Regarder une vidéo", role: .none) {
                        AdManager.shared.showRewardedAd { success in
                            if success { showAdvancedStats = true }
                        }
                    }
                    Button("Annuler", role: .cancel) {}
                } message: {
                    Text("Passez à Pro pour accéder aux stats avancées ou regardez une vidéo.")
                }
            } else {
                // Utilisateurs Pro ou en essai : accès direct
                Button {
                    showAdvancedStats = true
                } label: {
                    Label("Voir les stats avancées", systemImage: "chart.bar.fill")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.info.opacity(0.1))
                        .foregroundColor(Color.info)
                        .cornerRadius(12)
                }
            }

            HStack(spacing: 12) {

                Button {
                    viewModel.resetGame()
                    dismiss()
                } label: {
                    Text("Menu")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }

                Button {
                    viewModel.createRematch()
                    dismiss()
                } label: {
                    Label("Revanche", systemImage: "arrow.clockwise")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: themeColor.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color(.systemBackground))
        .shadow(color: Color.cardShadow, radius: 10, x: 0, y: -5)
    }

    // MARK: - Sorting
    private func sortedPlayers(_ game: Game) -> [Player] {
        let lowestIsBest = game.settings.lowestScoreIsBest
        
        switch sortBy {
        case .survival:
            return game.players.sorted { p1, p2 in
                // D'abord les non-éliminés
                if p1.isEliminated != p2.isEliminated {
                    return !p1.isEliminated && p2.isEliminated
                }
                
                // Ensuite les gagnants
                if p1.hasReachedTarget != p2.hasReachedTarget {
                    return p1.hasReachedTarget && !p2.hasReachedTarget
                }
                
                // Enfin tri par score selon le mode
                if lowestIsBest {
                    return p1.score < p2.score
                } else {
                    return p1.score > p2.score
                }
            }
        case .score:
            if lowestIsBest {
                return game.players.sorted { $0.score < $1.score }
            } else {
                return game.players.sorted { $0.score > $1.score }
            }
        }
    }

    // MARK: - Share routing (FIABLE)
    private func openSharePreview(game: Game) {
        let resultToShare =
            HistoryManager.shared.loadHistory().first { $0.id == game.id }
            ?? GameResult(from: game)

        // ✅ On pose le payload après fermeture sheet
        DispatchQueue.main.async {
            sharePayload = SharePayload(
                result: resultToShare,
                icon: selectedShareIcon,
                themeColor: themeColor
            )
        }
    }
}

// MARK: - Player Result Row
struct PlayerResultRow: View {
    let player: Player

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(statusColor)
                    .fontWeight(.medium)
            }

            Spacer()

            Text("\(player.score)")
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
        }
        .padding(.vertical, 8)
        .opacity(player.isEliminated ? 0.5 : 1.0)
    }

    private var statusText: String {
        if player.hasReachedTarget { return "Vainqueur" }
        if player.isEliminated { return "Éliminé" }
        return "En jeu"
    }

    private var statusColor: Color {
        if player.hasReachedTarget { return .green }
        if player.isEliminated { return .red }
        return .gray
    }
}

// MARK: - Share Icon Picker View
struct ShareIconPickerView: View {

    @Binding var selectedIcon: ShareManager.ShareIcon
    let primaryColor: Color
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {

                Text("Choisissez une icône")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, Spacing.lg)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: Spacing.lg
                ) {
                    ForEach(ShareManager.ShareIcon.allCases, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            VStack(spacing: Spacing.md) {
                                Text(icon.emoji)
                                    .font(.system(size: 60))

                                Text(iconName(for: icon))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(
                                selectedIcon == icon
                                ? primaryColor.opacity(0.18)
                                : Color(.systemGray6)
                            )
                            .cornerRadius(CornerRadius.lg)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .stroke(
                                        selectedIcon == icon ? primaryColor : Color.clear,
                                        lineWidth: 3
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()

                Button {
                    // ✅ On ferme, puis on continue
                    dismiss()
                    DispatchQueue.main.async { onContinue() }
                } label: {
                    Text("Continuer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(CornerRadius.lg)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    private func iconName(for icon: ShareManager.ShareIcon) -> String {
        switch icon {
        case .trophy: return "Trophée"
        case .crown: return "Couronne"
        case .target: return "Cible"
        case .star: return "Étoile"
        }
    }
}

// MARK: - ResultsView Preview
#Preview {
    ResultsView()
        .environmentObject({
            let vm = GameViewModel()

            let settings = GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )

            let game = Game(
                id: UUID().uuidString,
                presetId: .skyjo,
                settings: settings,
                players: [
                    Player(id: "1", name: "Alice", score: 120, isEliminated: false, hasReachedTarget: true, profileId: nil),
                    Player(id: "2", name: "Bob", score: 85, isEliminated: false, hasReachedTarget: false, profileId: nil),
                    Player(id: "3", name: "Charlie", score: 105, isEliminated: true, hasReachedTarget: false, profileId: nil),
                    Player(id: "4", name: "David", score: 72, isEliminated: false, hasReachedTarget: false, profileId: nil),
                    Player(id: "5", name: "Emma", score: 66, isEliminated: false, hasReachedTarget: false, profileId: nil)
                ],
                isOver: true
            )

            vm.game = game
            return vm
        }())
}
