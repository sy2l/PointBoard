/*
 ProfileManager.swift
 PointBoard

 Gestionnaire des profils joueurs.

 Fonctionnalités :
 - CRUD complet (Create, Read, Update, Delete)
 - Sauvegarde dans fichier JSON
 - Mise à jour des statistiques
 - Recherche et tri des profils
 - ✅ Gestion d’un "profil courant" sélectionné (persisté)

 Technique :
 - Singleton pattern
 - Stockage dans Documents/profiles.json
 - JSONEncoder/Decoder
 - ObservableObject pour la réactivité SwiftUI
 - @MainActor pour garantir UI safety

 Updated on 03/02/2026 — Ajout currentProfile (selection globale + persistance)
 */

import Foundation
import Combine

@MainActor
final class ProfileManager: ObservableObject {

    static let shared = ProfileManager()

    // MARK: - Public data
    @Published var profiles: [PlayerProfile] = [] {
        didSet {
            ensureValidCurrentProfile()
        }
    }

    /// ✅ ID du profil courant (source de vérité globale)
    @Published private(set) var currentProfileID: UUID? {
        didSet {
            persistCurrentProfileID()
        }
    }

    /// ✅ Profil courant (computed)
    var currentProfile: PlayerProfile? {
        guard let id = currentProfileID else { return nil }
        return profiles.first(where: { $0.id == id })
    }

    // MARK: - Private
    private let fileManager = FileManager.default
    private let profilesFile: URL

    private let currentProfileKey = "pb_current_profile_id"

    private init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        profilesFile = documentsPath.appendingPathComponent("profiles.json")
        loadProfiles()
        restoreCurrentProfileID()
        ensureValidCurrentProfile()
    }

    // MARK: - Current profile selection

    /// Sélectionne un profil comme profil courant global.
    func selectProfile(_ profile: PlayerProfile) {
        currentProfileID = profile.id
    }

    /// Permet de clear le profil courant (rarement utile, mais safe).
    func clearCurrentProfile() {
        currentProfileID = nil
    }

    private func restoreCurrentProfileID() {
        guard
            let str = UserDefaults.standard.string(forKey: currentProfileKey),
            let id = UUID(uuidString: str)
        else { return }
        currentProfileID = id
    }

    private func persistCurrentProfileID() {
        if let id = currentProfileID {
            UserDefaults.standard.set(id.uuidString, forKey: currentProfileKey)
        } else {
            UserDefaults.standard.removeObject(forKey: currentProfileKey)
        }
    }

    /// Assure que currentProfileID pointe vers un profil existant.
    private func ensureValidCurrentProfile() {
        // Si déjà valide -> OK
        if let id = currentProfileID, profiles.contains(where: { $0.id == id }) {
            return
        }

        // Sinon fallback : premier profil (si existe) sinon nil
        currentProfileID = profiles.first?.id
    }

    // MARK: - Create

    /// Vérifie si l'utilisateur peut ajouter un profil
    func canAddProfile() -> Bool {
        if StoreManager.shared.isProUser || ProTrialManager.shared.isTrialActive {
            return true
        }
        return profiles.count < 3
    }

    /// Crée un nouveau profil
    func createProfile(name: String, avatar: String = "person.circle.fill") -> PlayerProfile {
        let profile = PlayerProfile(name: name, avatar: avatar)
        profiles.append(profile)
        saveProfiles()

        // ✅ Par défaut, un profil créé devient le profil courant
        selectProfile(profile)

        return profile
    }

    /// Crée un nouveau profil après avoir vu une pub
    func createProfileAfterAd(
        name: String,
        avatar: String = "person.circle.fill",
        completion: @escaping (PlayerProfile?) -> Void
    ) {
        AdManager.shared.showRewardedAd { [weak self] success in
            guard let self else {
                completion(nil)
                return
            }

            // ⚠️ callback pub peut arriver hors MainActor -> on repasse explicitement sur MainActor
            Task { @MainActor in
                if success {
                    let profile = self.createProfile(name: name, avatar: avatar)
                    completion(profile)
                } else {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Read

    func loadProfiles() {
        guard fileManager.fileExists(atPath: profilesFile.path) else {
            print("📂 Aucun fichier de profils trouvé, création d'une liste vide")
            profiles = []
            return
        }

        do {
            let data = try Data(contentsOf: profilesFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            profiles = try decoder.decode([PlayerProfile].self, from: data)
            print("✅ \(profiles.count) profil(s) chargé(s)")
        } catch {
            print("❌ Erreur lors du chargement des profils : \(error)")
            profiles = []
        }
    }

    func getProfile(by id: UUID) -> PlayerProfile? {
        profiles.first { $0.id == id }
    }

    func getProfile(by name: String) -> PlayerProfile? {
        profiles.first { $0.name.lowercased() == name.lowercased() }
    }

    func getMostActivePlayers(limit: Int = 10) -> [PlayerProfile] {
        profiles
            .sorted { $0.stats.gamesPlayed > $1.stats.gamesPlayed }
            .prefix(limit)
            .map { $0 }
    }

    func getTopWinners(limit: Int = 10) -> [PlayerProfile] {
        profiles
            .filter { $0.stats.gamesPlayed >= 3 }
            .sorted { $0.winRate > $1.winRate }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Update

    func updateProfile(_ profile: PlayerProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles()
            print("✅ Profil mis à jour : \(profile.name)")
        }
    }

    func updateStats(for profileId: UUID, won: Bool, eliminated: Bool, finalScore: Int) {
        guard var profile = getProfile(by: profileId) else {
            print("❌ Profil introuvable : \(profileId)")
            return
        }

        profile.stats.recordGame(won: won, eliminated: eliminated, finalScore: finalScore)
        profile.lastPlayedAt = Date()
        updateProfile(profile)

        print("📊 Stats mises à jour pour \(profile.name) : \(profile.stats.gamesPlayed) parties, \(profile.stats.wins) victoires")
    }

    /// Enregistre une partie complète (gamesPlayed +1 pour tous, wins +1 pour gagnants)
    func recordGame(participantProfileIDs: [UUID], winnerProfileIDs: [UUID]) {
        let winnerSet = Set(winnerProfileIDs)

        for profileId in participantProfileIDs {
            guard var profile = getProfile(by: profileId) else {
                print("⚠️ Profil introuvable pour ID : \(profileId)")
                continue
            }

            let isWinner = winnerSet.contains(profileId)
            profile.stats.gamesPlayed += 1
            if isWinner { profile.stats.wins += 1 }
            profile.lastPlayedAt = Date()

            if let index = profiles.firstIndex(where: { $0.id == profileId }) {
                profiles[index] = profile
            }

            print("📊 Stats enregistrées pour \(profile.name) : \(profile.stats.gamesPlayed) parties, \(profile.stats.wins) victoires")
        }

        saveProfiles()
    }

    // MARK: - Delete

    func deleteProfile(_ profile: PlayerProfile) {
        let deletedID = profile.id
        profiles.removeAll { $0.id == deletedID }
        saveProfiles()
        print("🗑️ Profil supprimé : \(profile.name)")

        // ✅ si on supprime le profil courant, on retombe sur un autre
        if currentProfileID == deletedID {
            currentProfileID = profiles.first?.id
        }
    }

    func deleteAllProfiles() {
        profiles.removeAll()
        saveProfiles()
        currentProfileID = nil
        print("🗑️ Tous les profils supprimés")
    }

    // MARK: - Save

    private func saveProfiles() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profiles)
            try data.write(to: profilesFile)
            print("💾 Profils sauvegardés : \(profiles.count)")
        } catch {
            print("❌ Erreur lors de la sauvegarde des profils : \(error)")
        }
    }
}
