//
//  PlayerEditSheet.swift
//  PointBoard
//
//  Created by sy2l on 02/09/2026
//  -----------------------------------------------------------------------------
//  PlayerEditSheet — Popup d'édition de joueur
//  -----------------------------------------------------------------------------
//  Fonctionnalités:
//  - Carrousel d'avatars horizontal (swipe gauche/droite)
//  - TextField pour modifier le nom (auto-focus)
//  - Adaptation automatique au clavier
//  - Bouton "Fermer" dans la toolbar du clavier
//  - Design gaming 3D
//  - Support des images assets
//  -----------------------------------------------------------------------------

import SwiftUI

struct PlayerEditSheet: View {
    @Binding var slot: PlayerSlot
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var editedName: String = ""
    @State private var selectedAvatarIndex: Int = 0
    @FocusState private var isNameFieldFocused: Bool
    
    // MARK: - Avatar assets (à remplir avec vos noms d'assets)
    // TODO: Remplacez par vos vrais noms d'images dans Assets.xcassets
    private let avatarAssetNames: [String] = [
        "avatar1", // ← Mettez le nom exact de votre asset ici
        "avatar2",
        "avatar3",
        "avatar4",
        "avatar5",
        "avatar6",
        "avatar7",
        "avatar8"
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                
                // -----------------------------------------------------------------
                // MARK: - Carrousel d'avatars
                // -----------------------------------------------------------------
                VStack(spacing: Spacing.md) {
                    Text("Choisis un avatar")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    
                    TabView(selection: $selectedAvatarIndex) {
                        ForEach(avatarAssetNames.indices, id: \.self) { index in
                            avatarCard(assetName: avatarAssetNames[index], index: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))  // ← Pas de points iOS (on fait les nôtres)
                    .frame(height: 220)
                    .padding(.horizontal, Spacing.xl)
                    
                    // Indicateur de position personnalisé (SANS ombre)
                    HStack(spacing: 6) {
                        ForEach(avatarAssetNames.indices, id: \.self) { index in
                            Circle()
                                .fill(selectedAvatarIndex == index ? Color.accentGreen : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.spring(response: 0.3), value: selectedAvatarIndex)
                        }
                    }
                }
                
                // -----------------------------------------------------------------
                // MARK: - TextField nom
                // -----------------------------------------------------------------
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Nom du joueur")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    
                    TextField("Entre un nom...", text: $editedName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .padding(Spacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                .strokeBorder(Color.accentGreen.opacity(isNameFieldFocused ? 0.5 : 0.2), lineWidth: 2)
                        )
                        .focused($isNameFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            saveAndDismiss()
                        }
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
            }
            .padding(.top, Spacing.xl)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Modifier le joueur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Bouton Annuler
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                // Bouton Valider
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                // Bouton "Fermer clavier" (apparaît quand clavier visible)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        isNameFieldFocused = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "keyboard.chevron.compact.down")
                            Text("Fermer")
                        }
                        .font(.subheadline)
                        .foregroundColor(.accentGreen)
                    }
                }
            }
            .onAppear {
                editedName = slot.displayName
                isNameFieldFocused = true  // Auto-focus sur le TextField
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Avatar Card (avec effet 3D, support image asset)
    @ViewBuilder
    private func avatarCard(assetName: String, index: Int) -> some View {
        ZStack {
            // Fond avec dégradé gaming
            LinearGradient(
                colors: [
                    Color.accentGreen.opacity(0.9),
                    Color.accentGreen
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Image de l'asset (si elle existe) OU fallback lettre
            if let _ = UIImage(named: assetName) {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback : affiche la lettre + nom de l'asset
                VStack(spacing: Spacing.sm) {
                    Text(String(editedName.prefix(1)).uppercased())
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(assetName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(width: 200, height: 200)
        .overlay(
            // Bordure brillante
            RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
        .shadow(
            color: Color.accentGreen.opacity(0.5),
            radius: 12,
            x: 0,
            y: 8
        )
        .shadow(
            color: Color.black.opacity(0.25),
            radius: 6,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Actions
    private func saveAndDismiss() {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        slot.name = trimmed
        // TODO: Sauvegarder l'avatar sélectionné
        // slot.avatarAssetName = avatarAssetNames[selectedAvatarIndex]
        
        dismiss()
    }
}

// MARK: - Preview

#Preview("PlayerEditSheet") {
    Text("Tap to open")
        .sheet(isPresented: .constant(true)) {
            PlayerEditSheet(slot: .constant(PlayerSlot(name: "Alice")))
        }
}
