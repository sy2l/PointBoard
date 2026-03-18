//
//  PaywallView.swift
//  PointBoard
//
//  Created by sy2l on 06/01/2026.
//  Updated by sy2l on 06/01/2026 — V4.5 (simple + scalable, compatible StoreManager V4.5)
//  -----------------------------------------------------------------------------
//  PaywallView — Vue d’achat du produit PRO (scope limité)
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Présenter l’offre PRO à l’utilisateur.
//    - Lancer l’achat PRO via StoreKit 2 (StoreManager.purchasePro()).
//    - Permettre la restauration via StoreManager.restorePurchases().
//    - Gérer des états UI simples : loading / succès / erreur.
//
//  ► Règle métier (V4.5)
//    - PRO débloque UNIQUEMENT les 4 packs de base (pas tous les packs).
//
//  ► Pourquoi c’est "scalable"
//    - Cette vue ne dépend pas d’un purchaseState global ou d’un tableau products.
//    - Les états sont locaux (facile à maintenir).
//    - Si tu ajoutes plus tard un chargement de prix StoreKit, tu n’auras qu’à
//      remplacer la section Pricing sans toucher au reste.
//  -----------------------------------------------------------------------------

import SwiftUI
import StoreKit

struct PaywallView: View {

    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: - UI State (local)

    @State private var isLoading: Bool = false
    @State private var showPurchaseSuccess: Bool = false
    @State private var showRestoreSuccess: Bool = false
    @State private var errorMessage: String? = nil

    // MARK: - Constants (simple)

    /// Prix affiché "fallback" (tu peux le remplacer par Product.displayPrice plus tard).
    private let proPriceFallback: String = "1,99 €"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    proScopeInfo
                    features
                    pricing
                    purchaseButton
                    restoreButton
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("PointBoard Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Fermer")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            .onChange(of: storeManager.isProUser) { _, isPro in
                // Si l'achat a réussi, StoreManager passe isProUser à true :
                if isPro {
                    showPurchaseSuccess = true
                }
            }
            .alert("Achat réussi", isPresented: $showPurchaseSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Merci ! Le mode Pro est activé : les 4 packs de base sont maintenant débloqués.")
            }
            .alert("Achats restaurés", isPresented: $showRestoreSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Vos achats ont été restaurés avec succès.")
            }
            .alert("Erreur", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Une erreur inconnue est survenue.")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [Color.accentGreen, Color(pbHex: "FOF4EF")],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )

            Text("Passez en Pro")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Débloquez les packs de base et soutenez le développement.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Pro Scope Info (important pour éviter la confusion)

    private var proScopeInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ce que débloque Pro :")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Label("Pack Cartes Classiques 🃏", systemImage: "checkmark.seal.fill")
                Label("Pack Cartes & Dés Fun 🎲", systemImage: "checkmark.seal.fill")
                Label("Pack Société & Famille ♟️", systemImage: "checkmark.seal.fill")
                Label("Pack Extérieur & Sport ☀️", systemImage: "checkmark.seal.fill")
            }
            .foregroundColor(Color.textSecondary)

            Text("Les packs ajoutés plus tard peuvent rester vendus séparément.")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Features (garde simple, aligné sur ton nouveau modèle)

    private var features: some View {
        VStack(spacing: 16) {
            FeatureRow(
                icon: "square.grid.2x2.fill",
                title: "4 packs de jeux",
                description: "Accédez immédiatement aux packs de base."
            )

            FeatureRow(
                icon: "hand.thumbsup.fill",
                title: "Soutien au projet",
                description: "Vous aidez l’app à grandir et à être améliorée."
            )

            FeatureRow(
                icon: "bolt.fill",
                title: "Expérience plus fluide",
                description: "Un accès direct aux packs de base sans friction."
            )
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Pricing

    private var pricing: some View {
        VStack(spacing: 8) {
            Text(proPriceFallback)
                .font(.system(size: 46, weight: .bold))

            Text("Achat unique • Aucun abonnement")
                .font(.caption)
                .foregroundColor(.textPrimary)

            if storeManager.isProUser {
                Text("✅ Pro déjà activé")
                    .font(.footnote)
                    .foregroundColor(Color.accentGreen)
            }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await buyPro() }
        } label: {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "crown.fill")
                    Text(storeManager.isProUser ? "Pro activé" : "Acheter Pro")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(colors: [Color.accentGreen, Color(pbHex: "FOF4EF")],
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading || storeManager.isProUser)
    }

    // MARK: - Restore Button

    private var restoreButton: some View {
        Button {
            Task { await restore() }
        } label: {
            Text("Restaurer les achats")
                .font(.subheadline)
                .foregroundColor(.textPrimary)
        }
        .disabled(isLoading)
        .padding(.top, 4)
    }

    // MARK: - Actions (isolées = scalable)

    /// Lance l'achat Pro et gère les états UI.
    private func buyPro() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Si jamais tu veux afficher un "succès" même sans onChange:
        // on laisse StoreManager mettre isProUser à true.
        await storeManager.purchasePro()

        // Si l'achat a été annulé, isProUser restera false.
        if !storeManager.isProUser {
            // On ne peut pas distinguer annulation vs échec sans remonter un résultat.
            // Donc on reste silencieux (UX Apple-style).
        }
    }

    /// Restaure les achats et affiche un feedback simple.
    private func restore() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        await storeManager.restorePurchases()
        showRestoreSuccess = true
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.accentGreen)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Paywall") {
    PaywallView()
}
