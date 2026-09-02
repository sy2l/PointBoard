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
    
    // MARK: - State
    @Namespace private var scrollNamespace
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    // MARK: - Computed
    
    /// Presets filtrés par recherche
    private var filteredPresets: [PresetID] {
        if searchText.isEmpty {
            return PresetID.allCases
        } else {
            return PresetID.allCases.filter { presetId in
                let name = PresetManager.preset(for: presetId).displayName
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// Presets groupés par première lettre
    private var groupedPresets: [(letter: String, presets: [PresetID])] {
        let sorted = filteredPresets.sorted { a, b in
            let nameA = PresetManager.preset(for: a).displayName
            let nameB = PresetManager.preset(for: b).displayName
            return nameA.localizedCaseInsensitiveCompare(nameB) == .orderedAscending
        }
        
        let grouped = Dictionary(grouping: sorted) { presetId -> String in
            let name = PresetManager.preset(for: presetId).displayName
            let firstChar = String(name.prefix(1))
            
            // Si le premier caractère est un chiffre, retourner "#"
            if firstChar.rangeOfCharacter(from: .decimalDigits) != nil {
                return "#"
            }
            
            return firstChar.uppercased()
        }
        
        // Trier avec "#" en premier
        return grouped.sorted { a, b in
            if a.key == "#" { return true }
            if b.key == "#" { return false }
            return a.key < b.key
        }.map { (letter: $0.key, presets: $0.value) }
    }
    
    /// Lettres disponibles (pour l'index)
    private var availableLetters: [String] {
        groupedPresets.map { $0.letter }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .trailing) {
                
                // Fond blanc porcelaine derrière tout
                Color.whiteBackground
                    .ignoresSafeArea()
                
                // MARK: - Liste avec sections
                ScrollViewReader { proxy in
                    VStack(spacing: 0) {
                        // SearchBar (en dehors du conteneur blanc)
                        SearchBarView(
                            text: $searchText,
                            isFocused: $isSearchFocused,
                            placeholder: "Rechercher un jeu..."
                        )
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, Spacing.md)
                        
                        // Liste dans un conteneur blanc avec coins arrondis en haut
                        ZStack(alignment: .top) {
                            // Fond blanc DERRIÈRE (pas clippé)
                            VStack(spacing: 0) {
                                Color.whiteBackground
                                    .frame(height: 24) // Juste la partie arrondie
                                    .clipShape(
                                        UnevenRoundedRectangle(
                                            cornerRadii: .init(
                                                topLeading: 24,
                                                topTrailing: 24
                                            )
                                        )
                                    )
                                
                                Color.whiteBackground // Continue en bas sans clip
                            }
                            
                            // Liste PAR DESSUS
                            List {
                                ForEach(groupedPresets, id: \.letter) { group in
                                    Section {
                                        ForEach(group.presets) { presetId in
                                            gameRow(for: presetId)
                                        }
                                    } header: {
                                        Text(group.letter)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.sectionTitle)
                                            .textCase(nil)
                                            .id(group.letter)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowSeparator(.hidden) // ← Cache les traits
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    // MARK: - Section Index (overlay) - Caché pendant recherche
                    .overlay(alignment: .trailing) {
                        if searchText.isEmpty {
                            SectionIndexView(
                                availableLetters: availableLetters,
                                onLetterSelected: { letter in
                                    withAnimation {
                                        proxy.scrollTo(letter, anchor: .top)
                                    }
                                }
                            )
                            .padding(.trailing, 8)
                            .padding(.top, 140)
                            .transition(.opacity)
                        }
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
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func gameRow(for presetId: PresetID) -> some View {
        GameSelectionCard(
            presetId: presetId,
            isSelected: presetId == selectedPresetID,
            onTap: {
                onSelect(presetId)
                dismiss()
            }
        )
        .listRowInsets(EdgeInsets(top: 4, leading: Spacing.lg, bottom: 4, trailing: 12))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden) // ← Cache le séparateur pour cette row
    }
}
// MARK: - Preview

#Preview("Game Selection Sheet") {
    GameSelectionSheet(
        selectedPresetID: .constant(.uno),
        onSelect: { presetId in
            print("Selected: \(presetId.rawValue)")
        }
    )
}
