//
// DesignSystem.swift
// PointBoard
//
// Created on 20/01/2026.
// Updated on 29/01/2026 - Ajout de la palette de couleurs centralisée Light/Dark
//
// -----------------------------------------------------------------------------
// DesignSystem — Système de design centralisé pour PointBoard
// -----------------------------------------------------------------------------
// ► Rôle
//   - Centraliser toutes les couleurs, typographies, espacements, et styles
//   - Gérer automatiquement le mode Light et Dark
//   - Faciliter la maintenance : changer une couleur ici change toute l'app
//
// ► Palette de Couleurs
//   Les codes couleurs sont définis ici et s'adaptent automatiquement au mode :
//   - Ink Black (#0D1821) : Texte principal, fond dark
//   - Yale Blue (#344966) : Fond secondaire, éléments interactifs
//   - Powder Blue (#B4CDED) : Accents, bordures
//   - Porcelain (#F0F4EF) : Fond light, cartes
//   - Dry Sage (#BFCC94) : Accents verts, succès
//
// ► Utilisation
//   - Utiliser `Color.appBackground` au lieu de `Color.white`
//   - Utiliser `Color.appPrimary` au lieu de `Color.blue`
//   - Utiliser `Font.appTitle` au lieu de `Font.largeTitle`
//
// ► Notes maintenance
//   - Pour changer une couleur : modifier le code hex ci-dessous
//   - Pour ajouter une couleur : ajouter une nouvelle extension Color
//   - Ne jamais utiliser de couleurs en dur dans les Views
// -----------------------------------------------------------------------------

import SwiftUI
import UIKit

// MARK: - Color Palette
extension Color {

    // MARK: - Palette Principale (Light/Dark adaptatif)
    static let appBackground: Color = Color.assetOrDynamic(
        "AppBackground",
        light: Color(pbHex: "F2F2F7"), // Gris clair iOS (au lieu de blanc)
        dark: Color(pbHex: "0D1821")
    )

    static let appPrimary: Color = Color.assetOrDynamic(
        "AppPrimary",
        light: Color(pbHex: "344966"),
        dark: Color(pbHex: "B4CDED")
    )

    static let appSecondary: Color = Color.assetOrDynamic(
        "AppSecondary",
        light: Color(pbHex: "B4CDED"),
        dark: Color(pbHex: "344966")
    )

    static let cardBackground: Color = Color.assetOrDynamic(
        "CardBackground",
        light: Color.white,
        dark: Color(pbHex: "344966")
    )

    static let textPrimary: Color = Color.assetOrDynamic(
        "TextPrimary",
        light: Color(pbHex: "0D1821"),
        dark: Color(pbHex: "F0F4EF")
    )

    static let textSecondary: Color = Color.assetOrDynamic(
        "TextSecondary",
        light: Color(pbHex: "344966"),
        dark: Color(pbHex: "B4CDED")
    )

    static let accentGreen: Color = Color.assetOrDynamic(
        "AccentGreen",
        light: Color(pbHex: "BFCC94"),
        dark: Color(pbHex: "BFCC94")
    )
    
    static let accentBlue: Color = Color.assetOrDynamic(
        "AccentGreen",
        light: Color(pbHex: "235789"),
        dark: Color(pbHex: "235789")
    )
    
    static let accentRed: Color = Color.assetOrDynamic(
        "AccentGreen",
        light: Color(pbHex: "ED1C24"),
        dark: Color(pbHex: "ED1C24")
    )
    
    static let accentYellow: Color = Color.assetOrDynamic(
        "AccentGreen",
        light: Color(pbHex: "F1D302"),
        dark: Color(pbHex: "F1D302")
    )
    
    static let whiteBackground: Color = Color(pbHex: "FDFFFC")
    
    static let sectionTitle: Color = Color(pbHex: "020100")

    // MARK: - Utilitaires / Sémantiques
    static let cardShadow: Color = Color.black.opacity(0.10)

    static let success: Color = Color.green
    static let warning: Color = Color.orange
    static let error: Color = Color.red
    static let info: Color = Color.blue

    // MARK: - Gradient
    static func gameGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Internal helpers

    /// Tente de charger une couleur depuis Assets.
    /// Si l'asset n'existe pas, fallback vers une couleur dynamique Light/Dark.
    fileprivate static func assetOrDynamic(_ assetName: String, light: Color, dark: Color) -> Color {
        if let uiColor: UIColor = UIColor(named: assetName) {
            return Color(uiColor)
        }
        return Color(light: light, dark: dark)
    }

    /// Couleur dynamique Light/Dark
    init(light: Color, dark: Color) {
        let dynamicUIColor: UIColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: return UIColor(dark)
            default: return UIColor(light)
            }
        }
        self.init(dynamicUIColor)
    }

    /// Hex helper renommé pour éviter conflit avec un autre `init(hex:)` dans ton projet.
    init(pbHex: String) {
        let cleaned: String = pbHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}

// MARK: - Typography
extension Font {
    static let appTitle: Font = Font.system(size: 28, weight: .bold, design: .rounded)
    static let cardTitle: Font = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let cardSubtitle: Font = Font.system(size: 14, weight: .regular, design: .rounded)
    static let bodyText: Font = Font.system(size: 16, weight: .regular, design: .default)
    static let caption: Font = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 44
}

// MARK: - Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Component Heights
enum ComponentHeight {
    static let searchBar: CGFloat = 52
    static let button: CGFloat = 48
    static let textField: CGFloat = 44
}

// MARK: - Icon Sizes
enum IconSize {
    static let xs: CGFloat = 12
    static let sm: CGFloat = 14
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Button Sizes
enum ButtonSize {
    static let sm: CGFloat = 32
    static let md: CGFloat = 40
    static let lg: CGFloat = 48
    static let xl: CGFloat = 56
}

// MARK: - Glass Materials
enum GlassMaterial {
    /// Ultra thin material (très transparent)
    static let ultraThin = Material.ultraThinMaterial
    
    /// Thin material (transparent)
    static let thin = Material.thinMaterial
    
    /// Regular material (semi-transparent)
    static let regular = Material.regularMaterial
    
    /// Thick material (peu transparent)
    static let thick = Material.thickMaterial
    
    /// Ultra thick material (presque opaque)
    static let ultraThick = Material.ultraThickMaterial
}

// MARK: - Shadow
struct AppShadow {
    static let card: Shadow = Shadow(
        color: Color.cardShadow,
        radius: 8,
        x: 0,
        y: 4
    )

    static let elevated: Shadow = Shadow(
        color: Color.cardShadow,
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let glass: Shadow = Shadow(
        color: Color.black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(
                color: AppShadow.card.color,
                radius: AppShadow.card.radius,
                x: AppShadow.card.x,
                y: AppShadow.card.y
            )
    }
}

struct ElevatedCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.xl)
            .shadow(
                color: AppShadow.elevated.color,
                radius: AppShadow.elevated.radius,
                x: AppShadow.elevated.x,
                y: AppShadow.elevated.y
            )
    }
}

extension View {
    func modernCardStyle() -> some View {
        modifier(CardModifier())
    }

    func modernElevatedCardStyle() -> some View {
        modifier(ElevatedCardModifier())
    }
    
    func gamingButtonStyle() -> some View {
        buttonStyle(GamingButtonStyle())
    }
}

// MARK: - Gaming Button Style (3D effect like GameSelectionCard)
struct GamingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.lg)
            .background(
                LinearGradient(
                    colors: [
                        Color.accentGreen.opacity(0.9),
                        Color.accentGreen
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            .shadow(
                color: Color.accentGreen.opacity(0.5),
                radius: configuration.isPressed ? 4 : 12,
                x: 0,
                y: configuration.isPressed ? 2 : 8
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: configuration.isPressed ? 1 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
