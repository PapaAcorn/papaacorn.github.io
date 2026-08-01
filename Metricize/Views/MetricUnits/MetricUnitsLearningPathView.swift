//
//  MetricUnitsLearningPathView.swift
//  Metricize
//

import SwiftUI

struct MetricUnitsLearningPathView: View {
    let progressStore: MetricUnitsProgressStore
    var onRedoCompletedSubRound: ((Int) -> Void)?

    @Environment(\.metricPalette) private var palette

    private var nodes: [(subRoundIndex: Int, state: LearningPathNodeState)] {
        (0..<MetricUnitsGameConstants.subRoundsPerRound).map { subRoundIndex in
            (subRoundIndex, nodeState(for: subRoundIndex))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your path")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(Array(nodes.enumerated()), id: \.element.subRoundIndex) { index, node in
                        if index > 0 {
                            Capsule()
                                .fill(node.state == .completed || nodes[index - 1].state == .completed
                                    ? MetricTheme.warmEmber.opacity(0.55)
                                    : palette.progressTrack)
                                .frame(width: 24, height: 3)
                                .padding(.bottom, 22)
                        }
                        pathNode(subRoundIndex: node.subRoundIndex, state: node.state, isRoundStart: node.subRoundIndex == 0)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.cardFill.opacity(0.85))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(palette.glassStroke, lineWidth: 1)
                }
        }
    }

    private func nodeState(for subRoundIndex: Int) -> LearningPathNodeState {
        if progressStore.isModuleComplete || subRoundIndex < progressStore.currentSubRoundIndex {
            return .completed
        }
        if subRoundIndex == progressStore.currentSubRoundIndex {
            return .current
        }
        return .locked
    }

    @ViewBuilder
    private func pathNode(subRoundIndex: Int, state: LearningPathNodeState, isRoundStart: Bool) -> some View {
        let label = MetricUnitsCurriculum.subRoundLabel(majorRoundIndex: 0, subRoundIndex: subRoundIndex)
        let nodeBody = VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(nodeBackground(state))
                    .frame(width: isRoundStart ? 48 : 40, height: isRoundStart ? 48 : 40)
                    .overlay {
                        Circle()
                            .strokeBorder(nodeBorder(state), lineWidth: state == .current ? 2.5 : 1)
                    }
                nodeIcon(state, diameter: isRoundStart ? 48 : 40)
            }
            Text(label)
                .font(isRoundStart ? .caption.weight(.bold).monospacedDigit() : .caption2.weight(.semibold).monospacedDigit())
                .foregroundStyle(nodeLabelColor(state))
        }
        .frame(width: isRoundStart ? 58 : 54)

        return Group {
            if state == .completed, let onRedoCompletedSubRound {
                Button {
                    onRedoCompletedSubRound(subRoundIndex)
                } label: {
                    nodeBody
                }
                .buttonStyle(.plain)
            } else {
                nodeBody
            }
        }
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
                .fill(MetricTheme.warmGlow)
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
        case .current: MetricTheme.warmEmber.opacity(0.35)
        case .locked: palette.chipFill
        }
    }

    private func nodeBorder(_ state: LearningPathNodeState) -> Color {
        switch state {
        case .completed: MetricTheme.success.opacity(0.8)
        case .current: MetricTheme.warmEmber
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
