/*
 ProfileCards.swift
 PointBoard

 Composants cards pour la sélection et création de profils.

 Composants :
 - ProfileCard : Card extensible avec Select/Stats/Delete
 - CreateProfileCard : Card pour créer un nouveau profil

 Notes UX :
 - ✅ Le profil sélectionné est visuellement mis en avant (bordure + check)
 - ✅ "Sélectionner" applique aussi le profil courant global via ProfileManager

 Updated on 02/02/2026 - Card extensible avec actions
 Updated on 02/02/2026 - Fix deleteProfile call signature (expects PlayerProfile, not UUID)
 Updated on 03/02/2026 - Selected state highlight + global selection
 */

import SwiftUI

// MARK: - ProfileCard
struct ProfileCard: View {

    // MARK: - Inputs
    let profile: PlayerProfile
    let isDisabled: Bool
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: - Local UI State
    @State private var isExpanded: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showStats: Bool = false

    // MARK: - Dependencies
    @ObservedObject private var profileManager = ProfileManager.shared

    // MARK: - UI
    private let corner: CGFloat = CornerRadius.md

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Carte principale (toujours visible)
            Button(action: {
                guard !isDisabled else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: profile.avatar)
                        .font(.title2)
                        .foregroundColor(isDisabled ? .textSecondary.opacity(0.5) : (isSelected ? .accentGreen : .appPrimary))
                        .frame(width: 50, height: 50)
                        .background(
                            (isDisabled ? Color.textSecondary.opacity(0.1) :
                                (isSelected ? Color.accentGreen.opacity(0.12) : Color.appPrimary.opacity(0.1))
                            )
                        )
                        .cornerRadius(CornerRadius.md)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.headline)
                            .foregroundColor(isDisabled ? .textSecondary.opacity(0.5) : .textPrimary)

                        Text("\(profile.stats.gamesPlayed) parties • \(profile.stats.wins) victoires")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    if isDisabled {
                        Text("Déjà utilisé")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.warning)
                            .cornerRadius(8)
                    } else if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentGreen)
                    } else {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                    }
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .overlay(selectedOverlay)
            }
            .disabled(isDisabled)
            .buttonStyle(.plain)

            // MARK: - Zone extensible avec boutons
            if isExpanded && !isDisabled {
                VStack(spacing: Spacing.sm) {
                    Divider()
                        .padding(.horizontal, Spacing.md)

                    HStack(spacing: Spacing.md) {

                        // MARK: - Sélectionner
                        Button(action: {
                            // ✅ Met le profil en profil courant global
                            profileManager.selectProfile(profile)

                            // ✅ Remonte l’info au parent (sheet)
                            onTap()

                            // Optionnel : refermer l'expansion
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                isExpanded = false
                            }
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                Text(isSelected ? "Sélectionné" : "Sélectionner")
                                    .font(.cardSubtitle)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(isSelected ? Color.accentGreen.opacity(0.8) : Color.accentGreen)
                            .cornerRadius(CornerRadius.sm)
                        }
                        .buttonStyle(.plain)

                        // MARK: - Stats
                        Button(action: {
                            showStats = true
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.caption)
                                Text("Stats")
                                    .font(.cardSubtitle)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.appPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.appPrimary.opacity(0.1))
                            .cornerRadius(CornerRadius.sm)
                        }
                        .buttonStyle(.plain)

                        // MARK: - Supprimer
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.caption)
                                .foregroundColor(.error)
                                .frame(width: 44, height: 44)
                                .background(Color.error.opacity(0.1))
                                .cornerRadius(CornerRadius.sm)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                }
                .background(Color.cardBackground)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .shadow(color: Color.cardShadow, radius: isExpanded ? 8 : 4, x: 0, y: isExpanded ? 4 : 2)
        .opacity(isDisabled ? 0.5 : 1.0)

        // MARK: - Delete confirmation
        .alert("Supprimer le profil", isPresented: $showDeleteConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                profileManager.deleteProfile(profile)
                isExpanded = false
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer le profil \"\(profile.name)\" ? Cette action est irréversible.")
        }

        // MARK: - Stats Sheet
        .sheet(isPresented: $showStats) {
            PlayerStatsView(profile: profile)
        }
    }

    private var selectedOverlay: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .stroke(
                isSelected ? Color.accentGreen : Color.clear,
                lineWidth: isSelected ? 2 : 0
            )
    }
}

// MARK: - CreateProfileCard
struct CreateProfileCard: View {
    @Binding var newPlayerName: String
    @Binding var selectedAvatar: String
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {

            // MARK: - Nom du joueur
            TextField("Nom du joueur", text: $newPlayerName)
                .font(.bodyText)
                .padding(Spacing.md)
                .background(Color.appBackground)
                .cornerRadius(CornerRadius.sm)

            // MARK: - Sélection d'avatar
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Choisir un avatar")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(PlayerProfile.defaultAvatars, id: \.self) { avatar in
                            Button(action: { selectedAvatar = avatar }) {
                                Image(systemName: avatar)
                                    .font(.title2)
                                    .foregroundColor(selectedAvatar == avatar ? .appPrimary : .textSecondary)
                                    .frame(width: 50, height: 50)
                                    .background(selectedAvatar == avatar ? Color.appPrimary.opacity(0.15) : Color.appBackground)
                                    .cornerRadius(CornerRadius.sm)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                                            .stroke(selectedAvatar == avatar ? Color.appPrimary : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // MARK: - Bouton de création
            Button(action: onCreate) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Créer le profil")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.textSecondary.opacity(0.3)
                            : Color.accentGreen)
                .cornerRadius(CornerRadius.md)
            }
            .disabled(newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}
