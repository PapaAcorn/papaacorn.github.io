//
//  MetricUnitsChallengeView.swift
//  Metricize
//

import SwiftUI

struct MetricUnitsChallengeView: View {
    let card: MetricUnitsCard
    let choiceOrder: [Int]
    let isEnabled: Bool
    let onSelect: (Int) -> Void
    var compact: Bool = false

    @State private var appeared = false
    @Environment(\.metricPalette) private var palette

    var body: some View {
        VStack(spacing: compact ? 20 : 32) {
            Text(card.prompt)
                .font(compact ? .title3.weight(.semibold) : .title2.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 12)

            VStack(spacing: compact ? 6 : 10) {
                ForEach(Array(choiceOrder.enumerated()), id: \.element) { index, choiceIndex in
                    choiceButton(
                        label: card.choices[choiceIndex],
                        choiceIndex: choiceIndex,
                        delay: Double(index) * 0.06
                    )
                }
            }
        }
        .padding(.horizontal, 4)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                appeared = true
            }
        }
        .onChange(of: card.id) { _, _ in
            appeared = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.05)) {
                appeared = true
            }
        }
    }

    private func choiceButton(label: String, choiceIndex: Int, delay: Double) -> some View {
        Button {
            onSelect(choiceIndex)
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(MetricTheme.warmEmber.opacity(0.25))
                    .frame(width: 10, height: 10)
                    .overlay {
                        Circle()
                            .fill(MetricTheme.warmEmber)
                            .frame(width: 6, height: 6)
                    }

                Text(label)
                    .font(compact ? .body.weight(.semibold) : .title3.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.textTertiary)
            }
            .padding(.horizontal, compact ? 14 : 20)
            .padding(.vertical, compact ? 12 : 18)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(MetricTheme.warmEmber.opacity(0.08))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(MetricTheme.warmEmber.opacity(0.2), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}
