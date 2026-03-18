//
// GameCard.swift
// PointBoard
//
// Extracted from ModernCards.swift
//

import SwiftUI

// MARK: - Game Card (Style météo)
struct GameCard: View {

    // MARK: - Inputs
    let preset: GamePreset
    let configSummary: String
    let themeColor: Color

    // MARK: - Config UI
    let isConfigExpanded: Bool
    let onToggleConfig: () -> Void

    // MARK: - Actions
    let onChangeGame: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {

            // MARK: Partie haute (colorée avec gradient)
            ZStack(alignment: .topTrailing) {
                Color.gameGradient(for: themeColor)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.md) {

                        Image(systemName: preset.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(.white)

                        Text(preset.displayName)
                            .font(.cardTitle)
                            .foregroundColor(.white)

                        Text(configSummary)
                            .font(.cardSubtitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // MARK: CTA "Changer de jeu" (haut droite)
                    Button(action: onChangeGame) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title3)
                                .foregroundColor(.white)

                            Text("Changer\nde jeu")
                                .font(.cardSubtitle)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 120, height: 120)
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(Spacing.lg)
            }
            .frame(height: 150)

            // MARK: Partie basse (grise/blanche) -> "Modifier config"
            Button(action: onToggleConfig) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.textSecondary)

                    Text(isConfigExpanded ? "Masquer config" : "Modifier config")
                        .foregroundColor(.textSecondary)

                    Spacer()

                    Image(systemName: isConfigExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.textSecondary)
                        .font(.caption)
                }
                .font(.cardSubtitle)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(Color.cardBackground.opacity(0.5))
        }
        .modernElevatedCardStyle()
    }
}

#Preview("GameCard — fermé") {
    GameCard(
        preset: PresetConfiguration.presets.first ?? PresetConfiguration.genericPreset,
        configSummary: "Points - 0→100",
        themeColor: .red,
        isConfigExpanded: false,
        onToggleConfig: {},
        onChangeGame: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("GameCard — ouvert") {
    GameCard(
        preset: PresetConfiguration.presets.first ?? PresetConfiguration.genericPreset,
        configSummary: "Victoires - 0→10",
        themeColor: .blue,
        isConfigExpanded: true,
        onToggleConfig: {},
        onChangeGame: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
