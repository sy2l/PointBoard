/*
 * GameSelectionSheet.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by ChatGPT on 21/01/2026 — V4.6.0 (sheet dédiée + gating)
 * -----------------------------------------------------------------------------
 * GameSelectionSheet — Sélecteur de jeu (PresetID)
 * -----------------------------------------------------------------------------
 * - Affiche tous les PresetID
 * - Montre le verrou 🔒 si le preset n'est pas débloqué
 * - Affiche l'info pack (nom + prix) pour contextualiser la monétisation
 * -----------------------------------------------------------------------------
 */

import SwiftUI

struct GameSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeManager = StoreManager.shared

    @Binding var selectedPresetID: PresetID
    let onSelect: (PresetID) -> Void

    // MARK: - Sorting
    private var sortedPresets: [PresetID] {
        PresetID.allCases.sorted { a, b in
            let packA = GamePack.packContaining(a)
            let packB = GamePack.packContaining(b)

            // 1) Gratuits d'abord
            let freeA = (packA == .coreFree)
            let freeB = (packB == .coreFree)
            if freeA != freeB { return freeA && !freeB }

            // 2) Puis débloqués avant verrouillés
            let unlockedA = storeManager.isPresetUnlocked(a)
            let unlockedB = storeManager.isPresetUnlocked(b)
            if unlockedA != unlockedB { return unlockedA && !unlockedB }

            // 3) Puis alphabétique (displayName)
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
                    let isLocked = !storeManager.isPresetUnlocked(presetId)
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

                                HStack(spacing: 6) {
                                    Text(pack.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)

                                    Text("• \(pack.price)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.orange)
                            } else if presetId == selectedPresetID {
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
