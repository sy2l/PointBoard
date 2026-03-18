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
    @ObservedObject private var storeManager = StoreManager.shared

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
    @State private var showPackPaywall: GamePack? = nil

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

        // ✅ Root scrollable: permet à la NavigationStack (dans MainTabView)
        // de gérer le passage Large -> Inline automatiquement.
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {

                // -----------------------------------------------------------------
                // MARK: - Header
                // -----------------------------------------------------------------
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {

                        if let profile = profileManager.currentProfile {
                            Text("Salut \(profile.name), on joue à quoi ?")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.textSecondary)
                        }

                        Text("Choisis ou personnalise un jeu et ajoute les joueurs")
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.md)

                    Button(action: {
                        headerSelectedProfile = nil
                        showCreateProfileSheet = true
                    }) {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                                .foregroundColor(.appPrimary)

                            if hasAnyProfile {
                                Text("Changer de profil")
                                    .font(.cardTitle)
                                    .foregroundColor(.textPrimary)
                            } else {
                                Text("Crée ou choisis un profil")
                                    .font(.cardTitle)
                                    .foregroundColor(.textPrimary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(Spacing.lg)
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                        .background(Color.cardBackground)
                        .cornerRadius(CornerRadius.lg)
                        .shadow(
                            color: AppShadow.card.color,
                            radius: AppShadow.card.radius,
                            x: AppShadow.card.x,
                            y: AppShadow.card.y
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.lg)
                }

                // -----------------------------------------------------------------
                // MARK: - Content
                // -----------------------------------------------------------------
                VStack(spacing: Spacing.lg) {

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

                    PlayersConfigCard(playerSlots: $playerSlots)
                }
                .padding(.horizontal, Spacing.lg)

                Spacer(minLength: Spacing.xl)
            }
            .padding(.top, Spacing.md)
        }
        .background(Color.appBackground)
        .navigationTitle("Nouvelle partie")
        .navigationBarTitleDisplayMode(.large)

        // ✅ Le bouton restera AU-DESSUS de la TabBar automatiquement
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Button(action: startGame) {
                    Text("Démarrer la partie")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            canStartGame
                            ? Color.accentGreen
                            : Color.textSecondary.opacity(0.3)
                        )
                        .cornerRadius(CornerRadius.lg)
                }
                .disabled(!canStartGame)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
            }
            //.background(.ultraThinMaterial)
        }

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

        .sheet(item: $showPackPaywall) { pack in
            PackUnlockSheet(pack: pack)
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

    // MARK: - Helpers

    private func handlePresetSelection(_ presetId: PresetID) {
        if !storeManager.isPresetUnlocked(presetId) {
            let pack = GamePack.packContaining(presetId)
            showPackPaywall = pack
            return
        }

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
