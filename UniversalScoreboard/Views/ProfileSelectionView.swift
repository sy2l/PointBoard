/*
 ProfileSelectionView.swift
 PointBoard

 Vue de sélection ou création de profil joueur.

 Fonctionnalités :
 - Sélection d'un profil existant
 - Création d'un nouveau profil
 - Choix de l'avatar
 - ✅ Met à jour le "profil courant" global (ProfileManager.currentProfileID)

 Technique :
 - Sheet modal
 - Intégration ProfileManager
 - Binding pour retourner le profil sélectionné (utile pour d’autres flux)
 - Design modernisé avec cards
 - DisabledProfileIDs : empêche de choisir un profil déjà assigné (ex: joueurs d’une partie)

 Created by sy2l
 Updated on 03/02/2026 — Selected highlight + global current profile
 */

import SwiftUI

// MARK: - ProfileSelectionView
struct ProfileSelectionView: View {

    // MARK: - Dependencies
    @ObservedObject var profileManager = ProfileManager.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs
    @Binding var selectedProfile: PlayerProfile?
    var disabledProfileIDs: Set<UUID> = []

    // MARK: - State
    @State private var showCreateProfile = false
    @State private var newPlayerName = ""
    @State private var selectedAvatar = "person.circle.fill"

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // MARK: - Profils existants
                    if !profileManager.profiles.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Profils existants")
                                .font(.cardTitle)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, Spacing.lg)

                            VStack(spacing: Spacing.sm) {
                                ForEach(profileManager.profiles) { profile in
                                    ProfileCard(
                                        profile: profile,
                                        isDisabled: disabledProfileIDs.contains(profile.id),
                                        isSelected: profileManager.currentProfileID == profile.id,
                                        onTap: {
                                            guard !disabledProfileIDs.contains(profile.id) else { return }

                                            // ✅ 1) Binding (utile au parent)
                                            selectedProfile = profile

                                            // ✅ 2) Profil courant global
                                            profileManager.selectProfile(profile)

                                            // ✅ 3) Close
                                            dismiss()
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                    }

                    // MARK: - Nouveau profil
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Nouveau profil")
                            .font(.cardTitle)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.lg)

                        if showCreateProfile {
                            CreateProfileCard(
                                newPlayerName: $newPlayerName,
                                selectedAvatar: $selectedAvatar,
                                onCreate: createProfile
                            )
                            .padding(.horizontal, Spacing.lg)
                        } else {
                            Button(action: { showCreateProfile = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("Créer un nouveau profil")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.accentGreen)
                                .background(Color.accentGreen.opacity(0.1))
                                .cornerRadius(CornerRadius.md)
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Sélectionner un profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    // MARK: - Actions
    private func createProfile() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let profile = profileManager.createProfile(name: trimmed, avatar: selectedAvatar)

        // ✅ 1) Binding
        selectedProfile = profile

        // ✅ 2) Profil courant global (déjà fait dans createProfile, mais safe)
        profileManager.selectProfile(profile)

        // ✅ 3) Close
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    ProfileSelectionView(selectedProfile: .constant(nil))
}
