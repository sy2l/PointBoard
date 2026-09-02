//
//  SearchBarView.swift
//  PointBoard
//
//  Created by sy2l on 31/08/2026
//  -----------------------------------------------------------------------------
//  SearchBarView — Barre de recherche moderne avec bouton X
//  -----------------------------------------------------------------------------
//  Design inspiré d'iOS moderne avec:
//  - TextField avec placeholder
//  - Icône loupe à gauche
//  - Bouton X circulaire à droite (apparaît après saisie)
//  - Fond clair avec shadow subtile
//  - 100% Design System (adaptatif Light/Dark)
//  -----------------------------------------------------------------------------

import SwiftUI

struct SearchBarView: View {
    
    // MARK: - Bindings
    
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    
    // MARK: - Inputs
    
    let placeholder: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // MARK: - Icône loupe
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
                .font(.system(size: IconSize.md))
            
            // MARK: - TextField
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .font(.body)
                .foregroundColor(.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            // MARK: - Bouton circulaire (à l'intérieur)
            Button(action: {
                if !text.isEmpty {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        text = ""
                        isFocused = false
                    }
                } else {
                    isFocused = true
                }
            }) {
                Image(systemName: text.isEmpty ? "magnifyingglass" : "xmark")
                    .font(.system(size: IconSize.sm, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: ButtonSize.md, height: ButtonSize.md)
                    .background(
                        Circle()
                            .fill(Color.appPrimary)
                    )
                    .shadow(
                        color: Color.appPrimary.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .frame(height: ComponentHeight.searchBar)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ComponentHeight.searchBar / 2, style: .continuous))
        .shadow(
            color: AppShadow.card.color,
            radius: 2,
            x: 0,
            y: 1
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text.isEmpty)
    }
}

// MARK: - Preview

#Preview("SearchBar - Empty") {
    struct PreviewWrapper: View {
        @State private var text = ""
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack(spacing: Spacing.lg) {
                SearchBarView(
                    text: $text,
                    isFocused: $isFocused,
                    placeholder: "Search anything..."
                )
                
                Text("Empty state")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.appBackground)
        }
    }
    
    return PreviewWrapper()
}

#Preview("SearchBar - With text") {
    struct PreviewWrapper: View {
        @State private var text = "Uno"
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack(spacing: Spacing.lg) {
                SearchBarView(
                    text: $text,
                    isFocused: $isFocused,
                    placeholder: "Search anything..."
                )
                
                Text("With text + X button")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.appBackground)
        }
    }
    
    return PreviewWrapper()
}

#Preview("SearchBar - Dark Mode") {
    struct PreviewWrapper: View {
        @State private var text = "Belote"
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack(spacing: Spacing.lg) {
                SearchBarView(
                    text: $text,
                    isFocused: $isFocused,
                    placeholder: "Search anything..."
                )
                
                Text("Dark mode test")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.appBackground)
            .preferredColorScheme(.dark)
        }
    }
    
    return PreviewWrapper()
}
