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
    @State private var scale: CGFloat = 1.0

    // MARK: - Timing
    private let splashDuration: Double = 2.0
    private let zoomDuration: Double = 0.5
    private let targetScale: CGFloat = 3.5

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
        ZStack {
            LinearGradient(
                colors: [Color(pbHex: "228B22"), Color(pbHex: "98FF98")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                
                Image("SplashIcon") // ✅ Mets une vraie image Assets : "SplashIcon"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: .black.opacity(0.30), radius: 10, x: 0, y: 5)
                    //.scaleEffect(scale)

                Text("PointBoard")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
    }

    // MARK: - Sequence
    @MainActor
    private func runSplashSequence() async {
        // Laisse l'écran affiché un peu
        try? await Task.sleep(nanoseconds: UInt64(splashDuration * 1_000_000_000))

        // Zoom
        withAnimation(.easeInOut(duration: zoomDuration)) {
            scale = targetScale
        }

        // Petite attente pour laisser l'animation se finir proprement
        try? await Task.sleep(nanoseconds: UInt64(zoomDuration * 1_000_000_000))

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
