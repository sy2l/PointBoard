//
//  SplashScreenView.swift
//  PointBoard
//
//  Created on 28/01/2026.
//  Updated on 03/02/2026 — Fix animation reliability + single routing + safe task
//  -----------------------------------------------------------------------------
//  SplashScreenView — Écran de lancement avec animation
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Afficher l'icône + le titre "PointBoard" au lancement
//    - Lancer un petit zoom puis router vers l'app (MainTabView ou GameView)
//    - Éviter les crashs liés aux dispatch asyncAfter / double routing
//
//  ► Points importants
//    - Ne PAS ré-injecter environmentObject ici : il vient du root App.
//    - Utilise `.task` (annulable) au lieu de DispatchQueue.
//    - L'image "AppIcon" peut ne pas exister si c'est un App Icon Set.
//      ✅ Recommandé : mettre une vraie image dans Assets nommée "SplashIcon".
//
//  -----------------------------------------------------------------------------

import SwiftUI

struct SplashScreenView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var viewModel: GameViewModel

    // MARK: - State
    @State private var isActive: Bool = false

    // MARK: - Timing
    private let splashDuration: Double = 2.0

    // MARK: - Computed
    private var shouldResumeGame: Bool {
        viewModel.game != nil
    }

    // MARK: - Body
    var body: some View {
        Group {
            if isActive {
                if shouldResumeGame {
                    GameView()
                } else {
                    MainTabView()
                }
            } else {
                splashContent
            }
        }
        // `.task` est annulé automatiquement si la vue disparaît
        .task {
            await runSplashSequence()
        }
    }

    // MARK: - UI
    private var splashContent: some View {
        Image("Splashscreen")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    // MARK: - Sequence
    @MainActor
    private func runSplashSequence() async {
        // Affiche le splash pendant 2 secondes
        try? await Task.sleep(nanoseconds: UInt64(splashDuration * 1_000_000_000))

        // Route vers l'app
        withAnimation(.easeInOut(duration: 0.25)) {
            isActive = true
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(GameViewModel())
}
