//
//  GamePack.swift
//  PointBoard
//
//  Created by sy2l on 06/01/2026.
//  Updated by sy2l on 21/05/2026 — V6.2.0 : App 100% gratuite (sans pub, sans IAP)
//  Updated by sy2l on 31/05/2026 — V6.2.1 : Nettoyage complet références IAP
//  Updated by sy2l on 11/08/2026 — V6.2.2 : Suppression dernière référence "packs payants"
//  Updated by sy2l on 13/08/2026 — V6.2.3 : Renommage catégories (retrait "Pack"/"Bundle")
//  -----------------------------------------------------------------------------
//  GamePack — Organisation des jeux par catégorie
//  -----------------------------------------------------------------------------
//  ⚠️ NOTE IMPORTANTE : Cette app est 100% GRATUITE.
//  Toutes les catégories sont accessibles sans achat, sans publicité, sans restriction.
//  Le système de catégories sert uniquement à organiser les 59 jeux par thème.
//  -----------------------------------------------------------------------------
//  ► Rôle
//    - Définir les catégories de jeux disponibles (tous gratuits).
//    - Associer chaque catégorie à une liste de PresetID.
//    - Fournir les infos UI (nom, description).
//    - Fournir le mapping "preset -> catégorie" pour l'affichage.
//
//  ► Détails techniques
//    - `includedPresets` est la SOURCE DE VÉRITÉ catégorie -> jeux.
//    - `presetToPackMap` construit un lookup O(1) preset -> catégorie.
//    - Le garde-fou DEBUG log un warning si un PresetID est présent dans plusieurs catégories
//      (sinon le mapping serait "écrasé" silencieusement).
//
//  ► Fonctions clés
//    - packContaining(_:) : retrouve la catégorie d'un preset (fallback coreFree)
//  -----------------------------------------------------------------------------

import Foundation

enum GamePack: String, CaseIterable, Identifiable, Codable {

    // MARK: - Catégories disponibles (toutes gratuites)

    case coreFree      = "pack_core"
    case classicCards  = "pack_cards_classic"
    case funCardsDice  = "pack_cards_fun"
    case boardFamily   = "pack_board"
    case outdoorSport  = "pack_outdoor"
    case partyNight    = "pack_party_night"
    case duelsStrategy = "pack_duels_strategy"
    case kidsFamily2   = "pack_kids_family_2"

    var id: String { rawValue }

    // MARK: - UI / Display

    var displayName: String {
        switch self {
        case .coreFree:       return "Essentiels"
        case .classicCards:   return "Cartes Classiques 🃏"
        case .funCardsDice:   return "Cartes & Dés Fun 🎲"
        case .boardFamily:    return "Société & Famille ♟️"
        case .outdoorSport:   return "Extérieur & Sport ☀️"
        case .partyNight:     return "Soirées Party 🎉"
        case .duelsStrategy:  return "Duels & Stratégie 🧠"
        case .kidsFamily2:    return "Enfants & Famille 👨‍👩‍👧‍👦"
        }
    }

    // MARK: - Description (marketing)

    var description: String {
        switch self {
        case .coreFree:
            return "Les indispensables : Uno, Skyjo, Monopoly + Modes personnalisés"

        case .classicCards:
            return "7 jeux de légende : Belote, Tarot, Rami, Poker, Président, 8 Américain, Bridge"

        case .funCardsDice:
            return "7 jeux d'ambiance : 6 qui prend, Yams, Phase 10, Dutch, Skip-Bo, 421, Yaniv"

        case .boardFamily:
            return "7 jeux de plateau : Scrabble, Domino, Triominos, Mille Bornes, Qwirkle, Rummikub, Trivial"

        case .outdoorSport:
            return "Extérieur & Bar : Mölkky, Pétanque, Fléchettes, Ping-Pong, Palet, Cornhole, Volley, Badminton"

        case .partyNight:
            return "Soirées entre amis : Dobble, Jungle Speed, Time's Up, Just One, Codenames, Loup-Garou, Perudo, Bang!"

        case .duelsStrategy:
            return "Duels & réflexion : Échecs, Dames, Backgammon, Go, Hive, Patchwork, Azul, 7 Wonders Duel"

        case .kidsFamily2:
            return "Famille & enfants : Uno Junior, Memory, Bataille, Mistigri, Dobble Kids, Halli Galli, Puissance 4, La Bonne Paye"
        }
    }

    // MARK: - Presets inclus (source de vérité pack -> presets)

    /// IMPORTANT :
    /// - Un PresetID doit appartenir à un seul pack.
    /// - Sinon, le mapping preset->pack sera écrasé (dernier pack parcouru).
    var includedPresets: [PresetID] {
        switch self {
        case .coreFree:
            // "Teaser" gratuit
            return [.generic, .wins, .uno, .skyjo, .monopoly]

        case .classicCards:
            return [.belote, .tarot, .rami, .poker, .president, .huitAmericain, .bridge]

        case .funCardsDice:
            return [.sixQuiPrend, .yams, .phase10, .dutch, .skipBo, .quatreVingtEtUn, .yaniv]

        case .boardFamily:
            return [.scrabble, .domino, .triominos, .milleBornes, .qwirkle, .rummikub, .trivial]

        case .outdoorSport:
            return [.molkky, .petanque, .darts, .pingPong, .palet, .cornhole, .volley, .badminton]

        case .partyNight:
            return [.dobble, .jungleSpeed, .timesUp, .justOne, .codenames, .loupGarou, .perudo, .bang]

        case .duelsStrategy:
            return [.chess, .checkers, .backgammon, .go, .hive, .patchwork, .azul, .sevenWondersDuel]

        case .kidsFamily2:
            return [.unoJunior, .memory, .bataille, .mistigri, .dobbleKids, .halliGalli, .puissance4, .bonnePaye]
        }
    }

    // MARK: - Helpers (preset -> pack)

    /// Mapping pré-calculé (scalable et O(1)).
    /// - DEBUG : log si un preset est présent dans plusieurs packs.
    private static let presetToPackMap: [PresetID: GamePack] = {
        var map: [PresetID: GamePack] = [:]

        for pack in GamePack.allCases {
            for preset in pack.includedPresets {

                #if DEBUG
                if let existingPack = map[preset], existingPack != pack {
                    print("⚠️ [GamePack] Preset '\(preset.rawValue)' présent dans plusieurs catégories: '\(existingPack.rawValue)' + '\(pack.rawValue)'. (Le mapping sera écrasé)")
                }
                #endif

                map[preset] = pack
            }
        }

        return map
    }()

    /// Retourne la catégorie qui contient un preset (sinon coreFree).
    /// - Utilisé pour afficher la catégorie d'un jeu dans l'UI.
    static func packContaining(_ presetID: PresetID) -> GamePack {
        return presetToPackMap[presetID] ?? .coreFree
    }
}
