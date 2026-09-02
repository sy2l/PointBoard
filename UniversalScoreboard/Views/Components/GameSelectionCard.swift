//
//  GameSelectionCard.swift
//  PointBoard
//
//  Created by sy2l on 31/08/2026
//  -----------------------------------------------------------------------------
//  GameSelectionCard — Bouton type jeu mobile (Style Candy Crush)
//  -----------------------------------------------------------------------------
//  Design "juicy" avec:
//  - Double bordure (blanche externe + claire interne pour effet brillance)
//  - Dégradé vertical (clair en haut → saturé en bas)
//  - Double ombre portée (colorée + noire pour profondeur 3D)
//  - Animation scale + spring au tap
//  - Icône en blanc transparent pour contraste
//  - 100% Design System
//  -----------------------------------------------------------------------------

import SwiftUI

struct GameSelectionCard: View {
    
    // MARK: - Inputs
    
    let presetId: PresetID
    let isSelected: Bool
    let onTap: () -> Void
    
    // MARK: - State
    
    @State private var isPressed: Bool = false
    
    // MARK: - Computed
    
    private var preset: GamePreset {
        PresetManager.preset(for: presetId)
    }
    
    private var pack: GamePack {
        GamePack.packContaining(presetId)
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            // Animation tactile "bounce"
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            HStack(spacing: Spacing.md) {
                // MARK: - Texte (gauche)
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.displayName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(pack.displayName)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                // MARK: - Icône (droite)
                Image(systemName: presetId.iconName)
                    .font(.system(size: 40, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            .padding(.leading, Spacing.lg)
            .padding(.trailing, 10) // ← Padding extra pour l'index
            .padding(.vertical, Spacing.lg)
            .background(
                // Dégradé vertical (clair en haut, saturé en bas = effet 3D)
                LinearGradient(
                    colors: [
                        presetId.themeColor.opacity(0.9),
                        presetId.themeColor
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // Bordure intérieure claire (effet brillance/highlight)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),  // Plus opaque en haut
                                .white.opacity(0.05)  // Presque invisible en bas
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3  // Plus épais (était 2)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            // Bordure extérieure blanche épaisse (si sélectionné)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg + 2, style: .continuous)
                    .strokeBorder(Color.white, lineWidth: isSelected ? 4 : 0)
                    .padding(-2)
            )
            // Double ombre pour effet 3D profond
            .shadow(
                color: presetId.themeColor.opacity(0.5),
                radius: isPressed ? 4 : 12,
                x: 0,
                y: isPressed ? 2 : 8
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: isPressed ? 2 : 6,
                x: 0,
                y: isPressed ? 1 : 4
            )
            // Animation scale au tap (effet "enfoncé")
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 40)
    }
}

// MARK: - Preview

#Preview("GameSelectionCard - Uno") {
    VStack(spacing: Spacing.md) {
        GameSelectionCard(
            presetId: .uno,
            isSelected: false,
            onTap: { print("Tapped Uno") }
        )
        
        GameSelectionCard(
            presetId: .uno,
            isSelected: true,
            onTap: { print("Tapped Uno (selected)") }
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("GameSelectionCard - Multiple") {
    ScrollView {
        VStack(spacing: Spacing.sm) {
            GameSelectionCard(presetId: .uno, isSelected: false, onTap: {})
            GameSelectionCard(presetId: .skyjo, isSelected: true, onTap: {})
            GameSelectionCard(presetId: .belote, isSelected: false, onTap: {})
            GameSelectionCard(presetId: .poker, isSelected: false, onTap: {})
            GameSelectionCard(presetId: .molkky, isSelected: false, onTap: {})
        }
        .padding()
    }
    .background(Color.appBackground)
}
