/*
 * SetupView.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated on 22/01/2026 — Fix Rules Sheet (freeze PresetID at tap)
 * Updated on 23/01/2026 — Players flow: moved Players/Profile sheets inside PlayersConfigCard (2 sheets max)
 * Updated on 30/01/2026 — Header: CTA création profil si aucun profil
 * Updated on 02/02/2026 — Fix: Header CTA opens ProfileSelectionView sheet (required selectedProfile binding)
 * -----------------------------------------------------------------------------
 * SetupView — Configuration d'une partie (orchestrateur UI)
 *
 * Problème corrigé :
 * - SwiftUI peut réévaluer le contenu d'une sheet au moment de l'affichage.
 * - Si la sheet lit un PresetID “ailleurs” (fallback .generic, VM nil, etc.),
 *   RulesManager.getRules() peut être appelé avec le mauvais ID -> règles nil.
 *
 * Fix robuste :
 * - GameConfigCard envoie explicitement le PresetID au moment du tap.
 * - SetupView stocke un snapshot (rulesPresetID) et la sheet lit uniquement ce snapshot.
 *
 * Simplification joueurs :
 * - Les sheets "Joueurs" + "Profils" sont gérées dans PlayersConfigCard.
 * - SetupView n'a plus de state/sheets dédiés aux joueurs.
 * -----------------------------------------------------------------------------
 */

import SwiftUI

// MARK: - Setup View
struct SetupView: View {

    // MARK: - Dependencies
    @StateObject private var gameViewModel = GameViewModel()
    @ObservedObject private var profileManager = ProfileManager.shared

    // MARK: - State (Game selection)
    @State private var selectedPresetID: PresetID = .generic
    @State private var selectedMode: GameMode = .points

    // MARK: - State (Players)
    @State private var playerSlots: [PlayerSlot] = [
        PlayerSlot(name: "Joueur 1"),
        PlayerSlot(name: "Joueur 2"),
    ]

    // MARK: - State (Custom config)
    @State private var customInitialValue: Int = 0
    @State private var customTargetValue: Int = 100
    @State private var isDescendingMode: Bool = false
    @State private var isEliminationMode: Bool = false

    // MARK: - UI / Navigation / Sheets
    @State private var showGameView: Bool = false
    @State private var showGameSelection: Bool = false
    @State private var showRules: Bool = false
    
    // Étape actuelle du setup
    @State private var currentStep: SetupStep = .game

    // Snapshot : PresetID figé au moment du tap sur "Voir les règles"
    @State private var rulesPresetID: PresetID? = nil

    // Sheet "Profil"
    @State private var showCreateProfileSheet: Bool = false
    @State private var headerSelectedProfile: PlayerProfile? = nil

    // MARK: - Computed

    private var hasAnyProfile: Bool {
        !profileManager.profiles.isEmpty
    }

    private var canStartGame: Bool {
        playerSlots
            .filter { !$0.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count >= 2
    }

    private var currentPreset: GamePreset {
        PresetManager.preset(for: selectedPresetID)
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // -----------------------------------------------------------------
                // MARK: - Header (compact & adaptatif)
                // -----------------------------------------------------------------
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    if let profile = profileManager.currentProfile {
                        Text("Salut \(profile.name), on joue à quoi ?")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Text("Choisis ou personnalise un jeu")
                        .font(.footnote)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                
                // -----------------------------------------------------------------
                // MARK: - Step Picker (Gaming style) - EN HAUT
                // -----------------------------------------------------------------
                SetupStepPicker(selectedStep: $currentStep)
                    .padding(.top, Spacing.xs)
                    .padding(.bottom, Spacing.sm)
                
                // Bouton profil compact
                Button(action: {
                    headerSelectedProfile = nil
                    showCreateProfileSheet = true
                }) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "person.crop.circle")
                            .font(.body)
                            .foregroundColor(.appPrimary)

                        Text(hasAnyProfile ? "Changer de profil" : "Créer un profil")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.md)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)

                // -----------------------------------------------------------------
                // MARK: - Content (scrollable si besoin)
                // -----------------------------------------------------------------
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.md) {
                        
                        // Affichage conditionnel selon l'étape
                        switch currentStep {
                        case .summary:
                            summarySection
                            
                        case .players:
                            PlayersConfigCard(playerSlots: $playerSlots)
                            
                            // Grille des joueurs en dessous (3 par ligne)
                            if !playerSlots.isEmpty {
                                PlayersGridSection(playerSlots: $playerSlots)
                            }
                            
                        case .game:
                            GameConfigCard(
                                selectedPresetID: $selectedPresetID,
                                selectedMode: $selectedMode,
                                customInitialValue: $customInitialValue,
                                customTargetValue: $customTargetValue,
                                isDescendingMode: $isDescendingMode,
                                isEliminationMode: $isEliminationMode,
                                onChangeGame: { showGameSelection = true },
                                onShowRules: { presetId in
                                    rulesPresetID = presetId
                                    showRules = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                .frame(maxHeight: .infinity)

                // -----------------------------------------------------------------
                // MARK: - Bouton (fixe en bas)
                // -----------------------------------------------------------------
                Button(action: startGame) {
                    Text("Démarrer la partie")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .gamingButtonStyle()
                .disabled(!canStartGame)
                .opacity(canStartGame ? 1.0 : 0.5)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
                .background(Color.appBackground)
            }
        }
        .background(Color.whiteBackground)
        .navigationTitle("Nouvelle partie")
        .navigationBarTitleDisplayMode(.large)

        // MARK: - Sheets
        .sheet(isPresented: $showGameSelection) {
            GameSelectionSheet(
                selectedPresetID: $selectedPresetID,
                onSelect: handlePresetSelection
            )
        }

        .sheet(isPresented: $showRules) {
            let id = rulesPresetID ?? selectedPresetID

            if let rules = RulesManager.shared.getRules(for: id) {
                RulesSheet(gameRules: rules, themeColor: id.themeColor)
            } else {
                VStack(spacing: Spacing.md) {
                    Text("Pas de règles disponibles pour ce jeu.")
                    Text("presetId = \(id.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .onChange(of: showRules) { _, isPresented in
            if !isPresented { rulesPresetID = nil }
        }

        .sheet(
            isPresented: $showCreateProfileSheet,
            onDismiss: {
                headerSelectedProfile = nil
            }
        ) {
            ProfileSelectionView(
                selectedProfile: $headerSelectedProfile,
                disabledProfileIDs: []
            )
        }

        // MARK: - Navigation
        .navigationDestination(isPresented: $showGameView) {
            GameView()
                .environmentObject(gameViewModel)
                .navigationBarBackButtonHidden(true)
        }

        .onAppear {
            applyPresetToUI(selectedPresetID)
        }
    }

    // MARK: - Summary Section
    
    @ViewBuilder
    private var summarySection: some View {
        VStack(spacing: Spacing.md) {
            // Carte Jeu
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.accentYellow)
                    Text("Jeu sélectionné")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                Text(currentPreset.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(selectedPresetID.themeColor)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius)
            
            // Carte Joueurs
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.accentGreen)
                    Text("Joueurs")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                let activePlayers = playerSlots.filter { !$0.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                
                ForEach(activePlayers) { slot in
                    HStack {
                        Circle()
                            .fill(Color.accentGreen)
                            .frame(width: 8, height: 8)
                        Text(slot.displayName)
                            .font(.body)
                            .foregroundColor(.textPrimary)
                    }
                }
                
                Text("\(activePlayers.count) joueur\(activePlayers.count > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius)
            
            // Carte Configuration
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.accentBlue)
                    Text("Configuration")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                HStack {
                    Text("Mode:")
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text(selectedMode == .points ? "Points" : "Victoires")
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                
                HStack {
                    Text("Objectif:")
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("\(customInitialValue) → \(customTargetValue)")
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                
                if isDescendingMode {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.orange)
                        Text("Score décroissant")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                if isEliminationMode {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Mode élimination")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius)
        }
    }
    
    // MARK: - Helpers

    private func handlePresetSelection(_ presetId: PresetID) {
        // Tous les presets sont maintenant accessibles (app gratuite)
        selectedPresetID = presetId
        applyPresetToUI(presetId)
    }

    private func applyPresetToUI(_ presetId: PresetID) {
        let preset = PresetManager.preset(for: presetId)
        let settings = preset.settings

        selectedMode = settings.mode
        customInitialValue = settings.initialValue
        customTargetValue = settings.target.value

        isDescendingMode = settings.lowestScoreIsBest
        isEliminationMode =
        (settings.target.consequence == .eliminated)
        || (settings.endCondition.type == .remainingPlayers)
    }

    private func buildSettings() -> GameSettings {
        let base = currentPreset.settings

        let comparator: TargetComparator =
        isDescendingMode ? .lessThanOrEqual : .greaterThanOrEqual

        let endCondition: EndCondition =
        isEliminationMode
        ? EndCondition(type: .remainingPlayers, value: 1)
        : base.endCondition

        let consequence: TargetConsequence =
        isEliminationMode ? .eliminated : base.target.consequence

        return GameSettings(
            mode: selectedMode,
            initialValue: customInitialValue,
            target: Target(
                value: customTargetValue,
                comparator: comparator,
                consequence: consequence
            ),
            endCondition: endCondition,
            lowestScoreIsBest: isDescendingMode
        )
    }

    private func startGame() {
        guard canStartGame else { return }

        let filledSlots = playerSlots.filter {
            !$0.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        let names = filledSlots.map { $0.displayName }
        let profileIds = filledSlots.map { $0.profileId }

        let settings = buildSettings()

        gameViewModel.createGame(
            settings: settings,
            presetId: selectedPresetID,
            playerNames: names,
            profileIds: profileIds
        )

        showGameView = true
    }
}

// MARK: - Preview
#Preview {
    SetupView()
}
