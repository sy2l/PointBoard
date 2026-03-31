//
//  PremiumPaywallView.swift
//  PointBoard
//
//  Created on 26/03/2026.
//  -----------------------------------------------------------------------------
//  PremiumPaywallView — Interface d'achat Premium No Ads
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Présenter l'offre Premium No Ads (0,99€)
//    - Afficher les avantages (pas de pub + 12 joueurs)
//    - Gérer l'achat via StoreKit 2
//
//  ► Avantages Premium
//    - Prix : 0,99€
//    - Aucune publicité (récompensées, interstitielles, bannières)
//    - Jusqu'à 12 joueurs par partie
//    - Ne débloque PAS les packs (achat séparé)
//
//  ► Intégration
//    - Appelé depuis SettingsView (section Premium)
//    - Appelé depuis AddPlayerSheet (upsell si >6 joueurs)
//    - Dismiss automatique après achat réussi
//  -----------------------------------------------------------------------------

import SwiftUI
import StoreKit

struct PremiumPaywallView: View {
    
    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // HERO SECTION
                    heroView
                    
                    // AVANTAGES
                    advantagesSection
                    
                    // COMPARAISON PUBS
                    comparisonSection
                    
                    // BOUTON ACHAT
                    purchaseButton
                    
                    // INFO PACKS
                    packsInfoSection
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
            .onChange(of: storeManager.hasPremiumNoAds) { _, hasPremium in
                if hasPremium {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
            .onChange(of: storeManager.hasAllPacksBundle) { _, hasBundle in
                if hasBundle {
                    // Si Bundle acheté, fermer aussi (inclut Premium)
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
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("🚀")
                    .font(.system(size: 60))
            }
            
            Text("Premium No Ads")
                .font(.largeTitle.bold())
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Expérience sans interruption")
                .font(.headline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("0,99€")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.orange)
        }
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Avantages
    
    private var advantagesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Ce que vous obtenez :")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                advantageRow(
                    icon: "xmark.circle.fill",
                    iconColor: .red,
                    title: "Aucune publicité",
                    subtitle: "Toutes les pubs supprimées"
                )
                
                advantageRow(
                    icon: "person.3.fill",
                    iconColor: .blue,
                    title: "Jusqu'à 12 joueurs",
                    subtitle: "Au lieu de 6 joueurs max"
                )
                
                advantageRow(
                    icon: "bolt.fill",
                    iconColor: .yellow,
                    title: "Expérience fluide",
                    subtitle: "Parties sans interruption"
                )
                
                advantageRow(
                    icon: "infinity",
                    iconColor: .purple,
                    title: "Achat unique",
                    subtitle: "À vie, pas d'abonnement"
                )
            }
        }
    }
    
    private func advantageRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title2)
                .frame(width: 40)
            
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
    
    // MARK: - Comparaison
    
    private var comparisonSection: some View {
        VStack(spacing: Spacing.md) {
            Text("Avant / Après")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.md) {
                // AVANT
                VStack(spacing: Spacing.sm) {
                    Text("❌ Gratuit")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        comparisonItem(icon: "video.fill", text: "Pubs à chaque action", color: .red)
                        comparisonItem(icon: "6.circle.fill", text: "6 joueurs max", color: .orange)
                    }
                    .padding(Spacing.sm)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)
                }
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                // APRÈS
                VStack(spacing: Spacing.sm) {
                    Text("✅ Premium")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        comparisonItem(icon: "checkmark.circle.fill", text: "Zéro pub", color: .green)
                        comparisonItem(icon: "person.3.fill", text: "12 joueurs max", color: .blue)
                    }
                    .padding(Spacing.sm)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)
                }
            }
        }
    }
    
    private func comparisonItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.textPrimary)
        }
    }
    
    // MARK: - Bouton achat
    
    private var purchaseButton: some View {
        VStack(spacing: Spacing.md) {
            Button(action: {
                Task {
                    isPurchasing = true
                    await storeManager.purchasePremium()
                    isPurchasing = false
                }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Acheter Premium")
                            .fontWeight(.bold)
                        Text("•")
                        Text("0,99€")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(CornerRadius.lg)
                .shadow(
                    color: Color.orange.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(isPurchasing || storeManager.hasPremiumNoAds || storeManager.hasAllPacksBundle)
            
            if storeManager.hasPremiumNoAds || storeManager.hasAllPacksBundle {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentGreen)
                    Text("Déjà acheté")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Text("Achat unique • Pas d'abonnement")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Info Packs
    
    private var packsInfoSection: some View {
        VStack(spacing: Spacing.sm) {
            Divider()
            
            Text("ℹ️ Premium ne débloque PAS les packs de jeux")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("Pour tous les packs + Premium, optez pour le Bundle à 3,99€")
                .font(.caption.bold())
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    PremiumPaywallView()
}
