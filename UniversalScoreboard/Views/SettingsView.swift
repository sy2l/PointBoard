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
    @State private var showPackUnlock = false
    @State private var selectedPack: GamePack?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Section Profils
                    profilesSection

                    // Section Packs & Bundle
                    packsSection

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
                BundlePaywallView()
            }
            .sheet(item: $selectedPack) { pack in
                PackUnlockSheet(pack: pack)
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

    // MARK: - Packs & Bundle Section

    private var packsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Packs & Bundle")
                .font(.cardTitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.lg)

            // Bundle Card (si pas acheté)
            if !storeManager.hasAllPacksBundle {
                BundleCard(onTap: { showPaywall = true })
                    .padding(.horizontal, Spacing.lg)
            }

            // Streak Card
            StreakInfoCard()
                .padding(.horizontal, Spacing.lg)

            // Liste des packs
            PacksListView(onTapPack: { pack in
                selectedPack = pack
                showPackUnlock = true
            })
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

// MARK: - Bundle Card

struct BundleCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text("🎁")
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Bundle All Packs")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("Tous les packs pour 2,99€")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textSecondary)
            }
            .padding(Spacing.lg)
            .background(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(CornerRadius.md)
            .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak Info Card

struct StreakInfoCard: View {
    @ObservedObject private var streakManager = DailyStreakManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Streak de \(streakManager.currentStreak) jours")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if streakManager.jokerAvailable {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Joker disponible")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    } else {
                        Text("\(streakManager.daysUntilNextJoker()) jours avant le prochain joker")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // Indicateur visuel flammes
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < streakManager.currentStreak ? "flame.fill" : "flame")
                            .foregroundColor(index < streakManager.currentStreak ? .orange : .gray.opacity(0.3))
                            .font(.caption)
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Packs List View

struct PacksListView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    @ObservedObject private var progressManager = UnlockProgressManager.shared
    
    let onTapPack: (GamePack) -> Void
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(GamePack.allCases.filter { $0 != .coreFree }, id: \.self) { pack in
                PackRowView(
                    pack: pack,
                    isUnlocked: storeManager.isPackUnlocked(pack),
                    adsProgress: progressManager.adProgressText(for: pack),
                    onTap: { onTapPack(pack) }
                )
            }
        }
    }
}

// MARK: - Pack Row View

struct PackRowView: View {
    let pack: GamePack
    let isUnlocked: Bool
    let adsProgress: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Text(packEmoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(pack.displayName)
                        .font(.bodyText.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    if isUnlocked {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentGreen)
                            Text("Débloqué")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    } else {
                        Text(adsProgress)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
        }
        .buttonStyle(.plain)
    }
    
    private var packEmoji: String {
        switch pack {
        case .coreFree: return "⭐️"
        case .classicCards: return "🃏"
        case .funCardsDice: return "🎲"
        case .boardFamily: return "♟️"
        case .outdoorSport: return "☀️"
        case .partyNight: return "🎉"
        case .duelsStrategy: return "🧠"
        case .kidsFamily2: return "👨‍👩‍👧‍👦"
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
