/*
 HistoryView.swift
 PointBoard
 
 Vue de l'historique des parties archivées.
 Sprint 2+5 - V3.5
 Modernisé avec cards le 29/01/2026
 */

import SwiftUI

struct HistoryView: View {
    @State private var history: [GameResult] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                if isLoading {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.appBackground)
                } else if history.isEmpty {
                    emptyStateView
                } else {
                    historyCardsView
                }
            }
        }
        .navigationTitle("Historique")
        .onAppear {
            loadHistory()
        }
        .refreshable {
            loadHistory()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 60))
                    .foregroundColor(.textSecondary)
                
                VStack(spacing: Spacing.sm) {
                    Text("Aucune partie archivée")
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text("Les parties terminées apparaîtront ici.")
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - History Cards View
    
    private var historyCardsView: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Liste des parties en cards
                VStack(spacing: Spacing.md) {
                    ForEach(history) { result in
                        NavigationLink(destination: GameDetailView(result: result)) {
                            HistoryCard(result: result)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Actions
    
    private func loadHistory() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            history = HistoryManager.shared.loadHistory()
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview("Avec parties") {
    NavigationStack {
        HistoryView()
    }
}

#Preview("Vide") {
    NavigationStack {
        HistoryView()
    }
}
