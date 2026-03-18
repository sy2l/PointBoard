//
// GamePreset+Theme.swift
// PointBoard
//
// Relais des propriétés de thème définies sur PresetID
//
// Created on 21/01/2026.
//

import SwiftUI

// MARK: - GamePreset Theme Relay
extension GamePreset {

    var themeColor: Color { id.themeColor }
    var iconName: String { id.iconName }

    var backgroundWithOpacity: Color { id.backgroundWithOpacity }
    var accentWithOpacity: Color { id.accentWithOpacity }
}
