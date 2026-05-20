/*
 * AddPlayerSheet.swift
 * PointBoard
 *
 * Created by sy2l on 21/01/2026.
 * Updated by sy2l on 20/05/2026 — V6.1.0 : App gratuite (20 joueurs max)
 * -----------------------------------------------------------------------------
 * AddPlayerSheet — Ajout d'un joueur (invité ou profil)
 * -----------------------------------------------------------------------------
 * - 20 joueurs maximum (gratuit)
 * - Ajout invité (TextField)
 * - Ajout profil enregistré (Liste)
 * - Modification/Suppression en cours de partie
 * -----------------------------------------------------------------------------
 */

import SwiftUI

// MARK: - AddPlayerSheet
struct AddPlayerSheet: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs
    @Binding var playerSlots: [PlayerSlot]

    let maxPlayers: Int = 20
    let canAddPlayer: Bool
    let availableProfiles: [PlayerProfile]

    /// Ouvre la 2e sheet (ProfileSelectionView) depuis une ligne
    let onTapPickProfile: (UUID) -> Void

    let onClose: () -> Void

    // MARK: - State
    @State private var guestName: String = ""

    // MARK: - Computed

    private var trimmedGuestName: String {
        guestName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSubmitGuest: Bool {
        !trimmedGuestName.isEmpty
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
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
                
                Section("Liste (max 20 joueurs)") {
                    VStack(alignment: .leading, spacing: 10) {
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
        }
    }

    // MARK: - Add Player Logic

    /// Ajout de joueur (20 joueurs maximum, gratuit)
    private func attemptAddPlayer(performAdd: @escaping () -> Void) {
        // Limite à 20 joueurs
        guard playerSlots.count < maxPlayers else { return }
        performAdd()
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
            canAddPlayer: true,
            availableProfiles: [],
            onTapPickProfile: { _ in },
            onClose: {}
        )
    }
}
