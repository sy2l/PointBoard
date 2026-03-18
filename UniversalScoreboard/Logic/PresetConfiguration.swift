//
// PresetConfiguration.swift
// PointBoard
//
// Wrapper de compatibilité: certaines vues attendent PresetConfiguration,
// mais la source canonique est PresetManager.
//
// Created on 21/01/2026.
//

import Foundation

// MARK: - Preset Configuration (Compatibility Layer)
enum PresetConfiguration {

    // MARK: - Public Presets List
    static var presets: [GamePreset] {
        PresetID.allCases.map { PresetManager.preset(for: $0) }
    }

    // MARK: - Default / Generic
    static var genericPreset: GamePreset {
        PresetManager.preset(for: .generic)
    }
}
