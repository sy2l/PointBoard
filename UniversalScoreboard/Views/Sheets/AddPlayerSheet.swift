/*
 * AddPlayerSheet.swift
 * PointBoard
 *
 * Created by sy2l on 21/01/2026.
 * -----------------------------------------------------------------------------
 * AddPlayerSheet — Ajout d'un joueur (invité ou profil)
 * -----------------------------------------------------------------------------
 * Mise à jour Freemium:
 * - Free : 6 joueurs gratuits
 * - Free : ajouts 7..12 => pub statique à CHAQUE ajout
 * - Free : tentative 13e => popup "Deviens Pro"
 * - Pro / Trial : pas de pub
 * -----------------------------------------------------------------------------
 */

import SwiftUI

// MARK: - AddPlayerSheet
struct AddPlayerSheet: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs
    @Binding var playerSlots: [PlayerSlot]

    let maxPlayers: Int
    let canAddPlayer: Bool
    let availableProfiles: [PlayerProfile]

    /// Ouvre la 2e sheet (ProfileSelectionView) depuis une ligne
    let onTapPickProfile: (UUID) -> Void

    let onClose: () -> Void

    // MARK: - Dependencies
    @ObservedObject private var storeManager = StoreManager.shared
    @ObservedObject private var adManager = AdManager.shared

    // MARK: - Freemium rules
    private let freeIncludedPlayersCount: Int = 6
    private let freeHardCapPlayersCount: Int = 12

    // MARK: - State
    @State private var guestName: String = ""
    @State private var showProUpsellAlert: Bool = false

    // MARK: - Computed

    private var trimmedGuestName: String {
        guestName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isProOrTrial: Bool {
        storeManager.hasAllPacksBundle
    }

    private var canSubmitGuest: Bool {
        !trimmedGuestName.isEmpty
    }

    // MARK: - Banner (top) state

    private var shouldShowFreemiumBanner: Bool {
        !isProOrTrial
    }

    private var shouldShowAdRequiredBanner: Bool {
        // Free only + entre 7 et 12 (donc count > 6, et < 12)
        guard !isProOrTrial else { return false }
        return playerSlots.count > freeIncludedPlayersCount
            && playerSlots.count < freeHardCapPlayersCount
    }

    private var bannerTitle: String {
        if isProOrTrial { return "BUNDLE" }
        return shouldShowAdRequiredBanner ? "PUB" : "FREE"
    }

    private var bannerSubtitle: String {
        if isProOrTrial {
            return "Ajouts illimités"
        }
        if shouldShowAdRequiredBanner {
            return "de 7 à 12 joueurs"
        }
        return "jusqu’à 6 joueurs"
    }

    private var bannerIconSystemName: String {
        if isProOrTrial { return "crown.fill" }
        return shouldShowAdRequiredBanner ? "lock.fill" : "checkmark.seal.fill"
    }

    private var bannerTintColor: Color {
        if isProOrTrial { return .yellow }
        return shouldShowAdRequiredBanner ? .orange : .green
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Header (Top)
                
                // MARK: - Add guest
                
                Section(header: Text("Ajouter un joueur")) {
                    HStack(spacing: 12) {
                        TextField("Nom du joueur", text: $guestName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()

                        Button("Ajouter") {
                            guard canSubmitGuest else { return }
                            attemptAddPlayer {
                                addGuest(trimmedGuestName)
                                guestName = ""
                            }
                        }
                        .disabled(!canSubmitGuest)
                    }
                }

                // MARK: - Players list (editable)
                
                Section("Liste") {
                    VStack(alignment: .leading, spacing: 10) {
                        // MARK: - Freemium banner (requested: top, after "Joueurs")
                        
                        if shouldShowFreemiumBanner {
                            freemiumBanner
                        }
                        
                        ForEach($playerSlots) { $slot in
                            PlayerSlotEditableRow(
                                slot: $slot,
                                onTapPickProfile: { onTapPickProfile(slot.id) },
                                onTapRemoveProfile: { removeProfile(for: slot.id) },
                                onTapRemovePlayer: { removePlayer(slotId: slot.id) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                // MARK: - Add profile existing
                
                Section(header: Text("Ajouter un profil enregistré")) {
                    if availableProfiles.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.exclam")
                                .foregroundColor(.secondary)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Aucun profil disponible")
                                    .foregroundColor(.primary)
                                Text("Crée un profil dans Réglages, ou ajoute un invité.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    } else {
                        ForEach(availableProfiles) { profile in
                            Button {
                                attemptAddPlayer {
                                    addProfile(profile)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: profile.avatar)
                                        .font(.title3)
                                    
                                    Text(profile.name)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Joueurs")
            .navigationBarTitleDisplayMode(.inline)

            // -----------------------------------------------------------------
            // MARK: - Toolbar
            // -----------------------------------------------------------------
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(playerSlots.count)/\(maxPlayers)")
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { onClose() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // MARK: - Pro upsell
            
            .alert("Deviens Pro", isPresented: $showProUpsellAlert) {
                Button("Plus tard", role: .cancel) { }
                Button("Voir l’offre Pro") {
                    // TODO: branche ton paywall ici
                }
            } message: {
                Text("La version gratuite est limitée à 12 joueurs. Passe Pro pour en ajouter davantage.")
            }
        }
    }

    // MARK: - UI Components

    private var freemiumBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: bannerIconSystemName)
                .foregroundColor(bannerTintColor)

            Text("\(bannerTitle) ")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(bannerTintColor)
            +
            Text(bannerSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Gating core

    /// ✅ Garantit :
    /// - 1..6 : direct
    /// - 7..12 : pub à CHAQUE ajout
    /// - 13 : popup pro
    private func attemptAddPlayer(performAdd: @escaping () -> Void) {

        // MARK: - Pro/Trial: always allow (within maxPlayers defensive)
        if isProOrTrial {
            guard playerSlots.count < maxPlayers else { return }
            performAdd()
            return
        }

        // MARK: - Free: 13th attempt -> upsell (block)
        if playerSlots.count >= freeHardCapPlayersCount {
            showProUpsellAlert = true
            return
        }

        // MARK: - Free: first 6 are free
        if playerSlots.count < freeIncludedPlayersCount {
            performAdd()
            return
        }

        // MARK: - Free: players 7..12 => ad EACH add
        adManager.showStaticGateAd(duration: 15) {
            performAdd()
        }
    }

    // MARK: - Actions

    private func addGuest(_ name: String) {
        playerSlots.append(PlayerSlot(name: name))
    }

    private func addProfile(_ profile: PlayerProfile) {
        var slot = PlayerSlot(name: profile.name)
        slot.profile = profile
        playerSlots.append(slot)
    }

    private func removePlayer(slotId: UUID) {
        playerSlots.removeAll { $0.id == slotId }
    }

    private func removeProfile(for slotId: UUID) {
        guard let index = playerSlots.firstIndex(where: { $0.id == slotId }) else { return }
        let keepName = playerSlots[index].name
        playerSlots[index] = PlayerSlot(name: keepName)
    }
}

// MARK: - Row (editable)
private struct PlayerSlotEditableRow: View {

    @Binding var slot: PlayerSlot

    let onTapPickProfile: () -> Void
    let onTapRemoveProfile: () -> Void
    let onTapRemovePlayer: () -> Void

    private var hasProfile: Bool { slot.profileId != nil }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {

            HStack(spacing: 12) {
                Image(systemName: hasProfile ? "person.fill" : "person.crop.circle")
                    .foregroundColor(hasProfile ? .appPrimary : .appSecondary)
                    .frame(width: 28)

                TextField("Nom du joueur", text: $slot.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: onTapPickProfile) {
                    Label("", systemImage: "person.badge.plus")
                }
                .buttonStyle(.borderless)

                if hasProfile {
                    Button(role: .destructive, action: onTapRemoveProfile) {
                        Label("Retirer profil", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                } else {
                    Button(role: .destructive, action: onTapRemovePlayer) {
                        Label("", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Preview
#Preview("AddPlayerSheet — interactive") {
    AddPlayerSheetPreviewWrapper()
}

private struct AddPlayerSheetPreviewWrapper: View {
    @State private var playerSlots: [PlayerSlot] = [
        PlayerSlot(name: "Alice"),
        PlayerSlot(name: "Bob")
    ]

    var body: some View {
        AddPlayerSheet(
            playerSlots: $playerSlots,
            maxPlayers: 6,
            canAddPlayer: true,
            availableProfiles: [],
            onTapPickProfile: { _ in },
            onClose: {}
        )
    }
}
