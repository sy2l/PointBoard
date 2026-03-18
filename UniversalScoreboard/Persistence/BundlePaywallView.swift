//
//  BundlePaywallView.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  -----------------------------------------------------------------------------
//  BundlePaywallView — Interface d'achat du Bundle All Packs
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Présenter le Bundle All Packs (2,99€)
//    - Afficher la liste des 7 packs inclus
//    - Montrer l'économie réalisée vs achats individuels
//    - Gérer l'achat via StoreKit 2
//
//  ► Avantages Bundle
//    - Prix unique : 2,99€ (vs 7×0,99€ = 6,93€)
//    - Économie : 3,94€
//    - Inclut tous les packs actuels + futurs
//    - Plus de publicités ni d'attente
//
//  ► Intégration
//    - Appelé depuis PackUnlockSheet (footer link)
//    - Appelé depuis SettingsView (section Packs)
//    - Dismiss automatique après achat réussi
//  -----------------------------------------------------------------------------

import SwiftUI
import StoreKit

struct BundlePaywallView: View {
    
    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // HERO SECTION
                    heroView
                    
                    // LISTE DES PACKS INCLUS
                    packsListSection
                    
                    // COMPARAISON PRIX
                    priceComparisonSection
                    
                    // AVANTAGES
                    advantagesSection
                    
                    // BOUTON ACHAT
                    purchaseButton
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
            .onChange(of: storeManager.hasAllPacksBundle) { _, hasBundle in
                if hasBundle {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Hero
    
    private var heroView: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("🎁")
                    .font(.system(size: 60))
            }
            
            Text("Débloquez TOUT !")
                .font(.largeTitle.bold())
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Tous les packs actuels + futurs")
                .font(.headline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("2,99€")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.appPrimary)
        }
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Liste des packs
    
    private var packsListSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Packs inclus :")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                ForEach(GamePack.paidPacks, id: \.self) { pack in
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentGreen)
                            .font(.title3)
                        
                        Text(packEmoji(for: pack))
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(pack.displayName)
                                .font(.bodyText.weight(.semibold))
                                .foregroundColor(.textPrimary)
                            
                            Text("\(pack.includedPresets.count) jeux")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("0,99€")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .strikethrough()
                    }
                    .padding(Spacing.md)
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.md)
                }
            }
        }
    }
    
    // MARK: - Comparaison prix
    
    private var priceComparisonSection: some View {
        VStack(spacing: Spacing.md) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Prix individuel")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("7 × 0,99€")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .strikethrough()
                }
                
                Spacer()
                
                Text("6,93€")
                    .font(.title2.bold())
                    .foregroundColor(.textSecondary)
                    .strikethrough()
            }
            .padding(Spacing.md)
            .background(Color.cardBackground.opacity(0.5))
            .cornerRadius(CornerRadius.md)
            
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Bundle All Packs")
                        .font(.caption)
                        .foregroundColor(.appPrimary)
                    
                    Text("Économie de 3,94€ !")
                        .font(.headline)
                        .foregroundColor(.appPrimary)
                }
                
                Spacer()
                
                Text("2,99€")
                    .font(.title.bold())
                    .foregroundColor(.appPrimary)
            }
            .padding(Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.appPrimary.opacity(0.3), lineWidth: 2)
            )
        }
    }
    
    // MARK: - Avantages
    
    private var advantagesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Avantages")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                advantageRow(
                    icon: "infinity",
                    title: "Tous les packs actuels + futurs",
                    subtitle: "Accès à vie"
                )
                
                advantageRow(
                    icon: "bolt.fill",
                    title: "Déblocage instantané",
                    subtitle: "Pas d'attente"
                )
                
                advantageRow(
                    icon: "xmark.circle.fill",
                    title: "Plus de publicités",
                    subtitle: "Expérience sans interruption"
                )
                
                advantageRow(
                    icon: "star.fill",
                    title: "Économie de 3,94€",
                    subtitle: "vs achats individuels"
                )
            }
        }
    }
    
    private func advantageRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.bodyText.weight(.semibold))
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
    }
    
    // MARK: - Bouton achat
    
    private var purchaseButton: some View {
        VStack(spacing: Spacing.md) {
            Button(action: {
                Task {
                    isPurchasing = true
                    await storeManager.purchaseBundle()
                    isPurchasing = false
                }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Acheter le Bundle")
                            .fontWeight(.bold)
                        Text("•")
                        Text("2,99€")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(CornerRadius.lg)
                .shadow(
                    color: Color.appPrimary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(isPurchasing || storeManager.hasAllPacksBundle)
            
            if storeManager.hasAllPacksBundle {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentGreen)
                    Text("Déjà acheté")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Text("Achat sécurisé via Apple")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private func packEmoji(for pack: GamePack) -> String {
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
    BundlePaywallView()
}
