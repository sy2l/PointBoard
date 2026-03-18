/*
 * SharePreviewView.swift
 * PointBoard
 *
 * Preview avant partage — UI inspirée de la capture (lisible, clean).
 *
 * Objectifs :
 * - UI 100% SwiftUI (lisible)
 * - Design cohérent avec DesignSystem (cards, radius, shadows)
 * - Scroll uniquement si la liste dépasse (pas de "vert pour vert")
 * - Bouton Partager -> ShareManager.shareStory(...)
 *
 * Fix navigation (23/02/2026):
 * - SharePreviewView est présenté en fullScreenCover(item:)
 *   => OK d’avoir un NavigationStack LOCAL pour obtenir title + toolbar.
 *
 * Updated on 08/02/2026 — UI aligned with target mock
 */

import SwiftUI

// MARK: - Share Preview
struct SharePreviewView: View {

    // MARK: - Inputs
    let result: GameResult
    let icon: ShareManager.ShareIcon
    let themeColor: Color

    // MARK: - Env
    @Environment(\.dismiss) private var dismiss

    // MARK: - State (freeze hour)
    @State private var openedAt: Date = Date()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {

                headerCard

                storyCard

                actions
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Prévisualisation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        HStack(spacing: Spacing.md) {

            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .fill(themeColor.opacity(0.15))
                Text(icon.emoji)
                    .font(.system(size: 28))
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text("Prêt à partager ?")
                    .font(.cardTitle)
                    .foregroundColor(.textPrimary)

                Text("\(result.players.count) joueurs • \(result.totalTurns) tours")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Text("Story")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Color.cardBackground)
                .clipShape(Capsule())
        }
        .padding(Spacing.lg)
        .modernCardStyle()
    }

    // MARK: - Story Card
    private var storyCard: some View {
        VStack(spacing: Spacing.lg) {

            storyTopBar
                .padding(.top, Spacing.lg)
                .padding(.horizontal, Spacing.lg)

            classementCardScrollable
                .padding(.horizontal, Spacing.lg)
        }
        .padding(.bottom, Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(themeColor)
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
        )
    }

    // MARK: - Story Top Bar
    private var storyTopBar: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            Text(icon.emoji)
                .font(.system(size: 44))

            VStack(alignment: .leading, spacing: 2) {
                Text("LEADERBOARD")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.95))
                    .tracking(1.2)

                Text("\(result.formattedDate) à \(formattedHour)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.80))
            }

            Spacer()

            HStack(spacing: Spacing.xs) {
                Image(systemName: "trophy.fill")
                    .font(.caption)
                Text("PointBoard")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white.opacity(0.92))
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.white.opacity(0.18))
            .clipShape(Capsule())
        }
    }

    // MARK: - Classement (Scroll only if needed)
    private var classementCardScrollable: some View {
        let maxListHeight: CGFloat = 320

        return VStack(spacing: Spacing.md) {

            HStack {
                Text("Classement")
                    .font(.cardTitle)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(result.totalTurns) tours")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.sm) {
                    ForEach(displayPlayers.indices, id: \.self) { idx in
                        let item = displayPlayers[idx]
                        LeaderboardRow(
                            rank: idx + 1,
                            name: item.name,
                            score: item.score,
                            isWinner: item.isWinner,
                            themeColor: themeColor
                        )
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(maxHeight: maxListHeight)
            .modifier(ScrollBounceOnSizeIfAvailable())
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                .stroke(Color.textSecondary.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Actions
    private var actions: some View {
        VStack(spacing: Spacing.md) {

            Button {
                ShareManager.shared.shareStory(result: result, icon: icon)
                dismiss()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Partager")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            }

            Button {
                dismiss()
            } label: {
                Text("Retour")
                    .font(.bodyText)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.cardBackground)
                    .foregroundColor(.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                            .stroke(Color.textSecondary.opacity(0.18), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Data
    private var displayPlayers: [(name: String, score: Int, isWinner: Bool)] {
        let winnerIDs = Set(result.winners.map { $0.id })

        let sorted = result.players.sorted { a, b in
            let aWin = winnerIDs.contains(a.id)
            let bWin = winnerIDs.contains(b.id)
            if aWin != bWin { return aWin && !bWin }
            return a.score > b.score
        }

        return sorted.prefix(8).map { p in
            (p.name, p.score, winnerIDs.contains(p.id))
        }
    }

    private var formattedHour: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: openedAt)
    }
}

// MARK: - Leaderboard Row
private struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let score: Int
    let isWinner: Bool
    let themeColor: Color

    var body: some View {
        HStack(spacing: Spacing.md) {

            rankBadge

            Text(name)
                .font(.bodyText)
                .fontWeight(isWinner ? .bold : .semibold)
                .foregroundColor(.textPrimary)
                .lineLimit(1)

            Spacer()

            Text("\(score)")
                .font(.bodyText)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundColor(isWinner ? themeColor : .textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(isWinner ? themeColor.opacity(0.14) : Color.appBackground.opacity(0.70))
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .stroke(isWinner ? themeColor.opacity(0.35) : Color.textSecondary.opacity(0.10), lineWidth: 1)
        )
    }

    private var rankBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                .fill(isWinner ? themeColor.opacity(0.18) : Color.textSecondary.opacity(0.08))

            Text(isWinner ? "👑" : "\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isWinner ? themeColor : .textSecondary)
        }
        .frame(width: 42, height: 28)
    }
}

// MARK: - iOS compatibility helper
private struct ScrollBounceOnSizeIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}

// MARK: - Preview
#Preview {
    let settings = GameSettings(
        mode: .points,
        initialValue: 0,
        target: Target(value: 100, comparator: .greaterThanOrEqual, consequence: .eliminated),
        endCondition: EndCondition(type: .targetReached, value: 1),
        lowestScoreIsBest: false
    )

    let game = Game(
        id: UUID().uuidString,
        presetId: .skyjo,
        settings: settings,
        players: [
            Player(id: "1", name: "Alice", score: 120, isEliminated: false, hasReachedTarget: true, profileId: nil),
            Player(id: "2", name: "Charlie", score: 105, isEliminated: false, hasReachedTarget: false, profileId: nil),
            Player(id: "3", name: "Bob", score: 85, isEliminated: false, hasReachedTarget: false, profileId: nil),
            Player(id: "4", name: "David", score: 72, isEliminated: false, hasReachedTarget: false, profileId: nil),
            Player(id: "5", name: "Emma", score: 66, isEliminated: false, hasReachedTarget: false, profileId: nil)
        ],
        isOver: true
    )

    return SharePreviewView(
        result: GameResult(from: game),
        icon: .trophy,
        themeColor: PresetID.skyjo.themeColor
    )
}
