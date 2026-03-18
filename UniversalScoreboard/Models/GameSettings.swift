/*
 * GameSettings.swift
 * PointBoard
 *
 * Created by sy2l on 06/01/2026.
 * Updated by sy2l on 06/01/2026 — V4.5 (ajout nouveaux PresetID + commentaires maintenance)
 * -----------------------------------------------------------------------------
 * GameSettings — Modèle de configuration "moteur" (maths / conditions)
 * -----------------------------------------------------------------------------
 * ► Rôle
 *   - Définir la structure des données utilisées par le GameEngine.
 *   - Ne contenir AUCUN texte métier (pas de règles longues, pas de descriptions).
 *   - Permettre un stockage stable via PresetID (identifiant immuable).
 *
 * ► Contenu
 *   - PresetID : identifiants stables (utilisés par Packs, Persistance, Analytics)
 *   - Target / EndCondition : structures de règles de fin et de cible
 *   - GameSettings : configuration mathématique complète d'un jeu
 *   - GamePreset : glue UI (id + nom affiché + settings)
 * -----------------------------------------------------------------------------
 */

import Foundation

// MARK: - 1) Identifiants stables (Tech ID)

public enum PresetID: String, CaseIterable, Codable, Identifiable {

    // MARK: - Core Pack (Gratuit)
    case generic
    case wins

    // MARK: - Pack Cartes Classiques 🃏
    case uno
    case belote
    case tarot
    case rami
    case poker
    case president
    case huitAmericain = "8-americain"
    case bridge

    // MARK: - Pack Cartes & Dés Fun 🎲
    case skyjo
    case sixQuiPrend = "6-qui-prend"
    case yams
    case phase10 = "phase-10"
    case dutch
    case skipBo = "skip-bo"
    case quatreVingtEtUn = "421"
    case yaniv

    // MARK: - Pack Société & Famille ♟️
    case scrabble
    case monopoly
    case domino
    case triominos
    case milleBornes = "mille-bornes"
    case qwirkle
    case rummikub
    case trivial = "trivial-pursuit"

    // MARK: - Pack Extérieur & Sport ☀️
    case molkky
    case petanque
    case darts
    case pingPong = "ping-pong"
    case palet
    case cornhole
    case volley
    case badminton

    // MARK: - Packs additionnels (V4.5)
    // Party Night 🎉
    case dobble
    case jungleSpeed = "jungle-speed"
    case timesUp = "times-up"
    case justOne = "just-one"
    case codenames
    case loupGarou = "loup-garou"
    case perudo
    case bang

    // Duels & Stratégie 🧠
    case chess
    case checkers
    case backgammon
    case go
    case hive
    case patchwork
    case azul
    case sevenWondersDuel = "7-wonders-duel"

    // Kids & Famille 👨‍👩‍👧‍👦 2
    case unoJunior = "uno-junior"
    case memory
    case bataille
    case mistigri
    case dobbleKids = "dobble-kids"
    case halliGalli = "halli-galli"
    case puissance4 = "puissance-4"
    case bonnePaye = "bonne-paye"

    public var id: String { rawValue }
}

// MARK: - 2) Structures "Core" (moteur)

// MARK: - Target

struct Target: Codable, Equatable {
    let value: Int
    let comparator: TargetComparator
    let consequence: TargetConsequence

    /// Defaults pour faciliter la création manuelle (tests / previews).
    init(
        value: Int = 0,
        comparator: TargetComparator = .greaterThanOrEqual,
        consequence: TargetConsequence = .none
    ) {
        self.value = value
        self.comparator = comparator
        self.consequence = consequence
    }
}

// MARK: - EndCondition

struct EndCondition: Codable, Equatable {
    let type: EndConditionType
    let value: Int

    /// Defaults pour faciliter la création manuelle (tests / previews).
    init(type: EndConditionType = .manual, value: Int = 0) {
        self.type = type
        self.value = value
    }
}

// MARK: - GameSettings (config complète moteur)

struct GameSettings: Codable, Equatable {
    let mode: GameMode
    let initialValue: Int
    let target: Target
    let endCondition: EndCondition
    let lowestScoreIsBest: Bool

    /// Preset neutre "Personnalisé" (feuille blanche).
    static let defaultSettings = GameSettings(
        mode: .points,
        initialValue: 0,
        target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
        endCondition: EndCondition(type: .manual, value: 0),
        lowestScoreIsBest: false
    )
}

// MARK: - 3) Container metadata (glue UI)

struct GamePreset: Identifiable, Equatable {
    let id: PresetID
    let displayName: String
    let settings: GameSettings

    static func == (lhs: GamePreset, rhs: GamePreset) -> Bool {
        lhs.id == rhs.id
    }
}
