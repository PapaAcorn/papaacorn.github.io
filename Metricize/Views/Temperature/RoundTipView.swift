//
//  RoundTipView.swift
//  Metricize
//

import SwiftUI

struct RoundTipView: View {
    let roundTitle: String
    let tips: [String]
    let onContinue: () -> Void

    @State private var visibleTipIndex = 0
    @State private var glow = false

    private var isLastTip: Bool {
        visibleTipIndex >= tips.count - 1
    }

    private var actionTitle: String {
        isLastTip ? "Continue" : "Next Tip"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(MetricTheme.warmGlow.opacity(0.12))
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .scaleEffect(glow ? 1.15 : 0.9)

                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [MetricTheme.warmGlow, MetricTheme.coolFrost],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse)
            }
            .padding(.bottom, 32)

            VStack(spacing: 16) {
                Text("Before you continue")
                    .font(.caption.weight(.semibold))
                    .tracking(1.6)
                    .foregroundStyle(MetricTheme.textTertiary)

                Text(roundTitle)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(MetricTheme.textPrimary)

                Text(tips[visibleTipIndex])
                    .font(.title3.weight(.regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MetricTheme.textSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
                    .frame(minHeight: 100)
                    .id(visibleTipIndex)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 12)),
                        removal: .opacity.combined(with: .offset(y: -12))
                    ))
            }
            .animation(.easeInOut(duration: 0.45), value: visibleTipIndex)

            if tips.count > 1 {
                tipProgress
                    .padding(.top, 36)
                    .padding(.horizontal, 48)
            }

            Spacer()

            PrimaryActionButton(title: actionTitle, action: advance)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .onAppear {
            glow = true
        }
    }

    private var tipProgress: some View {
        HStack(spacing: 6) {
            ForEach(tips.indices, id: \.self) { index in
                Capsule()
                    .fill(index == visibleTipIndex ? MetricTheme.warmEmber : Color.white.opacity(0.15))
                    .frame(width: index == visibleTipIndex ? 28 : 8, height: 4)
                    .animation(.spring(response: 0.4), value: visibleTipIndex)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func advance() {
        if isLastTip {
            onContinue()
        } else {
            withAnimation {
                visibleTipIndex += 1
            }
        }
    }
}

#Preview {
    ZStack {
        AmbientBackgroundView(celsius: 15).ignoresSafeArea()
        RoundTipView(
            roundTitle: "Everyday Range",
            tips: TemperatureCurriculum.tips(forRound: 1),
            onContinue: {}
        )
    }
    .preferredColorScheme(.dark)
}
