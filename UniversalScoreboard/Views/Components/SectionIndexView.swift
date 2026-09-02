 //
//  SectionIndexView.swift
//  PointBoard
//
//  Created by sy2l on 31/08/2026
//  -----------------------------------------------------------------------------
//  SectionIndexView — Index alphabétique vertical (A-Z)
//  -----------------------------------------------------------------------------
//  Composant réutilisable inspiré du Section Index iOS (Contacts)
//  Version moderne avec glassmorphism, animations circulaires, et haptic feedback
//
//  Features:
//  - Lettres A-Z alignées verticalement
//  - Tap/Drag pour scroller vers section
//  - Design circulaire sur selection
//  - Popup central temporaire
//  - Lettres inactives en gris
//  - Haptic feedback
//  - Utilise le Design System (Color.appPrimary, Spacing, etc.)
//  -----------------------------------------------------------------------------

import SwiftUI

// MARK: - SectionIndexView

struct SectionIndexView: View {
    
    // MARK: - Inputs
    
    /// Lettres disponibles (ex: ["A", "B", "D"] → pas de "C")
    let availableLetters: [String]
    
    /// Callback quand on tap/drag sur une lettre
    let onLetterSelected: (String) -> Void
    
    // MARK: - State
    
    @State private var selectedLetter: String? = nil
    @State private var showPopup: Bool = false
    
    // MARK: - Constants
    
    private let allLetters = ["#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                              "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // MARK: - Index vertical (droite)
            VStack(spacing: 3) {
                ForEach(allLetters, id: \.self) { letter in
                    LetterButton(
                        letter: letter,
                        isAvailable: availableLetters.contains(letter),
                        isSelected: selectedLetter == letter,
                        onTap: {
                            handleLetterTap(letter)
                        }
                    )
                }
            }
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, 6)
            .background(GlassMaterial.ultraThin)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(
                color: AppShadow.glass.color,
                radius: AppShadow.glass.radius,
                x: AppShadow.glass.x,
                y: AppShadow.glass.y
            )
            
            // MARK: - Popup central (temporaire)
            if showPopup, let letter = selectedLetter {
                PopupLetterView(letter: letter)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDrag(at: value.location)
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLetter = nil
                        showPopup = false
                    }
                }
        )
    }
    
    // MARK: - Helpers
    
    private func handleLetterTap(_ letter: String) {
        guard availableLetters.contains(letter) else { return }
        
        triggerHaptic()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedLetter = letter
            showPopup = true
        }
        
        onLetterSelected(letter)
        
        // Hide popup après 0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                showPopup = false
            }
        }
    }
    
    private func handleDrag(at location: CGPoint) {
        // Déterminer la lettre sous le doigt (espacement ~21pt par lettre)
        let index = Int(location.y / 21)
        guard index >= 0, index < allLetters.count else { return }
        
        let letter = allLetters[index]
        guard availableLetters.contains(letter) else { return }
        
        if selectedLetter != letter {
            triggerHaptic()
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                selectedLetter = letter
                showPopup = true
            }
            
            onLetterSelected(letter)
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium) // ← Plus prononcé
        generator.impactOccurred()
    }
}

// MARK: - LetterButton (bouton individuel avec design circulaire)

private struct LetterButton: View {
    
    let letter: String
    let isAvailable: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(letter)
                .font(.system(size: isSelected ? 12 : 10, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : (isAvailable ? .appPrimary : .gray.opacity(0.3)))
                .frame(width: isSelected ? 26 : 20, height: isSelected ? 26 : 20)
                .background(
                    Circle()
                        .fill(isSelected ? Color.accentBlue : Color.clear)
                )
                .overlay(
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.white.opacity(0.3) : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: isSelected ? Color.appPrimary.opacity(0.3) : Color.clear,
                    radius: isSelected ? 6 : 0,
                    x: 0,
                    y: isSelected ? 2 : 0
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}

// MARK: - PopupLetterView (popup central)

private struct PopupLetterView: View {
    
    let letter: String
    
    var body: some View {
        ZStack {
            // Background circulaire avec glassmorphism
            Circle()
                .fill(GlassMaterial.ultraThin)
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(
                    color: AppShadow.glass.color,
                    radius: 20,
                    x: 0,
                    y: 10
                )
            
            // Lettre
            Text(letter)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.accentBlue)
        }
    }
}

// MARK: - Preview

#Preview("Section Index - Full") {
    ZStack(alignment: .trailing) {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        SectionIndexView(
            availableLetters: ["#", "A", "B", "C", "D", "M", "P", "S", "T", "U", "Y"],
            onLetterSelected: { letter in
                print("Selected: \(letter)")
            }
        )
        .padding(.trailing, 8)
    }
}

#Preview("Section Index - All letters") {
    ZStack(alignment: .trailing) {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        SectionIndexView(
            availableLetters: ["#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                              "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"],
            onLetterSelected: { letter in
                print("Selected: \(letter)")
            }
        )
        .padding(.trailing, 8)
    }
}
