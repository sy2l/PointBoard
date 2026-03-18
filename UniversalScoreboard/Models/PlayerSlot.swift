/*
 * PlayerSlot.swift
 * PointBoard
 *
 * Modèle représentant un slot de joueur dans la configuration de partie
 * Peut être soit un invité (saisie libre) soit un profil enregistré
 */

import Foundation

struct PlayerSlot: Identifiable, Equatable {
    let id: UUID
    var name: String
    var profile: PlayerProfile?  // nil = invité, non-nil = profil enregistré
    
    init(id: UUID = UUID(), name: String = "", profile: PlayerProfile? = nil) {
        self.id = id
        self.name = name
        self.profile = profile
    }
    
    // Helper : Est-ce un profil enregistré ?
    var isRegisteredProfile: Bool {
        return profile != nil
    }
    
    // Helper : Nom à afficher
    var displayName: String {
        return profile?.name ?? name
    }
    
    // Helper : ID du profil si enregistré
    var profileId: UUID? {
        return profile?.id
    }
}
