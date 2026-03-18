/*
 * RulesSheet.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by ChatGPT on 21/01/2026 — V1.0 (sheet dédiée règles)
 * -----------------------------------------------------------------------------
 * RulesSheet — Affichage des règles d'un jeu
 * -----------------------------------------------------------------------------
 * - Titre + résumé + détails (texte long)
 * - Theming via themeColor
 * -----------------------------------------------------------------------------
 */

import SwiftUI

struct RulesSheet: View {
    let gameRules: GameRules
    let themeColor: Color

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text(gameRules.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(gameRules.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    Text(gameRules.details)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .navigationTitle("Règles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(themeColor)
                }
            }
        }
        .tint(themeColor)
    }
}


// MARK: - Preview
#Preview {
    RulesSheet(
        gameRules: GameRules(
            title: "Règles",
            summary: "Résumé…",
            details: "Détails…"
        ),
        themeColor: .blue
    )
}
