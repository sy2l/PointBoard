/*
 * RulesManager.swift
 * PointBoard
 *
 * Gestionnaire de contenu pour les règles des jeux.
 * - Retourne un bloc de texte pour un PresetID.
 * - DEBUG : log si aucune règle n'existe pour l'ID demandé.
 */

import Foundation

struct GameRules {
    let title: String
    let summary: String
    let details: String
}

final class RulesManager {
    static let shared = RulesManager()
    private init() {}

    func getRules(for id: PresetID) -> GameRules? {
        let rules = rulesData[id]

        #if DEBUG
        if rules == nil {
            let keys = rulesData.keys.map(\.rawValue).sorted()
            print("⚠️ [RulesManager] No rules for preset:", id.rawValue)
            print("📌 Available rule keys:", keys)
        }
        #endif

        return rules
    }

    private let rulesData: [PresetID: GameRules] = [

        // MARK: - Skyjo
        .skyjo: GameRules(
            title: "Règles du Skyjo",
            summary: "L'objectif est simple : avoir le score le plus bas possible à la fin de la partie.",
            details: """
            👉 **Le concept**
            Chaque joueur a 12 cartes face cachée. À chaque tour, piochez une carte (de la pile ou de la défausse) pour remplacer l'une des vôtres.

            🔢 **Comptage des points**
            • Les cartes positives s'additionnent (le but est d'éviter les gros chiffres rouges !).
            • Les cartes bleues sont négatives (c'est bon pour vous).

            🔥 **Le Twist : La colonne**
            Si vous alignez 3 cartes identiques verticalement, toute la colonne part à la poubelle : **0 point** ! C'est la meilleure stratégie.

            🏁 **Fin de manche**
            Dès qu'un joueur retourne toutes ses cartes, le tour finit.
            ⚠️ Attention : Si celui qui finit n'a pas le plus petit score de la table, ses points doublent !
            """
        ),

        // MARK: - Uno
        .uno: GameRules(
            title: "Règles du Uno (+ Variantes)",
            summary: "Débarrassez-vous de vos cartes avant les autres. Le premier à 500 points gagne.",
            details: """
            👉 **Les Bases**
            On pose une carte de la même couleur ou du même chiffre. Si on ne peut pas, on pioche.
            N'oubliez pas de crier "UNO" quand il ne vous reste qu'une carte (sinon +2 cartes de pénalité !).

            🔢 **Valeur des cartes (pour le perdant)**
            • Cartes 0 à 9 : Valeur faciale
            • +2, Inverse, Passe : 20 points
            • Joker et +4 : 50 points

            🌶 **Variantes Populaires (House Rules)**
            • **La Suite (Cumul)** : On peut répondre à un +2 par un autre +2.
            • **Le 7 magique** : Si vous posez un 7, échange de main.
            • **Le 0 tournant** : Un 0 -> tout le monde passe son paquet au voisin.
            • **Interception** : Si vous avez exactement la même carte, vous pouvez couper.
            """
        ),

        // MARK: - 6 qui prend
        .sixQuiPrend: GameRules(
            title: "Règles du 6 qui prend",
            summary: "Un jeu de vaches où il ne faut surtout pas être le 6ème !",
            details: """
            👉 **Le concept**
            4 lignes de cartes sont posées sur la table. Tout le monde choisit une carte secrètement et on les révèle en même temps.

            🐮 **La règle d'or**
            On place sa carte sur la ligne dont la dernière valeur est la plus proche (mais inférieure).
            Si votre carte est la **6ème** de la ligne... vous ramassez les 5 précédentes.

            🔢 **Score**
            Chaque tête de boeuf = 1 point de pénalité. Fin quand un joueur atteint 66.
            """
        ),

        // MARK: - Tarot
        .tarot: GameRules(
            title: "Règles du Tarot",
            summary: "Un jeu de plis, d'atouts et de contrats. Se joue à 3, 4 ou 5.",
            details: """
            👉 **Le but**
            Le Preneur joue contre la Défense et doit réaliser un total selon ses Bouts.

            👑 **Les Bouts**
            Petit, 21, Excuse.
            • 0 Bout = 56 points
            • 1 Bout = 51 points
            • 2 Bouts = 41 points
            • 3 Bouts = 36 points
            """
        ),

        // MARK: - Belote
        .belote: GameRules(
            title: "Règles de la Belote",
            summary: "Le classique français. 162 points à partager par manche.",
            details: """
            👉 **À l'Atout**
            Valet (20) > 9 (14) > As (11) > 10 (10) > Roi (4) > Dame (3)

            👉 **Sans Atout**
            As (11) > 10 (10) > Roi (4) > Dame (3) > Valet (2)

            🎁 **Bonus**
            Belote-Rebelote : +20. Dix de Der : +10.
            """
        ),

        // MARK: - Rami
        .rami: GameRules(
            title: "Règles du Rami",
            summary: "Créez des combinaisons pour vider votre main.",
            details: """
            👉 **Combinaisons**
            • Brelan / Carré
            • Suite (même couleur)

            🔢 **Première pose**
            Souvent 51 points (selon variantes).

            ☠️ **Fin**
            Les perdants comptent les points restants en main.
            """
        ),

        // MARK: - Yams
        .yams: GameRules(
            title: "Règles du Yams (Yahtzee)",
            summary: "5 dés, 3 lancers, une grille à remplir.",
            details: """
            👉 **3 lancers**
            Gardez certains dés, relancez les autres.

            🎁 **Bonus**
            Si total 1..6 >= 63 : +35.
            """
        ),

        // MARK: - Mölkky
        .molkky: GameRules(
            title: "Règles du Mölkky",
            summary: "Arriver à exactement 50 points.",
            details: """
            • 1 quille : valeur écrite
            • Plusieurs : nombre de quilles

            ⚠️ Si > 50 : retour à 25.
            ⚠️ 3 lancers nuls : élimination.
            """
        ),

        // MARK: - Poker (Score)
        .poker: GameRules(
            title: "Règles du Poker (Score)",
            summary: "Ici on suit les stacks de jetons.",
            details: """
            Entrez les gains/pertes de jetons.
            0 jeton = élimination. Dernier survivant gagne.
            """
        ),

        // MARK: - Scrabble
        .scrabble: GameRules(
            title: "Règles du Scrabble",
            summary: "Le mot compte triple, on connaît la chanson.",
            details: """
            Additionnez la valeur des lettres + multiplicateurs.
            Scrabble (7 lettres) : +50.
            """
        )
    ]
}
