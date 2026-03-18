/*
 * PackPaywallView.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by sy2l on 06/01/2026 — V4.5 (StoreKit 2 + Pro scope "4 packs de base")
 * Updated on 29/01/2026 — iOS 17 onChange fix
 * -----------------------------------------------------------------------------
 * PackPaywallView — Paywall pour acheter un pack individuel
 * -----------------------------------------------------------------------------
 * ► Rôle
 *   - Afficher le contenu d'un pack (liste des jeux / presets).
 *   - Permettre l'achat du pack (0,99€) via StoreKit 2 (StoreManager).
 *   - Proposer un upsell vers PRO, qui débloque uniquement les 4 packs de base.
 *
 * ► Fonctions clés
 *   - includedGamesList : affiche les presets inclus + état lock/unlock.
 *   - actionButtons     : achat du pack + achat Pro (optionnel).
 *
 * ► Maintenance
 *   - La logique de déblocage est centralisée dans StoreManager.isPackUnlocked(_:)
 *   - Ce fichier n’écrit aucune logique monétisation métier (ex: pubs) : UI uniquement.
 * -----------------------------------------------------------------------------
 */

import SwiftUI
import StoreKit

struct PackPaywallView: View {

    let pack: GamePack

    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    descriptionView
                    includedGamesList
                    actionButtons
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }
                }
            }
            // Si l'utilisateur achète un pack : unlockedPacks change
            .onChange(of: storeManager.unlockedPacks) { _, _ in
                if storeManager.isPackUnlocked(pack) { dismiss() }
            }
            // Si l'utilisateur achète PRO : isProUser change (unlockedPacks peut rester identique)
            .onChange(of: storeManager.isProUser) { _, _ in
                if storeManager.isPackUnlocked(pack) { dismiss() }
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(packColor.opacity(0.2))
                    .frame(width: 100, height: 100)

                Text(packEmoji)
                    .font(.system(size: 50))
            }

            Text(pack.displayName)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(pack.price)
                .font(.title2)
                .foregroundColor(packColor)
                .fontWeight(.semibold)
        }
        .padding(.top, 20)
    }

    private var descriptionView: some View {
        Text(pack.description)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }

    private var includedGamesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jeux inclus :")
                .font(.headline)
                .padding(.horizontal)

            ForEach(pack.includedPresets, id: \.self) { presetID in
                if let preset = PresetManager.availablePresets.first(where: { $0.id == presetID }) {
                    HStack {
                        Image(systemName: preset.id.iconName)
                            .foregroundColor(packColor)
                            .frame(width: 30)

                        Text(preset.displayName)
                            .font(.body)

                        Spacer()

                        Image(systemName: storeManager.isPackUnlocked(pack) ? "lock.open.fill" : "lock.fill")
                            .font(.caption)
                            .foregroundColor(storeManager.isPackUnlocked(pack) ? .green : .secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {

            // MARK: - Achat Pack

            Button(action: {
                Task {
                    isPurchasing = true
                    await storeManager.purchasePack(pack)
                    isPurchasing = false
                    // Le dismiss est géré par onChange() si l'achat réussit.
                }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Acheter le Pack")
                        Text("•")
                        Text(pack.price)
                    }
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(packColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: packColor.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .disabled(isPurchasing || storeManager.isPackUnlocked(pack))
            .padding(.horizontal)

            // MARK: - Upsell Pro (scope limité : 4 packs de base)

            if !storeManager.isProUser {
                VStack(spacing: 6) {
                    Text("ou")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        Task {
                            isPurchasing = true
                            await storeManager.purchasePro()
                            isPurchasing = false
                        }
                    }) {
                        Text("Débloquer les 4 packs de base (Pro)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(packColor)
                            .underline()
                    }
                }
            }
        }
    }

    // MARK: - UI Helpers

    private var packColor: Color {
        switch pack {
        case .coreFree:       return .gray
        case .classicCards:   return .blue
        case .funCardsDice:   return .orange
        case .boardFamily:    return .green
        case .outdoorSport:   return .yellow

        // Nouveaux packs : couleurs simples (maintenance facile)
        case .partyNight:     return .pink
        case .duelsStrategy:  return .purple
        case .kidsFamily2:    return .teal
        }
    }

    private var packEmoji: String {
        switch pack {
        case .coreFree:       return "⭐️"
        case .classicCards:   return "🃏"
        case .funCardsDice:   return "🎲"
        case .boardFamily:    return "♟️"
        case .outdoorSport:   return "☀️"

        case .partyNight:     return "🎉"
        case .duelsStrategy:  return "🧠"
        case .kidsFamily2:    return "👨‍👩‍👧‍👦"
        }
    }
}

#Preview {
    PackPaywallView(pack: .classicCards)
}
