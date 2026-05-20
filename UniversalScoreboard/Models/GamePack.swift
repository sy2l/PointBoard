//
//  GamePack.swift
//  PointBoard
//
//  Created by sy2l on 06/01/2026.
//  Updated by sy2l on 21/05/2026 — V6.2.0 : App 100% gratuite (sans pub, sans IAP)
//  -----------------------------------------------------------------------------
//  GamePack — Système de packs (monétisation)
//  -----------------------------------------------------------------------------
//  ► Rôle (simple)
//    - Définir les packs disponibles (gratuits + payants).
//    - Associer chaque pack à une liste de PresetID.
//    - Fournir les infos boutique (nom, prix, productID, description).
//    - Fournir le mapping "preset -> pack" pour le gating UI.
//
//  ► Rôle (détaillé)
//    - `includedPresets` est la SOURCE DE VÉRITÉ pack -> jeux.
//    - `presetToPackMap` construit un lookup O(1) preset -> pack.
//    - Le garde-fou DEBUG log un warning si un PresetID est présent dans plusieurs packs
//      (sinon le mapping serait “écrasé” silencieusement).
//
//  ► Fonctions clés
//    - packContaining(_:) : retrouve le pack d’un preset (fallback coreFree)
//    - paidPacks         : liste des packs payants (pour la boutique)
//  -----------------------------------------------------------------------------

import Foundation

enum GamePack: String, CaseIterable, Identifiable, Codable {

    // MARK: - Packs disponibles (tous gratuits)

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
        case .coreFree:       return "Basiques & Démos"
        case .classicCards:   return "Pack Cartes Classiques 🃏"
        case .funCardsDice:   return "Pack Cartes & Dés Fun 🎲"
        case .boardFamily:    return "Pack Société & Famille ♟️"
        case .outdoorSport:   return "Pack Extérieur & Sport ☀️"
        case .partyNight:     return "Pack Party Night 🎉"
        case .duelsStrategy:  return "Pack Duels & Stratégie 🧠"
        case .kidsFamily2:    return "Pack Kids & Famille 👨‍👩‍👧‍👦 2"
        }
    }

    /// Prix “string” (simple UI).
    /// - Note : si tu veux le vrai prix StoreKit (localisé), récupère Product.displayPrice côté StoreManager.
    var price: String {
        // Tous les packs sont gratuits
        switch self {
        case .coreFree, .classicCards, .funCardsDice, .boardFamily, .outdoorSport, .partyNight, .duelsStrategy, .kidsFamily2:
            return "Gratuit"
        }
    }

    // MARK: - StoreKit Product IDs

    /// Obsolète: les IAP sont retirés, conserver pour compatibilité binaire.
    var productID: String? {
        return nil
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
            return "Soirées entre amis : Dobble, Jungle Speed, Time’s Up, Just One, Codenames, Loup-Garou, Perudo, Bang!"

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
                    print("⚠️ [GamePack] Preset '\(preset.rawValue)' présent dans plusieurs packs: '\(existingPack.rawValue)' + '\(pack.rawValue)'. (Le mapping sera écrasé)")
                }
                #endif

                map[preset] = pack
            }
        }

        return map
    }()

    /// Retourne le pack qui contient un preset (sinon coreFree).
    /// - Utilisé pour afficher le bon paywall lorsqu'un jeu est locké.
    static func packContaining(_ presetID: PresetID) -> GamePack {
        return presetToPackMap[presetID] ?? .coreFree
    }

    /// Packs payants (utile pour la boutique).
    static var paidPacks: [GamePack] {
        // Plus de packs payants
        return []
    }
}

