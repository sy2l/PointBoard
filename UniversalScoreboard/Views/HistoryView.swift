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
    @State private var showPaywall = false
    @ObservedObject private var storeManager = StoreManager.shared
    
    private let freeLimit = 10
    
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
            
            // Bannière publicitaire native (uniquement pour utilisateurs gratuits)
            if !StoreManager.shared.hasAllPacksBundle {
                /*AdBannerView()
                    .frame(height: 50)*/
            }
        }
        .navigationTitle("Historique")
        .onAppear {
            loadHistory()
        }
        .refreshable {
            loadHistory()
        }
        .sheet(isPresented: $showPaywall) {
            BundlePaywallView()
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
                // Badge Bundle (si Bundle)
                if storeManager.hasAllPacksBundle {
                    ProBadgeCard()
                        .padding(.horizontal, Spacing.lg)
                }
                
                // CTA Bundle (si limite atteinte et pas Bundle)
                if HistoryManager.shared.isLimitReached() && !storeManager.hasAllPacksBundle {
                    ProCallToActionCard(onUpgrade: { showPaywall = true })
                        .padding(.horizontal, Spacing.lg)
                }
                
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

// MARK: - Bundle Badge Card
struct ProBadgeCard: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.accentGreen)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Bundle All Packs activé")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("Historique illimité")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.accentGreen.opacity(0.1))
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(Color.accentGreen.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Bundle CTA Card
struct ProCallToActionCard: View {
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.accentGreen)
                    .font(.title3)
                
                Text("Historique limité")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            Text("Vous êtes limité aux 10 dernières parties. Prenez le Bundle All Packs pour conserver tout votre historique.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: onUpgrade) {
                HStack {
                    Text("Voir le Bundle")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentGreen)
                .foregroundColor(Color.textPrimary)
                .cornerRadius(CornerRadius.md)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
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
