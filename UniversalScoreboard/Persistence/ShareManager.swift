/*
 * ShareManager.swift
 * PointBoard
 *
 * Gestionnaire de partage moderne avec carte stylisée
 * V4.1 — Preview reliability + API stable
 *
 * Objectifs :
 * - shareStory/export = image full qualité (1080x1920)
 * - preview = image plus légère (720x1280) pour vitesse + fiabilité
 * - génération d’image réutilisable
 *
 * NOTE :
 * - Le bug de “Préparation du partage…” venait du flow SwiftUI (bool + optional) côté ResultsView,
 *   pas de ShareManager. Ici on garde ton rendu, on ne change pas le design.
 */

import SwiftUI
import UIKit

final class ShareManager {

    static let shared = ShareManager()
    private init() {}

    // MARK: - Share Icon

    enum ShareIcon: String, CaseIterable {
        case trophy = "trophy.fill"
        case crown = "crown.fill"
        case target = "target"
        case star = "star.fill"

        var emoji: String {
            switch self {
            case .trophy: return "🏆"
            case .crown: return "👑"
            case .target: return "🎯"
            case .star: return "⭐"
            }
        }
    }

    // MARK: - Top-most VC

    private func topMostViewController() -> UIViewController? {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
            var topVC = keyWindow.rootViewController
        else { return nil }

        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }

    private func presentActivityVC(_ activityVC: UIActivityViewController, from sourceView: UIView? = nil) {
        guard let topVC = topMostViewController() else {
            print("❌ Impossible de trouver le view controller")
            return
        }

        if let popover = activityVC.popoverPresentationController {
            if let sourceView = sourceView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
            } else {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(
                    x: topVC.view.bounds.midX,
                    y: topVC.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
        }

        topVC.present(activityVC, animated: true)
    }

    // MARK: - Public Share

    /// Partage basique (gratuit)
    func shareBasic(result: GameResult, from view: UIView? = nil) {
        guard let image = renderModernResultsCard(result: result, icon: .trophy, size: Self.fullStorySize) else {
            print("❌ Erreur génération image")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentActivityVC(activityVC, from: view)
    }

    /// Partage story (pro)
    func shareStory(result: GameResult, icon: ShareIcon = .trophy, from view: UIView? = nil) {
        guard let image = renderModernResultsCard(result: result, icon: icon, size: Self.fullStorySize) else {
            print("❌ Erreur génération image")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentActivityVC(activityVC, from: view)
    }

    // MARK: - Preview helper (Public)

    /// ✅ Permet de générer une image preview (plus légère)
    func generatePreviewImage(result: GameResult, icon: ShareIcon = .trophy) -> UIImage? {
        renderModernResultsCard(result: result, icon: icon, size: Self.previewStorySize)
    }

    // MARK: - CSV Export (inchangé)

    private func escapeCSVValue(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    func exportCSV(result: GameResult, from view: UIView? = nil) {
        var csvContent = "Rang,Joueur,Score\n"

        let sortedPlayers = result.players.sorted { p1, p2 in
            if result.winners.contains(where: { $0.id == p1.id }) { return true }
            if result.winners.contains(where: { $0.id == p2.id }) { return false }
            return p1.score > p2.score
        }

        for (index, player) in sortedPlayers.enumerated() {
            let rank = index + 1
            let name = escapeCSVValue(player.name)
            csvContent += "\(rank),\(name),\(player.score)\n"
        }

        let fileName = "PointBoard_\(result.formattedDate.replacingOccurrences(of: "/", with: "-")).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            presentActivityVC(activityVC, from: view)
        } catch {
            print("❌ Erreur export CSV: \(error)")
        }
    }

    // MARK: - Rendering

    private static let fullStorySize = CGSize(width: 1080, height: 1920)   // export / partage
    private static let previewStorySize = CGSize(width: 720, height: 1280) // preview (plus rapide)

    /// ✅ Rendu UIKit (ton design actuel)
    private func renderModernResultsCard(result: GameResult, icon: ShareIcon, size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext

            // MARK: - Fond (Yale Blue → Ink Black)
            let yaleBlue = UIColor(red: 0x34/255.0, green: 0x49/255.0, blue: 0x66/255.0, alpha: 1.0)
            let inkBlack = UIColor(red: 0x0D/255.0, green: 0x18/255.0, blue: 0x21/255.0, alpha: 1.0)

            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [yaleBlue.cgColor, inkBlack.cgColor] as CFArray,
                locations: [0.0, 1.0]
            ) {
                ctx.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: size.width / 2, y: 0),
                    end: CGPoint(x: size.width / 2, y: size.height),
                    options: []
                )
            }

            // MARK: - Motif décoratif (cercles)
            ctx.saveGState()
            ctx.setBlendMode(.softLight)
            let powderBlue = UIColor(red: 0xB4/255.0, green: 0xCD/255.0, blue: 0xED/255.0, alpha: 0.10)
            powderBlue.setFill()
            ctx.fillEllipse(in: CGRect(x: -100, y: 100, width: 400, height: 400))
            ctx.fillEllipse(in: CGRect(x: size.width - 300, y: size.height - 500, width: 500, height: 500))
            ctx.restoreGState()

            // MARK: - Titre
            let scaleH = size.height / 1920
            let titleY: CGFloat = 120 * scaleH

            let appTitle = "POINTBOARD"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 56 * scaleH, weight: .black),
                .foregroundColor: UIColor.white,
                .kern: 4.0
            ]
            let titleSize = appTitle.size(withAttributes: titleAttributes)
            appTitle.draw(
                at: CGPoint(x: (size.width - titleSize.width) / 2, y: titleY),
                withAttributes: titleAttributes
            )

            // Ligne sous titre
            let lineY = titleY + titleSize.height + 20 * scaleH
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: CGPoint(x: size.width * 0.3, y: lineY))
            ctx.addLine(to: CGPoint(x: size.width * 0.7, y: lineY))
            ctx.strokePath()

            // MARK: - Carte centrale
            let scaleW = size.width / 1080
            let cardY: CGFloat = 300 * scaleH
            let cardWidth: CGFloat = size.width - 120 * scaleW
            let cardHeight: CGFloat = 1200 * scaleH
            let cardX: CGFloat = (size.width - cardWidth) / 2

            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: 10), blur: 30, color: UIColor.black.withAlphaComponent(0.3).cgColor)

            let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 24)
            UIColor.white.setFill()
            cardPath.fill()
            ctx.restoreGState()

            // Titre "Résultats"
            let resultsTitle = "RÉSULTATS"
            let resultsTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40 * scaleH, weight: .bold),
                .foregroundColor: inkBlack,
                .kern: 2.0
            ]
            let resultsTitleSize = resultsTitle.size(withAttributes: resultsTitleAttributes)
            resultsTitle.draw(
                at: CGPoint(x: (size.width - resultsTitleSize.width) / 2, y: cardY + 60 * scaleH),
                withAttributes: resultsTitleAttributes
            )

            // Date & stats
            let dateStatsText = "\(result.formattedDate) • \(result.players.count) joueurs • \(result.totalTurns) tours"
            let dateStatsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20 * scaleH, weight: .medium),
                .foregroundColor: yaleBlue.withAlphaComponent(0.7)
            ]
            let dateStatsSize = dateStatsText.size(withAttributes: dateStatsAttributes)
            dateStatsText.draw(
                at: CGPoint(x: (size.width - dateStatsSize.width) / 2, y: cardY + 120 * scaleH),
                withAttributes: dateStatsAttributes
            )

            // MARK: - Tri joueurs (ton tri)
            var yOffset: CGFloat = cardY + 220 * scaleH

            let sortedPlayers = result.players.sorted { p1, p2 in
                if result.winners.contains(where: { $0.id == p1.id }) { return true }
                if result.winners.contains(where: { $0.id == p2.id }) { return false }
                return p1.score > p2.score
            }

            // MARK: - Top 3
            for (index, player) in sortedPlayers.prefix(3).enumerated() {
                let rank = index + 1

                let medalColor: UIColor
                let medalEmoji: String
                switch rank {
                case 1: medalColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0); medalEmoji = "🥇"
                case 2: medalColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0); medalEmoji = "🥈"
                case 3: medalColor = UIColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0); medalEmoji = "🥉"
                default: medalColor = .gray; medalEmoji = ""
                }

                let podiumRect = CGRect(
                    x: cardX + 40 * scaleW,
                    y: yOffset - 10 * scaleH,
                    width: cardWidth - 80 * scaleW,
                    height: (rank == 1 ? 120 : 100) * scaleH
                )
                let podiumPath = UIBezierPath(roundedRect: podiumRect, cornerRadius: 16)
                medalColor.withAlphaComponent(0.15).setFill()
                podiumPath.fill()

                let medalAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: (rank == 1 ? 60 : 50) * scaleH)
                ]
                let medalSize = medalEmoji.size(withAttributes: medalAttributes)
                medalEmoji.draw(
                    at: CGPoint(x: cardX + 70 * scaleW, y: yOffset + (rank == 1 ? 30 : 25) * scaleH),
                    withAttributes: medalAttributes
                )

                let playerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: (rank == 1 ? 36 : 32) * scaleH, weight: rank == 1 ? .bold : .semibold),
                    .foregroundColor: inkBlack
                ]
                player.name.draw(
                    at: CGPoint(x: cardX + 70 * scaleW + medalSize.width + 20 * scaleW, y: yOffset + 15 * scaleH),
                    withAttributes: playerAttributes
                )

                let scoreText = "\(player.score) pts"
                let scoreAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: (rank == 1 ? 32 : 28) * scaleH, weight: .bold),
                    .foregroundColor: medalColor
                ]
                let scoreSize = scoreText.size(withAttributes: scoreAttributes)
                scoreText.draw(
                    at: CGPoint(x: cardX + cardWidth - scoreSize.width - 60 * scaleW, y: yOffset + 20 * scaleH),
                    withAttributes: scoreAttributes
                )

                yOffset += (rank == 1 ? 140 : 120) * scaleH
            }

            // MARK: - Autres joueurs
            if sortedPlayers.count > 3 {
                yOffset += 40 * scaleH

                ctx.setStrokeColor(yaleBlue.withAlphaComponent(0.2).cgColor)
                ctx.setLineWidth(1)
                ctx.move(to: CGPoint(x: cardX + 60 * scaleW, y: yOffset))
                ctx.addLine(to: CGPoint(x: cardX + cardWidth - 60 * scaleW, y: yOffset))
                ctx.strokePath()

                yOffset += 40 * scaleH

                for (index, player) in sortedPlayers.dropFirst(3).prefix(5).enumerated() {
                    let rank = index + 4

                    let rankText = "\(rank)"
                    let rankAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 24 * scaleH, weight: .semibold),
                        .foregroundColor: yaleBlue.withAlphaComponent(0.6)
                    ]
                    rankText.draw(at: CGPoint(x: cardX + 70 * scaleW, y: yOffset), withAttributes: rankAttributes)

                    let nameAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 24 * scaleH, weight: .medium),
                        .foregroundColor: inkBlack
                    ]
                    player.name.draw(at: CGPoint(x: cardX + 130 * scaleW, y: yOffset), withAttributes: nameAttributes)

                    let scoreText = "\(player.score) pts"
                    let scoreAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 24 * scaleH, weight: .semibold),
                        .foregroundColor: yaleBlue
                    ]
                    let scoreSize = scoreText.size(withAttributes: scoreAttributes)
                    scoreText.draw(
                        at: CGPoint(x: cardX + cardWidth - scoreSize.width - 60 * scaleW, y: yOffset),
                        withAttributes: scoreAttributes
                    )

                    yOffset += 60 * scaleH
                }
            }

            // Footer
            let footerY = size.height - 150 * scaleH
            let footerText = "Partagé depuis PointBoard"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22 * scaleH, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let footerSize = footerText.size(withAttributes: footerAttributes)
            footerText.draw(
                at: CGPoint(x: (size.width - footerSize.width) / 2, y: footerY),
                withAttributes: footerAttributes
            )
        }
    }
}
