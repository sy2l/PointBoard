/*
 FakeAdView.swift
 PointBoard
 
 Vue factice pour simuler les publicités en attendant l'intégration d'AdMob.
 
 Fonctionnalités :
 - Affiche "PUB DE 15 SEC" ou "PUB DE 45 SEC"
 - Bouton de fermeture (X) en haut à droite
 - Compte à rebours simulé
 
 Technique :
 - @Binding pour contrôler l'affichage depuis la vue parente
 - Timer pour simuler la durée de la pub
 - Design cohérent avec le DesignSystem
 
 Created on 02/02/2026
 */

import SwiftUI

struct FakeAdView: View {
    @Binding var isPresented: Bool
    let duration: Int // Durée en secondes (15 ou 45)
    let onComplete: () -> Void
    
    @State private var remainingTime: Int
    @State private var timer: Timer?
    
    init(isPresented: Binding<Bool>, duration: Int, onComplete: @escaping () -> Void) {
        self._isPresented = isPresented
        self.duration = duration
        self.onComplete = onComplete
        self._remainingTime = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            // Fond semi-transparent
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // Icône de publicité
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appPrimary)
                
                // Texte de la pub
                VStack(spacing: Spacing.sm) {
                    Text("PUBLICITÉ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("PUB DE \(duration) SEC")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Compte à rebours
                Text("\(remainingTime) secondes")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.accentGreen)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(CornerRadius.md)
                
                // Bouton de fermeture (visible après 3 secondes)
                if remainingTime <= duration - 3 {
                    Button(action: closeAd) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Fermer")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.appPrimary)
                        .cornerRadius(CornerRadius.md)
                    }
                }
            }
            .padding(Spacing.xl)
            
            // Bouton X en haut à droite (toujours visible)
            VStack {
                HStack {
                    Spacer()
                    Button(action: closeAd) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(Spacing.lg)
                }
                Spacer()
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                closeAd()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func closeAd() {
        stopTimer()
        onComplete()
        isPresented = false
    }
}

// MARK: - Preview
struct FakeAdView_Previews: PreviewProvider {
    static var previews: some View {
        FakeAdView(
            isPresented: .constant(true),
            duration: 15,
            onComplete: {}
        )
    }
}
