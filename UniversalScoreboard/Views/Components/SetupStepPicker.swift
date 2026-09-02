//
//  SetupStepPicker.swift
//  PointBoard
//
//  Created by sy2l on 02/09/2026
//  -----------------------------------------------------------------------------
//  SetupStepPicker — Picker segmenté compact style gaming
//  -----------------------------------------------------------------------------
//  Design inspiré de GameSelectionCard avec:
//  - Format compact (3 segments côte à côte)
//  - Dégradé vertical subtil
//  - Bordure brillante + sélection
//  - Animation fluide au changement
//  - 3 étapes : Résumé / Joueurs / Jeu
//  -----------------------------------------------------------------------------

import SwiftUI

enum SetupStep: String, CaseIterable, Identifiable {
    case summary = "Résumé"
    case players = "Joueurs"
    case game = "Jeu"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .summary: return "list.bullet.clipboard"
        case .players: return "person.2.fill"
        case .game: return "gamecontroller.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .summary: return .accentBlue
        case .players: return .accentRed
        case .game: return .accentYellow
        }
    }
}

struct SetupStepPicker: View {
    @Binding var selectedStep: SetupStep
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(SetupStep.allCases) { step in
                stepButton(for: step)
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(CornerRadius.md)
        .padding(.horizontal, Spacing.lg)
    }
    
    @ViewBuilder
    private func stepButton(for step: SetupStep) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedStep = step
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: step.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(selectedStep == step ? .white : .textSecondary)
                
                Text(step.rawValue)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(selectedStep == step ? .white : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if selectedStep == step {
                        // Fond avec dégradé vertical
                        LinearGradient(
                            colors: [
                                step.color.opacity(0.9),
                                step.color
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .matchedGeometryEffect(id: "background", in: animation)
                        
                        // Bordure intérieure brillante
                        RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("SetupStepPicker - Compact") {
    VStack(spacing: Spacing.xl) {
        SetupStepPicker(selectedStep: .constant(.summary))
        SetupStepPicker(selectedStep: .constant(.players))
        SetupStepPicker(selectedStep: .constant(.game))
    }
    .padding()
    .background(Color.appBackground)
}
