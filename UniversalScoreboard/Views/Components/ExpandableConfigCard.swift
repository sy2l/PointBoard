//
// ExpandableConfigCard.swift
// PointBoard
//
// Extracted from ModernCards.swift
//

import SwiftUI

// MARK: - Expandable Config Card
struct ExpandableConfigCard<Content: View>: View {
    let title: String
    let icon: String
    let summary: String
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Button(action: onToggle) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.appPrimary)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(summary)
                            .font(.subheadline)
                            .foregroundColor(.appSecondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.appSecondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                content
            }
        }
        .padding(Spacing.lg)
        .modernCardStyle()
    }
}

#Preview("ExpandableConfigCard") {
    ExpandableConfigCard(
        title: "Configuration",
        icon: "slider.horizontal.3",
        summary: "Points - 0→100",
        isExpanded: true,
        onToggle: {},
        content: {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Score descendant", isOn: .constant(true))
                Toggle("Élimination au seuil", isOn: .constant(false))
            }
        }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
