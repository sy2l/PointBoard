/*
 * PresetThemeID.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by sy2l on 06/01/2026 — V4.5 (thèmes nouveaux presets)
 * -----------------------------------------------------------------------------
 * PresetTheme — Identité visuelle des jeux (couleur + icône)
 * -----------------------------------------------------------------------------
 * ► Rôle
 *   - Fournir un thème UI stable par PresetID :
 *       - themeColor : couleur principale
 *       - iconName   : SF Symbol (listes, tuiles, paywalls)
 *
 * ► Maintenance
 *   - À chaque ajout de PresetID, ajouter un case ici (switch exhaustif).
 *   - Les SF Symbols non disponibles sur une version iOS donnée n'empêchent pas
 *     la compilation, mais peuvent afficher une icône vide → privilégier des
 *     symboles "classiques".
 * -----------------------------------------------------------------------------
 */

import SwiftUI

extension PresetID {

    // MARK: - Couleur principale

    var themeColor: Color {
        switch self {

        // --- Core ---
        case .generic: return Color.appPrimary
        case .wins: return .yellow

        // --- Cartes Classiques ---
        case .uno: return .red
        case .belote, .tarot, .bridge: return Color(red: 0.0, green: 0.5, blue: 0.0)
        case .rami: return .blue
        case .poker: return .black
        case .president: return .purple
        case .huitAmericain: return .orange

        // --- Fun & Dés ---
        case .skyjo: return Color(red: 0.0, green: 0.6, blue: 0.5)
        case .sixQuiPrend: return .orange
        case .yams: return .purple
        case .phase10: return .green
        case .dutch: return .blue
        case .skipBo: return .red
        case .quatreVingtEtUn: return .pink
        case .yaniv: return Color(red: 0.8, green: 0.4, blue: 0.0)

        // --- Société ---
        case .scrabble: return Color(red: 0.0, green: 0.4, blue: 0.2)
        case .monopoly: return Color(red: 0.8, green: 0.0, blue: 0.0)
        case .domino, .triominos: return .black
        case .milleBornes: return .green
        case .qwirkle: return .orange
        case .rummikub: return .blue
        case .trivial: return .yellow

        // --- Extérieur ---
        case .molkky: return .brown
        case .petanque, .palet: return .gray
        case .darts: return .red
        case .pingPong: return .blue
        case .cornhole: return .orange
        case .volley: return .yellow
        case .badminton: return .green

        // --- Party Night 🎉 ---
        case .dobble: return .pink
        case .jungleSpeed: return .red
        case .timesUp: return .orange
        case .justOne: return .yellow
        case .codenames: return .blue
        case .loupGarou: return .purple
        case .perudo: return .green
        case .bang: return .brown

        // --- Duels & Stratégie 🧠 ---
        case .chess: return .black
        case .checkers: return .gray
        case .backgammon: return .orange
        case .go: return .black
        case .hive: return .yellow
        case .patchwork: return .pink
        case .azul: return .blue
        case .sevenWondersDuel: return .red

        // --- Kids & Famille 👨‍👩‍👧‍👦 2 ---
        case .unoJunior: return .red
        case .memory: return .blue
        case .bataille: return .orange
        case .mistigri: return .purple
        case .dobbleKids: return .pink
        case .halliGalli: return .yellow
        case .puissance4: return .green
        case .bonnePaye: return .brown
        }
    }

    // MARK: - Icône SF Symbol

    var iconName: String {
        switch self {

        // --- Core ---
        case .generic: return "pencil.and.outline"
        case .wins: return "trophy.fill"

        // --- Cartes Classiques ---
        case .uno: return "rectangle.portrait.on.rectangle.portrait.angled.fill"
        case .belote, .tarot, .bridge: return "suit.spade.fill"
        case .rami: return "list.number"
        case .poker: return "suit.club.fill"
        case .president: return "crown.fill"
        case .huitAmericain: return "8.circle.fill"

        // --- Fun & Dés ---
        case .skyjo: return "square.grid.3x3.fill"
        case .sixQuiPrend: return "6.circle.fill"
        case .yams: return "die.face.5.fill"
        case .phase10: return "10.circle.fill"
        case .dutch: return "bolt.fill"
        case .skipBo: return "arrow.right.circle.fill"
        case .quatreVingtEtUn: return "die.face.4.fill"
        case .yaniv: return "hand.raised.fill"

        // --- Société ---
        case .scrabble: return "character.cursor.ibeam"
        case .monopoly: return "banknote.fill"
        case .domino, .triominos: return "rectangle.split.2x1"
        case .milleBornes: return "car.fill"
        case .qwirkle: return "square.grid.2x2.fill"
        case .rummikub: return "123.rectangle.fill"
        case .trivial: return "lightbulb.fill"

        // --- Extérieur ---
        case .molkky: return "figure.bowling"
        case .petanque, .palet: return "circle.circle.fill"
        case .darts: return "target"
        case .pingPong: return "tennis.racket"
        case .cornhole: return "square.fill"
        case .volley: return "figure.volleyball"
        case .badminton: return "figure.badminton"

        // --- Party Night 🎉 ---
        case .dobble: return "circle.grid.3x3.fill"
        case .jungleSpeed: return "hand.tap.fill"
        case .timesUp: return "timer"
        case .justOne: return "1.circle.fill"
        case .codenames: return "bubble.left.and.bubble.right.fill"
        case .loupGarou: return "moon.stars.fill"
        case .perudo: return "die.face.6.fill"
        case .bang: return "burst.fill"

        // --- Duels & Stratégie 🧠 ---
        case .chess: return "crown"                // icône simple (évite symboles trop exotiques)
        case .checkers: return "circle.grid.2x2.fill"
        case .backgammon: return "rectangle.split.2x1"
        case .go: return "circle.grid.3x3"
        case .hive: return "hexagon.fill"
        case .patchwork: return "scissors"
        case .azul: return "square.grid.3x3"
        case .sevenWondersDuel: return "building.columns.fill"

        // --- Kids & Famille 👨‍👩‍👧‍👦 2 ---
        case .unoJunior: return "rectangle.portrait.on.rectangle.portrait.angled.fill"
        case .memory: return "brain.head.profile"
        case .bataille: return "suit.heart.fill"
        case .mistigri: return "cat.fill"
        case .dobbleKids: return "sparkles"
        case .halliGalli: return "bell.fill"
        case .puissance4: return "4.circle.fill"
        case .bonnePaye: return "banknote.fill"
        }
    }

    // MARK: - Helpers UI

    var backgroundWithOpacity: Color { themeColor.opacity(0.15) }
    var accentWithOpacity: Color { themeColor.opacity(0.8) }
}
