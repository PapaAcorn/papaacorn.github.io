//
//  HereToThereLearningPathView.swift
//  Metricize
//

import SwiftUI

struct HereToThereLearningPathView: View {
    let progressStore: HereToThereProgressStore
    var style: LearningPathStyle = .standard
    var onRedoCompletedSubRound: ((Int, Int) -> Void)?
    var onRedoFinalExam: (() -> Void)?

    @Environment(\.metricPalette) private var palette

    private var nodes: [LearningPathNode] {
        HereToThereCurriculum.rounds.flatMap { round -> [LearningPathNode] in
            if round.isFinalExam {
                return [
                    LearningPathNode(
                        roundIndex: round.index,
                        subRoundIndex: 0,
                        isFinalExam: true,
                        isRoundStart: true,
                        state: nodeState(roundIndex: round.index, subRoundIndex: 0, isFinalExam: true)
                    ),
                ]
            }
            return (0..<round.subRoundCount).map { subIndex in
                LearningPathNode(
                    roundIndex: round.index,
                    subRoundIndex: subIndex,
                    isFinalExam: false,
                    isRoundStart: subIndex == 0,
                    state: nodeState(roundIndex: round.index, subRoundIndex: subIndex, isFinalExam: false)
                )
            }
        }
    }

    var body: some View {
        switch style {
        case .standard:
            standardPath
        case .compact:
            compactPath
        }
    }

    private var standardPath: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your path")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textTertiary)

            pathScroll
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(pathBackground(cornerRadius: 18))
    }

    private var compactPath: some View {
        pathScroll
            .padding(.vertical, 4)
    }

    private var pathScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                    if index > 0 {
                        pathConnector(from: nodes[index - 1], to: node)
                    }
                    pathNode(node)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, style == .compact ? 2 : 8)
        }
    }

    private func pathBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(palette.cardFill.opacity(0.85))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(palette.glassStroke, lineWidth: 1)
            }
    }

    private func nodeState(roundIndex: Int, subRoundIndex: Int, isFinalExam: Bool) -> LearningPathNodeState {
        if isFinalExam {
            if !progressStore.areLearningRoundsComplete() { return .locked }
            if progressStore.isActiveFinalExamSession { return .current }
            if progressStore.hasPassedFinalExam { return .completed }
            return .current
        }
        if progressStore.hasPassedFinalExam {
            return .completed
        }
        if roundIndex < progressStore.currentRoundIndex {
            return .completed
        }
        if roundIndex > progressStore.currentRoundIndex {
            return .locked
        }
        if subRoundIndex < progressStore.currentSubRoundIndex {
            return .completed
        }
        if subRoundIndex == progressStore.currentSubRoundIndex {
            return .current
        }
        return .locked
    }

    @ViewBuilder
    private func pathNode(_ node: LearningPathNode) -> some View {
        let metrics = nodeMetrics(for: node)
        let nodeBody = VStack(spacing: metrics.labelSpacing) {
            ZStack {
                Circle()
                    .fill(nodeBackground(node.state))
                    .frame(width: metrics.diameter, height: metrics.diameter)
                    .overlay {
                        Circle()
                            .strokeBorder(nodeBorder(node.state), lineWidth: node.state == .current ? 2.5 : 1)
                    }

                nodeIcon(node.state, diameter: metrics.diameter)
            }

            if style == .standard || node.isRoundStart || node.isFinalExam {
                Text(HereToThereCurriculum.pathLabel(roundIndex: node.roundIndex, subRoundIndex: node.subRoundIndex))
                    .font(metrics.labelFont)
                    .foregroundStyle(nodeLabelColor(node.state))
            }
        }
        .frame(width: metrics.columnWidth)

        Group {
            if node.isFinalExam, progressStore.canAccessFinalExam, let onRedoFinalExam {
                Button {
                    onRedoFinalExam()
                } label: {
                    nodeBody
                }
                .buttonStyle(.plain)
            } else if node.state == .completed, !node.isFinalExam, let onRedoCompletedSubRound {
                Button {
                    onRedoCompletedSubRound(node.roundIndex, node.subRoundIndex)
                } label: {
                    nodeBody
                }
                .buttonStyle(.plain)
            } else {
                nodeBody
            }
        }
        .accessibilityLabel(accessibilityLabel(for: node))
        .accessibilityHint(accessibilityHint(for: node))
    }

    private func accessibilityLabel(for node: LearningPathNode) -> String {
        let status: String
        switch node.state {
        case .completed: status = "completed"
        case .current: status = "current"
        case .locked: status = "locked"
        }
        let name = node.isFinalExam ? "Final exam" : "Round \(HereToThereCurriculum.pathLabel(roundIndex: node.roundIndex, subRoundIndex: node.subRoundIndex))"
        return "\(name), \(status)"
    }

    private func accessibilityHint(for node: LearningPathNode) -> String {
        if node.isFinalExam, progressStore.canAccessFinalExam, onRedoFinalExam != nil {
            return "Starts a new final exam attempt."
        }
        if node.state == .completed, !node.isFinalExam, onRedoCompletedSubRound != nil {
            return "Opens the review screen to practice this section again."
        }
        return ""
    }

    private func nodeMetrics(for node: LearningPathNode) -> (
        diameter: CGFloat,
        columnWidth: CGFloat,
        labelSpacing: CGFloat,
        labelFont: Font
    ) {
        let isLarge = node.isRoundStart || node.isFinalExam
        switch style {
        case .standard:
            return (
                isLarge ? 48 : 40,
                isLarge ? 58 : 54,
                6,
                isLarge ? .caption.weight(.bold).monospacedDigit() : .caption2.weight(.semibold).monospacedDigit()
            )
        case .compact:
            return (
                isLarge ? 30 : 24,
                isLarge ? 36 : 30,
                0,
                .caption2.weight(.bold).monospacedDigit()
            )
        }
    }

    private func pathConnector(from previous: LearningPathNode, to next: LearningPathNode) -> some View {
        let isActive = previous.state == .completed
        let width: CGFloat = style == .compact ? 12 : 24
        let bottomPad: CGFloat = style == .compact ? 10 : 22
        let largePad = (previous.isRoundStart || next.isRoundStart) ? 4.0 : 0.0
        return Capsule()
            .fill(isActive ? MetricTheme.coolFrost.opacity(0.55) : palette.progressTrack)
            .frame(width: width, height: 3)
            .padding(.bottom, bottomPad + largePad)
    }

    @ViewBuilder
    private func nodeIcon(_ state: LearningPathNodeState, diameter: CGFloat) -> some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
        case .current:
            Circle()
                .fill(MetricTheme.coolFrost)
                .frame(width: diameter * 0.28, height: diameter * 0.28)
        case .locked:
            Image(systemName: "lock.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(palette.textTertiary)
        }
    }

    private func nodeBackground(_ state: LearningPathNodeState) -> Color {
        switch state {
        case .completed: MetricTheme.success
        case .current: MetricTheme.coolFrost.opacity(0.35)
        case .locked: palette.chipFill
        }
    }

    private func nodeBorder(_ state: LearningPathNodeState) -> Color {
        switch state {
        case .completed: MetricTheme.success.opacity(0.8)
        case .current: MetricTheme.coolFrost
        case .locked: palette.chipStroke
        }
    }

    private func nodeLabelColor(_ state: LearningPathNodeState) -> Color {
        switch state {
        case .completed: palette.textSecondary
        case .current: palette.textPrimary
        case .locked: palette.textTertiary
        }
    }
}
