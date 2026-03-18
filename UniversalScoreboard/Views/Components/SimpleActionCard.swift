//
// SimpleActionCard.swift
// PointBoard
//
// Extracted from ModernCards.swift
//

import SwiftUI

// MARK: - Action Card Simple
struct SimpleActionCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.appSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.appSecondary)
                    .font(.caption)
            }
            .padding(Spacing.lg)
            .modernCardStyle()
        }
        .buttonStyle(.plain)
    }
}

#Preview("SimpleActionCard") {
    SimpleActionCard(
        icon: "book.fill",
        title: "Voir les règles",
        subtitle: "Règles du Uno",
        action: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
