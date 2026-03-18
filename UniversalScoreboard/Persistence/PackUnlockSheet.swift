//
//  PackUnlockSheet.swift
//  PointBoard
//
//  Created on 18/03/2026.
//  -----------------------------------------------------------------------------
//  PackUnlockSheet — Interface de déblocage d'un pack (3 méthodes)
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Afficher les 3 options de déblocage pour un pack :
//      1. Achat direct (0,99€)
//      2. 10 publicités
//      3. 5 jours consécutifs (streak)
//    - Afficher la progression actuelle (pubs/streak)
//    - Proposer le Bundle All Packs en alternative
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
    @ObservedObject private var progressManager = UnlockProgressManager.shared
    @ObservedObject private var adManager = AdManager.shared
    @ObservedObject private var streakManager = DailyStreakManager.shared
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    @State private var showBundleView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // HEADER
                    headerView
                    
                    // LISTE JEUX INCLUS
                    includedGamesSection
                    
                    Divider()
                    
                    // TITRE SECTION
                    Text("Comment débloquer ?")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    // OPTION 1 : ACHAT
                    purchaseCard
                    
                    // OPTION 2 : PUBS
                    adsCard
                    
                    // OPTION 3 : STREAK
                    streakCard
                    
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
    
    // MARK: - Option 1 : Achat
    
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
                .padding()
                .background(Color.accentGreen)
                .foregroundColor(.white)
                .cornerRadius(CornerRadius.md)
            }
            .disabled(isPurchasing)
        }
        .padding(Spacing.lg)
        .background(Color.accentGreen.opacity(0.1))
        .cornerRadius(CornerRadius.lg)
    }
    
    // MARK: - Option 2 : Pubs
    
    private var adsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Text("📺")
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("10 Publicités")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(progressManager.adProgressText(for: pack))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
            
            // Indicateur visuel (10 carrés)
            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { index in
                    let watched = progressManager.adsWatchedPerPack[pack, default: 0]
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index < watched ? Color.accentGreen : Color.gray.opacity(0.3))
                        .frame(height: 8)
                }
            }
            
            Button(action: {
                if progressManager.canUnlockWithAds(pack) {
                    progressManager.unlockWithAds(pack)
                } else {
                    adManager.showRewardedAd { success in
                        if success {
                            progressManager.incrementAdCount(for: pack)
                        }
                    }
                }
            }) {
                Text(progressManager.canUnlockWithAds(pack) ? "Débloquer maintenant !" : "Regarder une pub")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(CornerRadius.md)
            }
        }
        .padding(Spacing.lg)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(CornerRadius.lg)
    }
    
    // MARK: - Option 3 : Streak
    
    private var streakCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Text("🔥")
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("5 Jours Consécutifs")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(progressManager.streakProgressText())
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    if streakManager.currentStreak == 4 {
                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.yellow)
                            Text("Demain = cadeau !")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if streakManager.jokerAvailable {
                        Text(progressManager.jokerStatusText())
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
            }
            
            // Indicateur flammes (5)
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < streakManager.currentStreak ? "flame.fill" : "flame")
                        .foregroundColor(index < streakManager.currentStreak ? .orange : .gray.opacity(0.3))
                        .font(.caption)
                }
            }
            
            Button(action: {
                if progressManager.canUnlockWithStreak(pack) {
                    progressManager.unlockWithStreak(pack)
                }
            }) {
                Text(progressManager.canUnlockWithStreak(pack) ? "Débloquer maintenant !" : "Reviens demain !")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(progressManager.canUnlockWithStreak(pack) ? Color.orange : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(CornerRadius.md)
            }
            .disabled(!progressManager.canUnlockWithStreak(pack))
        }
        .padding(Spacing.lg)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(CornerRadius.lg)
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
                    Text("Tout débloquer pour 2,99€")
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
