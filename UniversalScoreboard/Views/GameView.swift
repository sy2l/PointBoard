/*
 * GameView.swift
 * PointBoard
 *
 * Vue principale du jeu en cours
 *
 * Fonctionnalités:
 * - Theming automatique (Preset)
 * - Gestion scores / deltas
 * - Edition joueurs via AddPlayerSheet (pendant la partie)
 * - Règles via RulesSheet
 *
 * Fix navigation (23/02/2026):
 * - GameView NE DOIT PAS embarquer son propre NavigationStack
 *   si elle est poussée depuis un NavigationStack parent (ex: MainTabView -> SetupView).
 * - Conserver NavigationStack uniquement dans les sheets (modals) qui ont besoin d'une barre.
 */

import SwiftUI
import UIKit

// MARK: - Game View
struct GameView: View {

    // MARK: - Dependencies
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var storeManager = StoreManager.shared

    // MARK: - State
    @State private var deltas: [String: Int] = [:]
    @State private var showResults: Bool = false
    @State private var showInProgressResults: Bool = false

    // MARK: - Rules sheet (snapshot)
    @State private var showRules: Bool = false
    @State private var rulesPresetSnapshot: PresetID? = nil

    // MARK: - Players edit sheets
    @State private var showEditPlayersSheet: Bool = false
    @State private var showProfilePickerSheet: Bool = false
    @State private var profilePickerTargetSlotId: UUID? = nil
    @State private var profilePickerSelectedProfile: PlayerProfile? = nil
    @State private var editingPlayerSlots: [PlayerSlot] = []

    // MARK: - Delta sheet
    @State private var editingPlayerId: String? = nil
    @State private var editingText: String = ""
    @State private var editingIsNegative: Bool = false
    private var isDeltaSheetPresented: Bool { editingPlayerId != nil }

    // MARK: - UI Feedback
    @State private var showUndoUnavailableAlert: Bool = false

    // MARK: - Computed
    private var currentTheme: PresetID {
        viewModel.game?.presetId ?? .generic
    }

    /// Affichage uniquement à partir du tour 2 (ton requirement)
    private var canShowUndoButton: Bool {
        guard let game = viewModel.game else { return false }
        return game.currentRound > 1
    }

    /// Undo réellement possible (technique)
    private var canActuallyUndo: Bool {
        viewModel.canUndo
    }

    // MARK: - UI constants (basés sur DesignSystem)
    private let headerPaddingV: CGFloat = Spacing.sm
    private let headerPaddingH: CGFloat = Spacing.lg
    private let stackSpacing: CGFloat = Spacing.lg

    private let primaryButtonHeight: CGFloat = Spacing.xxl + Spacing.xxl
    private let squareButtonSize: CGFloat = Spacing.xxl + Spacing.xxl

    // MARK: - Body
    var body: some View {
        if let game = viewModel.game {
            VStack(spacing: stackSpacing) {

                // MARK: - Header
                roundHeader(game: game)

                // MARK: - Players List
                playersList(game: game)

                // MARK: - Actions
                actionButtons(themeColor: currentTheme.themeColor)
            }
            .padding(.top, Spacing.sm)
            .tint(currentTheme.themeColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarLeading
                toolbarTitle
                toolbarMenu
            }
            .navigationDestination(isPresented: $showResults) {
                ResultsView()
                    .environmentObject(viewModel)
            }

            // MARK: - Lifecycle
            .onAppear { initializeDeltas() }
            .onChange(of: viewModel.game?.isOver) { _, isOver in
                if isOver == true { showResults = true }
            }

            // MARK: - Sheets
            .sheet(isPresented: $showInProgressResults) {
                InProgressResultsView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
            }

            .sheet(isPresented: $showRules, onDismiss: {
                rulesPresetSnapshot = nil
            }) {
                let id = rulesPresetSnapshot ?? currentTheme
                if let rules = RulesManager.shared.getRules(for: id) {
                    RulesSheet(gameRules: rules, themeColor: id.themeColor)
                } else {
                    VStack(spacing: Spacing.md) {
                        Text("Pas de règles disponibles pour ce jeu.")
                            .font(.bodyText)
                        Text("presetId = \(id.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.lg)
                }
            }

            .sheet(isPresented: $showEditPlayersSheet) {
                // ⚠️ Pas de dépendance à une prop incertaine (isPro)
                let maxPlayers = 10
                let canAdd = editingPlayerSlots.count < maxPlayers

                AddPlayerSheet(
                    playerSlots: $editingPlayerSlots,
                    maxPlayers: maxPlayers,
                    canAddPlayer: canAdd,
                    availableProfiles: profileManager.profiles,
                    onTapPickProfile: { slotId in
                        profilePickerTargetSlotId = slotId
                        profilePickerSelectedProfile = nil
                        showProfilePickerSheet = true
                    },
                    onClose: {
                        applyEditedPlayersAndClose()
                    }
                )
                .presentationDetents([.medium, .large])
            }

            .sheet(isPresented: $showProfilePickerSheet, onDismiss: {
                if let profile = profilePickerSelectedProfile,
                   let slotId = profilePickerTargetSlotId {
                    applyPickedProfile(profile, to: slotId)
                }
                profilePickerTargetSlotId = nil
                profilePickerSelectedProfile = nil
            }) {
                ProfileSelectionView(
                    selectedProfile: $profilePickerSelectedProfile,
                    disabledProfileIDs: disabledProfileIDsForProfilePicker
                )
            }

            .sheet(
                isPresented: Binding(
                    get: { isDeltaSheetPresented },
                    set: { newValue in
                        if !newValue { editingPlayerId = nil }
                    }
                )
            ) {
                DeltaInputSheetKeypad(
                    themeColor: currentTheme.themeColor,
                    playerName: editingPlayerName,
                    valueText: $editingText,
                    isNegative: $editingIsNegative,
                    onClose: { applyDeltaEditAndClose() }
                )
                .presentationDetents([.fraction(0.65), .large])
            }

            // MARK: - Alert
            .alert("Impossible d’annuler", isPresented: $showUndoUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Aucun tour précédent n’est disponible à annuler pour le moment.")
            }

        } else {
            ContentUnavailableView("Aucune partie", systemImage: "gamecontroller.fill")
        }
    }

    // MARK: - Toolbar

    private var toolbarTitle: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: Spacing.xs) {
                Text("Partie en cours")
                    .font(.cardTitle)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: currentTheme.iconName)
                    Text(PresetManager.preset(for: currentTheme).displayName)
                }
                .font(.caption)
                .foregroundColor(currentTheme.themeColor)
                .fontWeight(.medium)
            }
        }
    }

    private var toolbarLeading: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if canShowUndoButton {
                Button {
                    // MARK: - Undo
                    performUndoLastTurn()
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Annuler")
                    }
                    .font(.cardSubtitle)
                }
                // ✅ Le bouton est visible dès tour 2, mais activé seulement si l'undo est réellement possible
                .disabled(!canActuallyUndo)
                .buttonStyle(.bordered)
                .tint(.secondary)
                .opacity(canActuallyUndo ? 1.0 : 0.4)
            }
        }
    }

    private var toolbarMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    openEditPlayersSheet()
                } label: {
                    Label("Modifier joueurs", systemImage: "person.2.fill")
                }

                Button(role: .destructive) {
                    viewModel.endGame()
                    showResults = true
                } label: {
                    Label("Finir la partie", systemImage: "flag.checkered")
                }

            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(currentTheme.themeColor)
            }
        }
    }

    // MARK: - Subviews

    private func roundHeader(game: Game) -> some View {
        HStack(spacing: Spacing.md) {

            HStack(spacing: Spacing.sm) {
                Text("Tour")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(game.currentRound)")
                    .font(.appTitle)
                    .foregroundColor(currentTheme.themeColor)
            }
            .frame(height: primaryButtonHeight)

            Spacer()

            gameInfoBadge(game: game)

            if currentTheme != .generic {
                Button {
                    rulesPresetSnapshot = currentTheme
                    showRules = true
                } label: {
                    Text("Règles")
                        .font(.caption)
                        .foregroundColor(currentTheme.themeColor)
                }
            }
        }
        .padding(.horizontal, headerPaddingH)
        .padding(.vertical, headerPaddingV)
        .background(currentTheme.backgroundWithOpacity)
    }

    @ViewBuilder
    private func gameInfoBadge(game: Game) -> some View {
        let initialValue = game.settings.initialValue
        let targetValue = game.settings.target.value

        let isElimination = isEliminationMode(for: game)
        let victoriesText = victoriesLabel(for: game)

        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "target")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(initialValue) → \(targetValue)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            .foregroundColor(.secondary)

            Text("•")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                Image(systemName: isElimination ? "person.fill.xmark" : "trophy.fill")
                    .font(.caption)

                Text(isElimination ? "Élimination" : victoriesText)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isElimination ? .error : currentTheme.themeColor)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color(.systemBackground).opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous))
    }

    private func playersList(game: Game) -> some View {
        List {
            ForEach(game.players) { player in
                PlayerScoreRow(
                    player: player,
                    delta: bindingForPlayer(player.id),
                    isActive: player.isActive,
                    themeColor: currentTheme.themeColor,
                    onTapDelta: { beginDeltaEdit(for: player.id) }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }

    private func actionButtons(themeColor: Color) -> some View {
        HStack(spacing: Spacing.md) {

            Button(action: { showInProgressResults = true }) {
                Image(systemName: "list.number")
                    .font(.cardTitle)
                    .frame(width: squareButtonSize, height: squareButtonSize)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            }

            Button(action: { validateTurn() }) {
                HStack(spacing: Spacing.sm) {
                    Text("Valider le Tour")
                        .font(.bodyText)
                        .fontWeight(.bold)
                    Image(systemName: "checkmark.circle.fill")
                }
                .frame(maxWidth: .infinity)
                .frame(height: primaryButtonHeight)
                .background(themeColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
                .shadow(
                    color: themeColor.opacity(0.3),
                    radius: AppShadow.card.radius,
                    x: AppShadow.card.x,
                    y: AppShadow.card.y
                )
            }
        }
        .padding(Spacing.lg)
    }

    // MARK: - Undo Action

    private func performUndoLastTurn() {
        guard canActuallyUndo else {
            showUndoUnavailableAlert = true
            return
        }

        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
            viewModel.undoLastTurn()
            initializeDeltas()
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Delta helpers

    private func bindingForPlayer(_ playerId: String) -> Binding<Int> {
        Binding(
            get: { deltas[playerId] ?? 0 },
            set: { deltas[playerId] = $0 }
        )
    }

    private func initializeDeltas() {
        deltas = [:]
        for player in viewModel.game?.players ?? [] {
            deltas[player.id] = 0
        }
    }

    private func validateTurn() {
        withAnimation {
            viewModel.validateTurn(deltas: deltas)
            initializeDeltas()
        }
    }

    private func beginDeltaEdit(for playerId: String) {
        let current = deltas[playerId] ?? 0
        editingPlayerId = playerId
        editingIsNegative = current < 0

        let absValue = abs(current)
        editingText = absValue == 0 ? "" : "\(absValue)"
    }

    private func applyDeltaEditAndClose() {
        guard let playerId = editingPlayerId else { return }

        let digitsOnly = editingText.filter { $0.isNumber }
        let value = Int(digitsOnly) ?? 0

        deltas[playerId] = (editingIsNegative && value != 0) ? -value : value

        editingText = ""
        editingIsNegative = false
        editingPlayerId = nil
    }

    private var editingPlayerName: String {
        guard
            let game = viewModel.game,
            let id = editingPlayerId,
            let player = game.players.first(where: { $0.id == id })
        else { return "" }
        return player.name
    }

    // MARK: - Players editing helpers

    private func openEditPlayersSheet() {
        guard let game = viewModel.game else { return }

        editingPlayerSlots = game.players.map { player in
            let profile = profileManager.profiles.first(where: { $0.id == player.profileId })
            if let profile {
                return PlayerSlot(name: profile.name, profile: profile)
            } else {
                return PlayerSlot(name: player.name, profile: nil)
            }
        }

        showEditPlayersSheet = true
    }

    private func applyEditedPlayersAndClose() {
        viewModel.updatePlayers(playerSlots: editingPlayerSlots)
        initializeDeltas()
        showEditPlayersSheet = false
    }

    private func applyPickedProfile(_ profile: PlayerProfile, to slotId: UUID) {
        guard let index = editingPlayerSlots.firstIndex(where: { $0.id == slotId }) else { return }
        var slot = editingPlayerSlots[index]
        slot.profile = profile
        slot.name = profile.name
        editingPlayerSlots[index] = slot
    }

    private var disabledProfileIDsForProfilePicker: Set<UUID> {
        Set(editingPlayerSlots.compactMap { $0.profileId })
    }

    // MARK: - Helpers (Game Info)

    private func isEliminationMode(for game: Game) -> Bool {
        let isEliminatedConsequence = (game.settings.target.consequence == .eliminated)
        let isRemainingPlayersEnd = (game.settings.endCondition.type == .remainingPlayers)
        return isEliminatedConsequence || isRemainingPlayersEnd
    }

    private func victoriesLabel(for game: Game) -> String {
        let endValue = game.settings.endCondition.value
        if endValue > 1 { return "Victoires : \(endValue)" }
        if endValue == 1 { return "Victoire : 1" }
        return "Victoire"
    }
}

// MARK: - Player Score Row
struct PlayerScoreRow: View {

    // MARK: - Properties
    let player: Player
    @Binding var delta: Int
    let isActive: Bool
    let themeColor: Color
    let onTapDelta: () -> Void

    // MARK: - UI constants (DesignSystem)
    private let rowSpacing: CGFloat = Spacing.md
    private let headerSpacing: CGFloat = Spacing.md
    private let controlHeight: CGFloat = Spacing.xxl + Spacing.sm
    private let pillCornerRadius: CGFloat = CornerRadius.lg

    var body: some View {
        VStack(spacing: rowSpacing) {

            HStack(spacing: headerSpacing) {

                VStack(spacing: Spacing.xs) {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                    Text("\(player.score)")
                        .font(.cardTitle)
                }
                .foregroundColor(.secondary)

                Spacer()

                Text(player.name)
                    .font(.cardTitle)

                Spacer()

                Button(action: onTapDelta) {
                    Text(delta > 0 ? "+\(delta)" : "\(delta)")
                        .font(.cardTitle)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .frame(minWidth: Spacing.xxl)
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }

            if isActive {
                deltaControlsRow
            } else {
                statusBadge
            }
        }
        .padding(Spacing.lg)
        .modernCardStyle()
    }

    // MARK: - Subviews

    private var deltaControlsRow: some View {
        HStack(spacing: Spacing.md) {

            deltaPillButton(
                title: "-5",
                textColor: .textSecondary,
                borderColor: Color.textSecondary.opacity(0.15),
                fillColor: Color.cardBackground
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                delta -= 5
            }

            deltaPillButton(
                title: "+5",
                textColor: Color.accentGreen,
                borderColor: Color.accentGreen.opacity(0.50),
                fillColor: Color.cardBackground
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                delta += 5
            }

            deltaPillButton(
                systemImage: "minus",
                textColor: .textSecondary,
                borderColor: .clear,
                fillColor: Color.textSecondary.opacity(0.15)
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                delta -= 1
            }

            deltaPillButton(
                systemImage: "plus",
                textColor: Color.accentGreen,
                borderColor: .clear,
                fillColor: Color.accentGreen.opacity(0.20)
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                delta += 1
            }
        }
    }

    private func deltaPillButton(
        title: String? = nil,
        systemImage: String? = nil,
        textColor: Color = .primary,
        borderColor: Color = Color(.systemGray4),
        fillColor: Color = Color.cardBackground,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.bodyText.weight(.bold))
                        .foregroundColor(textColor)
                }
                if let title {
                    Text(title)
                        .font(.bodyText.weight(.bold))
                        .foregroundColor(textColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: controlHeight)
            .background(
                RoundedRectangle(cornerRadius: pillCornerRadius, style: .continuous)
                    .fill(fillColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: pillCornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: pillCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(player.isEliminated ? "Éliminé" : "Vainqueur")
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                player.isEliminated
                ? Color.error.opacity(0.12)
                : Color.success.opacity(0.12)
            )
            .foregroundColor(player.isEliminated ? .error : .success)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous))
    }
}

// MARK: - Delta Input Sheet (Custom keypad)
private struct DeltaInputSheetKeypad: View {

    let themeColor: Color
    let playerName: String
    @Binding var valueText: String
    @Binding var isNegative: Bool
    let onClose: () -> Void

    @Environment(\.dismiss) private var dismiss

    private let keys: [[Key]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.sign, .digit("0"), .backspace],
    ]

    private let keypadSpacing: CGFloat = Spacing.md
    private let keypadKeyHeight: CGFloat = Spacing.xxl + Spacing.lg
    private let keypadCornerRadius: CGFloat = CornerRadius.md

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {

                Text(previewText)
                    .font(.appTitle)
                    .monospacedDigit()
                    .foregroundColor(previewColor)
                    .padding(.top, Spacing.xl)

                VStack(spacing: keypadSpacing) {
                    ForEach(keys.indices, id: \.self) { row in
                        HStack(spacing: keypadSpacing) {
                            ForEach(keys[row].indices, id: \.self) { col in
                                keyButton(keys[row][col])
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()

                Button(action: confirm) {
                    Text("OK")
                        .font(.bodyText)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.xxl + Spacing.xxl)
                        .background(themeColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
            }
            .navigationTitle("Saisie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(playerName)
                        .font(.bodyText)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { cancel() }
                        .font(.bodyText)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColor)
                }
            }
        }
    }

    // MARK: - Keypad

    private func keyButton(_ key: Key) -> some View {
        Button(action: { handle(key) }) {
            ZStack {
                RoundedRectangle(cornerRadius: keypadCornerRadius, style: .continuous)
                    .fill(Color(.systemGray6))

                switch key {
                case .digit(let valueString):
                    Text(valueString)
                        .font(.cardTitle)
                        .foregroundColor(.primary)

                case .backspace:
                    Image(systemName: "delete.left")
                        .font(.bodyText.weight(.semibold))
                        .foregroundColor(.primary)

                case .sign:
                    Text("−")
                        .font(.appTitle)
                        .foregroundColor(isNegative ? .error : .secondary)
                }
            }
            .frame(height: keypadKeyHeight)
        }
        .buttonStyle(.plain)
    }

    private func handle(_ key: Key) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        switch key {
        case .digit(let valueString):
            if valueText == "0" { valueText = valueString }
            else { valueText.append(valueString) }

            let maxDigits = Int(Spacing.sm)
            if valueText.count > maxDigits {
                valueText = String(valueText.prefix(maxDigits))
            }

        case .backspace:
            if !valueText.isEmpty { valueText.removeLast() }

        case .sign:
            isNegative.toggle()
        }
    }

    // MARK: - Actions

    private func cancel() { dismiss() }

    private func confirm() {
        onClose()
        dismiss()
    }

    // MARK: - Preview UI

    private var previewText: String {
        let value = Int(valueText) ?? 0
        if value == 0 { return "0" }
        return isNegative ? "-\(value)" : "+\(value)"
    }

    private var previewColor: Color {
        let value = Int(valueText) ?? 0
        if value == 0 { return .secondary }
        return isNegative ? .error : themeColor
    }

    // MARK: - Types

    private enum Key {
        case digit(String)
        case backspace
        case sign
    }
}

// MARK: - In Progress Results
struct InProgressResultsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            if let game = viewModel.game {
                List {
                    ForEach(sortedPlayers(game.players)) { player in
                        HStack(spacing: Spacing.md) {
                            Text(player.name)
                                .font(.bodyText)
                            Spacer()
                            Text("\(player.score)")
                                .font(.bodyText)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }
                .navigationTitle("Classement Actuel")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fermer") { dismiss() }
                    }
                }
            } else {
                ContentUnavailableView("Aucune partie", systemImage: "gamecontroller.fill")
            }
        }
    }

    private func sortedPlayers(_ players: [Player]) -> [Player] {
        let lowestIsBest = viewModel.game?.settings.lowestScoreIsBest ?? false
        
        return players.sorted { a, b in
            // Tri par statut d'abord (actifs avant éliminés/gagnants)
            if a.isActive != b.isActive {
                return a.isActive
            }
            
            // Ensuite tri par score selon le mode de jeu
            if lowestIsBest {
                return a.score < b.score  // Score le plus bas en premier
            } else {
                return a.score > b.score  // Score le plus haut en premier
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GameView()
        .environmentObject(
            {
                let vm = GameViewModel()
                vm.createGame(
                    settings: GameSettings.defaultSettings,
                    presetId: .generic,
                    playerNames: ["Alice", "Bob", "Charlie"]
                )
                return vm
            }()
        )
}
