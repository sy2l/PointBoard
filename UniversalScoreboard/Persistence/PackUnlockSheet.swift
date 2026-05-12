//
//  PackUnlockSheet.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  Updated on 26/03/2026 — Supprimé méthodes alternatives (refus Apple)
//  Updated on 01/04/2026 — Ajout bouton "Restaurer les achats" + Fix iPad tap area
//  Updated on 08/04/2026 — Ajout indicateurs chargement + alertes erreurs (Option A+C)
//  -----------------------------------------------------------------------------
//  PackUnlockSheet — Interface de déblocage d'un pack
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Afficher l'option d'achat direct du pack (0,99€)
//    - Proposer le Bundle All Packs en alternative (3,99€)
//
//  ► Intégration
//    - Appelé depuis SetupView (quand user clique sur jeu locké)
//    - Appelé depuis SettingsView (section Packs)
//    - Dismiss automatique après déblocage réussi
//  -----------------------------------------------------------------------------

import SwiftUI
import StoreKit

struct PackUnlockSheet: View {
    
    let pack: GamePack
    
    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    @State private var showBundleView = false
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // HEADER
                    headerView
                    
                    // Indicateur de chargement (Option C)
                    if storeManager.isLoadingProducts {
                        loadingView
                    }
                    
                    // Message d'erreur si produits non chargés (Option A)
                    if let error = storeManager.productsLoadError {
                        errorView(message: error)
                    }
                    
                    // LISTE JEUX INCLUS
                    includedGamesSection
                    
                    Divider()
                    
                    // TITRE SECTION
                    Text("Comment débloquer ?")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    // OPTION : ACHAT IAP
                    purchaseCard
                    
                    // FOOTER : BUNDLE LINK
                    bundleFooter
                }
                .padding(Spacing.lg)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }
                }
            }
            .alert("Erreur d'achat", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {
                    storeManager.lastPurchaseError = nil
                }
                Button("Réessayer") {
                    Task {
                        await storeManager.loadProducts()
                    }
                }
            } message: {
                Text(storeManager.lastPurchaseError ?? "Une erreur est survenue")
            }
            .onChange(of: storeManager.lastPurchaseError) { _, error in
                showErrorAlert = (error != nil)
            }
            .sheet(isPresented: $showBundleView) {
                BundlePaywallView()
            }
            .onChange(of: storeManager.unlockedPacks) { _, _ in
                if storeManager.isPackUnlocked(pack) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
            .onChange(of: storeManager.hasAllPacksBundle) { _, hasBundle in
                if hasBundle { dismiss() }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(packColor.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Text(packEmoji)
                    .font(.system(size: 50))
            }
            
            Text(pack.displayName)
                .font(.title.bold())
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(pack.description)
                .font(.bodyText)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Jeux inclus
    
    private var includedGamesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Jeux inclus :")
                .font(.caption.bold())
                .foregroundColor(.textSecondary)
            
            ForEach(pack.includedPresets, id: \.self) { presetID in
                if let preset = PresetManager.availablePresets.first(where: { $0.id == presetID }) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: preset.id.iconName)
                            .foregroundColor(packColor)
                            .frame(width: 20)
                        
                        Text(preset.displayName)
                            .font(.caption)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
    }
    
    // MARK: - Option : Achat IAP
    
    private var purchaseCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Text("💳")
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Achat Direct")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("0,99€ • Instantané")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
            
            // Bouton principal achat
            Button(action: {
                Task {
                    isPurchasing = true
                    await storeManager.purchasePack(pack)
                    isPurchasing = false
                }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Acheter maintenant")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50) // Fix iPad tap area
                .padding()
                .background(Color.accentGreen)
                .foregroundColor(.white)
                .cornerRadius(CornerRadius.md)
            }
            .buttonStyle(.plain) // Fix iPad gesture
            .disabled(isPurchasing || storeManager.isLoadingProducts)
            
            // Bouton Restaurer les achats (exigé par Apple)
            if !storeManager.isPackUnlocked(pack) {
                Button(action: {
                    Task {
                        await storeManager.restorePurchases()
                    }
                }) {
                    Text("Restaurer les achats")
                        .font(.subheadline)
                        .foregroundColor(.accentGreen)
                        .underline()
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.lg)
        .background(Color.accentGreen.opacity(0.1))
        .cornerRadius(CornerRadius.lg)
    }
    
    // MARK: - Vues de chargement et d'erreur (Option A + C)
    
    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .accentGreen))
            
            Text("Chargement des produits...")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.accentGreen.opacity(0.1))
        .cornerRadius(CornerRadius.md)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(message)
                .font(.bodyText)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await storeManager.loadProducts()
                }
            }) {
                Text("Réessayer")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.accentGreen)
                    .cornerRadius(CornerRadius.sm)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .cornerRadius(CornerRadius.md)
    }
    
    // MARK: - Footer Bundle
    
    private var bundleFooter: some View {
        VStack(spacing: Spacing.sm) {
            Text("ou")
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            Button(action: {
                showBundleView = true
            }) {
                HStack(spacing: Spacing.xs) {
                    Text("Tout débloquer pour 3,99€")
                        .font(.bodyText.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundColor(.appPrimary)
            }
        }
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Helpers
    
    private var packColor: Color {
        switch pack {
        case .coreFree: return .gray
        case .classicCards: return .blue
        case .funCardsDice: return .orange
        case .boardFamily: return .green
        case .outdoorSport: return .yellow
        case .partyNight: return .pink
        case .duelsStrategy: return .purple
        case .kidsFamily2: return .teal
        }
    }
    
    private var packEmoji: String {
        switch pack {
        case .coreFree: return "⭐️"
        case .classicCards: return "🃏"
        case .funCardsDice: return "🎲"
        case .boardFamily: return "♟️"
        case .outdoorSport: return "☀️"
        case .partyNight: return "🎉"
        case .duelsStrategy: return "🧠"
        case .kidsFamily2: return "👨‍👩‍👧‍👦"
        }
    }
}

// MARK: - Preview

#Preview {
    PackUnlockSheet(pack: .classicCards)
}
