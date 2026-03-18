/*
 SettingsView.swift
 PointBoard

 Vue des réglages et gestion des profils.

 Fonctionnalités :
 - Liste des profils joueurs
 - Navigation vers les statistiques détaillées
 - Suppression de profils
 - Gestion du statut Pro

 Technique :
 - ObservedObject ProfileManager
 - NavigationLink vers PlayerStatsView
 - Swipe to delete
 - Design modernisé avec cards (29/01/2026)
 */

import SwiftUI

struct SettingsView: View {
    @ObservedObject var profileManager = ProfileManager.shared
    @ObservedObject var storeManager = StoreManager.shared
    @State private var showCreateProfile = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Section Profils
                    profilesSection

                    // Section Pro
                    proSection

                    // Section À propos
                    aboutSection
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Réglages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreateProfile = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateProfile) {
                CreateProfileSheet()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Profiles Section

    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Profils Joueurs")
                .font(.cardTitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.lg)

            if profileManager.profiles.isEmpty {
                // Empty state
                VStack(spacing: Spacing.md) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.textSecondary)

                    Text("Aucun profil créé")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    Button(action: { showCreateProfile = true }) {
                        Text("Créer un profil")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.appPrimary)
                            .cornerRadius(CornerRadius.md)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
                .padding(.horizontal, Spacing.lg)
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.md)
                .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
                .padding(.horizontal, Spacing.lg)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(profileManager.profiles) { profile in
                        let isRecentlyActive = profile.lastPlayedAt.map { Date().timeIntervalSince($0) < 24*3600 } ?? false

                        NavigationLink(destination: PlayerStatsView(profile: profile)) {
                            ProfileSettingsCard(
                                profile: profile,
                                isRecentlyActive: isRecentlyActive
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                profileManager.deleteProfile(profile)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }

    // MARK: - Pro Section

    private var proSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Version Pro")
                .font(.cardTitle)
                .foregroundColor(Color.textPrimary)// //Color.accentGreen
                .padding(.horizontal, Spacing.lg)

            ProStatusCard(
                isPro: storeManager.isProUser,
                onUpgrade: { showPaywall = true }
            )
            .padding(.horizontal, Spacing.lg)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("À propos")
                .font(.cardTitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.lg)

            AboutCard()
                .padding(.horizontal, Spacing.lg)
        }
    }
}

// MARK: - Create Profile Sheet
struct CreateProfileSheet: View {
    @ObservedObject var profileManager = ProfileManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var selectedAvatar = "person.circle.fill"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Nom du joueur
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Nom du joueur")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        TextField("Nom du joueur", text: $name)
                            .font(.bodyText)
                            .padding(Spacing.md)
                            .background(Color.cardBackground)
                            .cornerRadius(CornerRadius.sm)
                    }

                    // Sélection d'avatar
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Choisir un avatar")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                ForEach(PlayerProfile.defaultAvatars, id: \.self) { avatar in
                                    Button(action: {
                                        selectedAvatar = avatar
                                    }) {
                                        Image(systemName: avatar)
                                            .font(.title2)
                                            .foregroundColor(selectedAvatar == avatar ? .appPrimary : .textSecondary)
                                            .frame(width: 50, height: 50)
                                            .background(selectedAvatar == avatar ? Color.appPrimary.opacity(0.15) : Color.cardBackground)
                                            .cornerRadius(CornerRadius.sm)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                    .stroke(selectedAvatar == avatar ? Color.appPrimary : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Nouveau profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        _ = profileManager.createProfile(name: name, avatar: selectedAvatar)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Avec profils") {
    // Simuler ProfileManager avec des profils
    let manager = ProfileManager.shared
    manager.profiles = PlayerProfile.mockProfiles

    return SettingsView()
}

#Preview("Sans profils") {
    let manager = ProfileManager.shared
    manager.profiles = []

    return SettingsView()
}

#Preview("Create Profile Sheet") {
    CreateProfileSheet()
}
