/*
 * GameSelectionSheet.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by ChatGPT on 21/01/2026 — V4.6.0 (sheet dédiée + gating)
 * Updated by sy2l on 12/05/2026 — Migration V6.0.0 : Tous les presets gratuits
 * -----------------------------------------------------------------------------
 * GameSelectionSheet — Sélecteur de jeu (PresetID)
 * -----------------------------------------------------------------------------
 * - Affiche tous les PresetID (tous accessibles)
 * - Pas de verrou (app 100% gratuite)
 * -----------------------------------------------------------------------------
 */

import SwiftUI

struct GameSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedPresetID: PresetID
    let onSelect: (PresetID) -> Void

    // MARK: - Sorting
    private var sortedPresets: [PresetID] {
        PresetID.allCases.sorted { a, b in
            // Tri alphabétique par nom
            let nameA = PresetManager.preset(for: a).displayName
            let nameB = PresetManager.preset(for: b).displayName
            return nameA.localizedCaseInsensitiveCompare(nameB) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedPresets) { presetId in
                    let preset = PresetManager.preset(for: presetId)
                    let pack = GamePack.packContaining(presetId)

                    Button {
                        onSelect(presetId)
                        dismiss()
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: presetId.iconName)
                                .font(.title2)
                                .foregroundColor(presetId.themeColor)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(preset.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(pack.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if presetId == selectedPresetID {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Choisir un jeu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}
