/*
 * PresetManager.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by sy2l on 06/01/2026 — V4.0.3 (packs + nouveaux presets + helpers)
 * -----------------------------------------------------------------------------
 * PresetManager — Base de données des presets (configurations de jeux)
 * -----------------------------------------------------------------------------
 * ► Rôle
 *   - Source de vérité des presets disponibles dans l'app.
 *   - Fournir des configurations mathématiques (GameSettings) stables par jeu.
 *   - Lookup sécurisé par PresetID (fallback sur .generic).
 *
 * ► Notes de maintenance
 *   - Ce fichier ne gère PAS la monétisation (packs / StoreKit).
 *     Le lien Pack -> PresetID est dans GamePack.includedPresets.
 *   - Ici : uniquement la config du moteur de score (pas de règles texte).
 *
 * ► Helpers
 *   - preset(for:) : lookup safe + fallback.
 *   - presets(for:) : IDs -> Presets (filtré).
 *   - exists(_:) : vérifie qu'un preset est défini.
 * -----------------------------------------------------------------------------
 */

import Foundation

struct PresetManager {

    // MARK: - Source de vérité

    static let availablePresets: [GamePreset] = [

        // MARK: - Core (Gratuit)

        GamePreset(id: .generic, displayName: "Jeu Personnalisé", settings: GameSettings.defaultSettings),

        GamePreset(
            id: .wins,
            displayName: "Compteur de Victoires",
            settings: GameSettings(
                mode: .wins,
                initialValue: 0,
                target: Target(value: 3, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        // MARK: - Pack Cartes & Dés Fun 🎲

        GamePreset(
            id: .skyjo,
            displayName: "Skyjo",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: true
            )
        ),

        GamePreset(
            id: .sixQuiPrend,
            displayName: "6 qui prend",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 66, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: true
            )
        ),

        GamePreset(
            id: .yams,
            displayName: "Yams",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 300, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .phase10,
            displayName: "Phase 10",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 500, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: true
            )
        ),

        GamePreset(
            id: .dutch,
            displayName: "Dutch (Ligretto)",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .skipBo,
            displayName: "Skip-Bo",
            settings: GameSettings(
                mode: .wins,
                initialValue: 0,
                target: Target(value: 3, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .quatreVingtEtUn,
            displayName: "421",
            settings: GameSettings(
                mode: .points,
                initialValue: 21,
                target: Target(value: 0, comparator: .lessThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .yaniv,
            displayName: "Yaniv",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 200, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: true
            )
        ),

        // MARK: - Pack Cartes Classiques 🃏

        GamePreset(
            id: .uno,
            displayName: "Uno",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 500, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .belote,
            displayName: "Belote",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 1000, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .tarot,
            displayName: "Tarot",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 1000, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .rami,
            displayName: "Rami",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 500, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: true
            )
        ),

        GamePreset(
            id: .poker,
            displayName: "Poker (Jetons)",
            settings: GameSettings(
                mode: .points,
                initialValue: 1000,
                target: Target(value: 0, comparator: .lessThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .president,
            displayName: "Président",
            settings: GameSettings(
                mode: .wins,
                initialValue: 0,
                target: Target(value: 5, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .huitAmericain,
            displayName: "Le 8 Américain",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 500, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .bridge,
            displayName: "Bridge",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        // MARK: - Pack Société & Famille ♟️

        GamePreset(
            id: .scrabble,
            displayName: "Scrabble",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 0, comparator: .greaterThanOrEqual, consequence: .none),
                endCondition: EndCondition(type: .manual, value: 0),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .monopoly,
            displayName: "Monopoly",
            settings: GameSettings(
                mode: .points,
                initialValue: 1500,
                target: Target(value: 0, comparator: .lessThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .domino,
            displayName: "Domino",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
                endCondition: EndCondition(type: .remainingPlayers, value: 1),
                lowestScoreIsBest: true
            )
        ),

        GamePreset(
            id: .triominos,
            displayName: "Triominos",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 400, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .milleBornes,
            displayName: "Mille Bornes",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 1000, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .qwirkle,
            displayName: "Qwirkle",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 0, comparator: .greaterThanOrEqual, consequence: .none),
                endCondition: EndCondition(type: .manual, value: 0),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .rummikub,
            displayName: "Rummikub",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 0, comparator: .greaterThanOrEqual, consequence: .none),
                endCondition: EndCondition(type: .manual, value: 0),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .trivial,
            displayName: "Trivial Pursuit",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 6, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        // MARK: - Pack Extérieur & Sport ☀️

        GamePreset(
            id: .molkky,
            displayName: "Mölkky",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 50, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .petanque,
            displayName: "Pétanque",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 13, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .darts,
            displayName: "Fléchettes (301/501)",
            settings: GameSettings(
                mode: .points,
                initialValue: 301,
                target: Target(value: 0, comparator: .lessThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: true
            )
        ),

        GamePreset(
            id: .pingPong,
            displayName: "Ping-Pong",
            settings: GameSettings(
                mode: .wins,
                initialValue: 0,
                target: Target(value: 3, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .palet,
            displayName: "Palet Breton",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 30, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .cornhole,
            displayName: "Cornhole",
            settings: GameSettings(
                mode: .points,
                initialValue: 0,
                target: Target(value: 21, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .volley,
            displayName: "Volley-Ball",
            settings: GameSettings(
                mode: .wins,
                initialValue: 0,
                target: Target(value: 3, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        GamePreset(
            id: .badminton,
            displayName: "Badminton",
            settings: GameSettings(
                mode: .wins,
                initialValue: 0,
                target: Target(value: 3, comparator: .greaterThanOrEqual, consequence: .winner),
                endCondition: EndCondition(type: .targetReached, value: 1),
                lowestScoreIsBest: false
            )
        ),

        // MARK: - Packs additionnels (Party / Duels / Kids)

        // Party Night 🎉
        GamePreset(id: .dobble, displayName: "Dobble", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 5, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .jungleSpeed, displayName: "Jungle Speed", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .timesUp, displayName: "Time’s Up", settings: .init(mode: .points, initialValue: 0, target: .init(value: 0, comparator: .greaterThanOrEqual, consequence: .none), endCondition: .init(type: .manual, value: 0), lowestScoreIsBest: false)),
        GamePreset(id: .justOne, displayName: "Just One", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 13, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .codenames, displayName: "Codenames", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 5, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .loupGarou, displayName: "Loup-Garou", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .perudo, displayName: "Perudo", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .bang, displayName: "Bang!", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),

        // Duels & Stratégie 🧠
        GamePreset(id: .chess, displayName: "Échecs", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 2, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .checkers, displayName: "Dames", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 2, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .backgammon, displayName: "Backgammon", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .go, displayName: "Go", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 2, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .hive, displayName: "Hive", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 2, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .patchwork, displayName: "Patchwork", settings: .init(mode: .points, initialValue: 0, target: .init(value: 0, comparator: .greaterThanOrEqual, consequence: .none), endCondition: .init(type: .manual, value: 0), lowestScoreIsBest: false)),
        GamePreset(id: .azul, displayName: "Azul", settings: .init(mode: .points, initialValue: 0, target: .init(value: 0, comparator: .greaterThanOrEqual, consequence: .none), endCondition: .init(type: .manual, value: 0), lowestScoreIsBest: false)),
        GamePreset(id: .sevenWondersDuel, displayName: "7 Wonders Duel", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 2, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),

        // Kids & Famille 👨‍👩‍👧‍👦 2
        GamePreset(id: .unoJunior, displayName: "Uno Junior", settings: .init(mode: .points, initialValue: 0, target: .init(value: 200, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .memory, displayName: "Memory", settings: .init(mode: .points, initialValue: 0, target: .init(value: 0, comparator: .greaterThanOrEqual, consequence: .none), endCondition: .init(type: .manual, value: 0), lowestScoreIsBest: false)),
        GamePreset(id: .bataille, displayName: "Bataille", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 5, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .mistigri, displayName: "Mistigri", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .dobbleKids, displayName: "Dobble Kids", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 5, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .halliGalli, displayName: "Halli Galli", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 3, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .puissance4, displayName: "Puissance 4", settings: .init(mode: .wins, initialValue: 0, target: .init(value: 2, comparator: .greaterThanOrEqual, consequence: .winner), endCondition: .init(type: .targetReached, value: 1), lowestScoreIsBest: false)),
        GamePreset(id: .bonnePaye, displayName: "La Bonne Paye", settings: .init(mode: .points, initialValue: 0, target: .init(value: 0, comparator: .greaterThanOrEqual, consequence: .none), endCondition: .init(type: .manual, value: 0), lowestScoreIsBest: false))
    ]

    // MARK: - Helpers

    static func preset(for id: PresetID) -> GamePreset {
        availablePresets.first(where: { $0.id == id }) ?? availablePresets[0]
    }

    static func presets(for ids: [PresetID]) -> [GamePreset] {
        ids.compactMap { wantedID in
            availablePresets.first(where: { $0.id == wantedID })
        }
    }

    /// Utile pour des checks (ex: debug, asserts, migrations).
    static func exists(_ id: PresetID) -> Bool {
        availablePresets.contains(where: { $0.id == id })
    }
}
