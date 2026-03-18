//
//  AdBannerView.swift
//  PointBoard
//
//  Created on 28/01/2026.
//  -----------------------------------------------------------------------------
//  AdBannerView — Composant SwiftUI pour afficher les bannières publicitaires natives
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Afficher une bannière publicitaire native en bas des écrans Historique et Stats
//    - Intégration avec Google AdMob (SDK à brancher via CocoaPods/SPM)
//    - Masquer automatiquement si l'utilisateur est Pro ou en essai
//
//  ► Utilisation
//    - Ajouter ce composant en bas d'une VStack dans HistoryView ou PlayerStatsView
//    - Exemple : AdBannerView().frame(height: 50)
//
//  ► Notes maintenance
//    - Le composant est un stub pour l'instant (SDK AdMob non intégré)
//    - Voir documentation d'intégration AdMob pour brancher le SDK
//  -----------------------------------------------------------------------------

import SwiftUI

struct AdBannerView: View {
    @ObservedObject private var adManager = AdManager.shared
    
    var body: some View {
        if adManager.shouldShowBanner() {
            ZStack {
                // Placeholder pour la bannière (à remplacer par le composant AdMob)
                Rectangle()
                    .fill(Color.textSecondary.opacity(0.2))
                    .frame(height: 50)
                    .overlay(
                        Text("Publicité")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    )
            }
            .onAppear {
                adManager.loadBannerAd()
            }
        }
    }
}

#Preview {
    AdBannerView()
}
