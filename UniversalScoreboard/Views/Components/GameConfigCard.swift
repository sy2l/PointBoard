//
// GameConfigCard.swift
// PointBoard
//
// Composant de configuration du jeu
// - Affiche la card du jeu sélectionné
// - Permet d'étendre la config (mode / scores / options)
// - "Modifier config" est intégré dans la GameCard (partie basse)
// - "Changer de jeu" est en haut à droite (CTA)
// - Déclenche "Voir les règles" EN PASSANT le PresetID courant (fix robuste)
// - Defaults one-shot + édition score via clavier custom en sheet (uniquement en mode Points)
// - Mode Victoires : un seul champ "Victoires" (objectif), pas d'options, pas de clavier
//
// Created by sy2l
// Updated on 22/01/2026 — Fix "Voir les règles" (PresetID capturé au tap)
// Updated on 23/01/2026 — UI: swap "Modifier config" / "Changer de jeu"
// Updated on 23/01/2026 — Defaults + Custom keypad sheet for scores
// Updated on 23/01/2026 — Mode Victoires simplifié + Stepper fix + default wins=0
//

import SwiftUI

// MARK: - GameConfigCard
struct GameConfigCard: View {

    // MARK: - Bindings (source de vérité: SetupView)
    @Binding var selectedPresetID: PresetID
    @Binding var selectedMode: GameMode
    @Binding var customInitialValue: Int
    @Binding var customTargetValue: Int
    @Binding var isDescendingMode: Bool
    @Binding var isEliminationMode: Bool

    // MARK: - Callbacks
    let onChangeGame: () -> Void

    /// IMPORTANT :
    /// On passe explicitement le preset au parent au moment du tap.
    /// Ça évite tous les cas où une autre vue utilise un fallback (.generic)
    /// ou lit une autre source (ex: viewModel.game?.presetId).
    let onShowRules: (PresetID) -> Void

    // MARK: - State (UI)
    @State private var isExpanded = false

    // MARK: - State (Defaults one-shot)
    @State private var hasAppliedDefaults = false

    // MARK: - State (Score editor sheet)
    private enum EditableScoreField {
        case initial
        case target
    }

    @State private var isScoreEditorPresented = false
    @State private var scoreFieldToEdit: EditableScoreField = .initial

    // MARK: - Computed
    private var currentPreset: GamePreset {
        PresetConfiguration.presets.first { $0.id == selectedPresetID }
        ?? PresetConfiguration.genericPreset
    }

    private var isWinsMode: Bool { selectedMode == .wins }

    private var configSummary: String {
        if isWinsMode {
            return "Victoires - \(customTargetValue)"
        }

        let modeText = "Points"
        return isDescendingMode
            ? "\(modeText) - \(customTargetValue)→\(customInitialValue)"
            : "\(modeText) - \(customInitialValue)→\(customTargetValue)"
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: Spacing.md) {

            // MARK: Card principale du jeu (actions intégrées)
            GameCard(
                preset: currentPreset,
                configSummary: configSummary,
                themeColor: selectedPresetID.themeColor,
                isConfigExpanded: isExpanded,
                onToggleConfig: {
                    withAnimation { isExpanded.toggle() }
                },
                onChangeGame: onChangeGame
            )

            // MARK: Configuration expandable
            if isExpanded {
                VStack(spacing: Spacing.lg) {

                    // MARK: Mode de jeu
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Mode de jeu")
                            .font(.headline)

                        Picker("Mode", selection: $selectedMode) {
                            Text("Points").tag(GameMode.points)
                            Text("Victoires").tag(GameMode.wins)
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: Mode Victoires -> un seul champ "Victoires"
                    if isWinsMode {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Victoires")
                                .font(.headline)

                            HStack {
                                Text("\(customTargetValue)")
                                    .font(.title2)
                                    .foregroundColor(.appPrimary)

                                Spacer()

                                // ✅ Stepper "safe" (évite les soucis de hitbox/label vide)
                                Stepper(value: $customTargetValue, in: 0...10, step: 1) {
                                    EmptyView()
                                }
                                .labelsHidden()
                            }

                            Text("Le premier à atteindre ce nombre de victoires gagne.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                    } else {
                        // MARK: Mode Points -> initial + cible + clavier
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Score initial")
                                .font(.headline)

                            HStack {
                                Button {
                                    scoreFieldToEdit = .initial
                                    isScoreEditorPresented = true
                                } label: {
                                    Text("\(customInitialValue)")
                                        .font(.title2)
                                        .foregroundColor(.appPrimary)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(Color.cardBackground.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                Stepper("", value: $customInitialValue, in: -100...100, step: 5)
                            }
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Seuil cible")
                                .font(.headline)

                            HStack {
                                Button {
                                    scoreFieldToEdit = .target
                                    isScoreEditorPresented = true
                                } label: {
                                    Text("\(customTargetValue)")
                                        .font(.title2)
                                        .foregroundColor(.appPrimary)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(Color.cardBackground.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                Stepper("", value: $customTargetValue, in: 1...1000, step: 10)
                            }
                        }

                        // MARK: Options (Points uniquement)
                        Toggle("Score descendant", isOn: $isDescendingMode)
                        Toggle("Élimination au seuil", isOn: $isEliminationMode)
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.md)
            }

            // MARK: Card "Voir les règles"
            if selectedPresetID != .generic {
                SimpleActionCard(
                    icon: "book.fill",
                    title: "Voir les règles",
                    subtitle: "Règles du \(currentPreset.displayName)",
                    action: {
                        onShowRules(selectedPresetID)
                    }
                )
            }
        }
        // MARK: Defaults one-shot (ne reset pas les choix user)
        .onAppear {
            applyDefaultConfigIfNeeded()
            applyModeConstraintsIfNeeded()
        }
        // MARK: Ajuster automatiquement au changement de mode
        .onChange(of: selectedMode) { _, _ in
            applyModeConstraintsIfNeeded()
        }
        // MARK: Sheet score editor (uniquement en mode Points)
        .sheet(isPresented: $isScoreEditorPresented) {
            scoreEditorSheet
                .presentationDetents([.height(520)])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
        }
    }

    // MARK: - Defaults (one-shot)
    private func applyDefaultConfigIfNeeded() {
        guard !hasAppliedDefaults else { return }
        hasAppliedDefaults = true

        // Defaults demandés (Points)
        customInitialValue = 0
        customTargetValue = 100
        isEliminationMode = true

        selectedMode = .points
        isDescendingMode = false
    }

    // MARK: - Mode constraints
    private func applyModeConstraintsIfNeeded() {
        if selectedMode == .wins {
            // Victoires : état simple
            customInitialValue = 0

            // ✅ Si on vient de Points (ex: 100), on remet à 0 (comme demandé)
            if customTargetValue > 10 {
                customTargetValue = 0
            } else {
                customTargetValue = clampWins(customTargetValue)
            }

            // Options inutiles en wins
            isDescendingMode = false
            isEliminationMode = false
        } else {
            // Points : clamp simple (pas d'arrondi)
            customInitialValue = clampPointsInitial(customInitialValue)
            customTargetValue = clampPointsTarget(customTargetValue)
        }
    }

    // MARK: - Sheet builder (Points uniquement)
    @ViewBuilder
    private var scoreEditorSheet: some View {
        let title = (scoreFieldToEdit == .initial) ? "Score initial" : "Seuil cible"
        let currentValue = (scoreFieldToEdit == .initial) ? customInitialValue : customTargetValue

        ScoreValueEditorSheet(
            title: title,
            initialValue: currentValue,
            onValidate: { newValue in
                switch scoreFieldToEdit {
                case .initial:
                    customInitialValue = clampPointsInitial(newValue)
                case .target:
                    customTargetValue = clampPointsTarget(newValue)
                }
                isScoreEditorPresented = false
            },
            onClose: {
                isScoreEditorPresented = false
            }
        )
    }

    // MARK: - Clamp helpers (SANS ARRONDI)
    private func clampWins(_ value: Int) -> Int {
        min(max(value, 0), 10)
    }

    private func clampPointsInitial(_ value: Int) -> Int {
        min(max(value, -100), 100)
    }

    private func clampPointsTarget(_ value: Int) -> Int {
        min(max(value, 1), 1000)
    }
}

//
// MARK: - ScoreValueEditorSheet (Custom Keypad Sheet)
//

private struct ScoreValueEditorSheet: View {

    // MARK: - Inputs
    let title: String
    let initialValue: Int
    let onValidate: (Int) -> Void
    let onClose: () -> Void

    // MARK: - State
    @State private var workingText: String = ""

    // MARK: - Key model
    fileprivate enum Key: Hashable {
        case digit(String)
        case sign
        case backspace
    }

    // 3 colonnes, ordre ligne par ligne (demandé)
    private let keys: [[Key]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.sign, .digit("0"), .backspace],
    ]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // MARK: Value display
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)

                    Text(displayValue)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                }

                // MARK: Keypad grid
                VStack(spacing: 10) {
                    ForEach(0..<keys.count, id: \.self) { rowIndex in
                        HStack(spacing: 10) {
                            ForEach(keys[rowIndex], id: \.self) { key in
                                KeypadButton(key: key) {
                                    handleKeyTap(key)
                                }
                            }
                        }
                    }
                }

                Spacer()

                // MARK: Validate button
                Button {
                    onValidate(parsedIntValue)
                } label: {
                    Text("Valider")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding()
            .onAppear {
                workingText = "\(initialValue)"
            }
            .toolbar {
                // MARK: Close button (rounded cross)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Computed
    private var displayValue: String {
        workingText.isEmpty ? "0" : workingText
    }

    private var parsedIntValue: Int {
        Int(workingText) ?? 0
    }

    // MARK: - Key handling
    private func handleKeyTap(_ key: Key) {
        switch key {
        case .digit(let digit):
            if workingText == "0" {
                workingText = digit
            } else if workingText == "-0" {
                workingText = "-" + digit
            } else {
                workingText += digit
            }

        case .sign:
            if workingText.hasPrefix("-") {
                workingText.removeFirst()
            } else {
                workingText = "-" + (workingText.isEmpty ? "0" : workingText)
            }

        case .backspace:
            guard !workingText.isEmpty else { return }
            workingText.removeLast()
            if workingText == "-" { workingText = "" }
        }
    }
}

// MARK: - KeypadButton
private struct KeypadButton: View {

    // MARK: - Inputs
    let key: ScoreValueEditorSheet.Key
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                    )

                keypadContent
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content
    @ViewBuilder
    private var keypadContent: some View {
        switch key {
        case .digit(let digit):
            Text(digit)
        case .sign:
            Text("±")
        case .backspace:
            Image(systemName: "delete.left")
        }
    }
}

// MARK: - Previews

#Preview("Points — fermé") {
    GameConfigCard(
        selectedPresetID: .constant(.uno),
        selectedMode: .constant(.points),
        customInitialValue: .constant(0),
        customTargetValue: .constant(100),
        isDescendingMode: .constant(false),
        isEliminationMode: .constant(true),
        onChangeGame: {},
        onShowRules: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Points — ouvert") {
    GameConfigCard(
        selectedPresetID: .constant(.uno),
        selectedMode: .constant(.points),
        customInitialValue: .constant(10),
        customTargetValue: .constant(250),
        isDescendingMode: .constant(false),
        isEliminationMode: .constant(true),
        onChangeGame: {},
        onShowRules: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Victoires — fermé") {
    GameConfigCard(
        selectedPresetID: .constant(.uno),
        selectedMode: .constant(.wins),
        customInitialValue: .constant(0),
        customTargetValue: .constant(3),
        isDescendingMode: .constant(false),
        isEliminationMode: .constant(false),
        onChangeGame: {},
        onShowRules: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Victoires — ouvert") {
    GameConfigCard(
        selectedPresetID: .constant(.uno),
        selectedMode: .constant(.wins),
        customInitialValue: .constant(0),
        customTargetValue: .constant(5),
        isDescendingMode: .constant(false),
        isEliminationMode: .constant(false),
        onChangeGame: {},
        onShowRules: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Victoires — Stepper (0 → 10)") {
    GameConfigCard(
        selectedPresetID: .constant(.uno),
        selectedMode: .constant(.wins),
        customInitialValue: .constant(0),
        customTargetValue: .constant(10),
        isDescendingMode: .constant(false),
        isEliminationMode: .constant(false),
        onChangeGame: {},
        onShowRules: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
