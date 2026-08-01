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
    @Environment(\.metricPalette) private var palette

    private var isLastTip: Bool {
        visibleTipIndex >= tips.count - 1
    }

    private var actionTitle: String {
        isLastTip ? "Continue" : "Next Tip"
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: isLandscape ? 16 : 24) {
                        ZStack {
                            Circle()
                                .fill(MetricTheme.warmGlow.opacity(0.12))
                                .frame(width: isLandscape ? 100 : 140, height: isLandscape ? 100 : 140)
                                .blur(radius: 30)
                                .scaleEffect(glow ? 1.15 : 0.9)

                            Image(systemName: "sparkles")
                                .font(.system(size: isLandscape ? 34 : 44, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [MetricTheme.warmGlow, MetricTheme.coolFrost],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolEffect(.pulse)
                        }
                        .padding(.top, isLandscape ? 8 : 16)

                        VStack(spacing: isLandscape ? 12 : 16) {
                            Text("Before you continue")
                                .font(.caption.weight(.semibold))
                                .tracking(1.6)
                                .foregroundStyle(palette.textTertiary)

                            Text(roundTitle)
                                .font(isLandscape ? .title2.weight(.semibold) : .title.weight(.semibold))
                                .foregroundStyle(palette.textPrimary)
                                .multilineTextAlignment(.center)

                            Text(tips[visibleTipIndex])
                                .font(isLandscape ? .body : .title3.weight(.regular))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(palette.textSecondary)
                                .lineSpacing(4)
                                .padding(.horizontal, 28)
                                .frame(minHeight: isLandscape ? 60 : 100)
                                .id(visibleTipIndex)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .offset(y: 12)),
                                    removal: .opacity.combined(with: .offset(y: -12))
                                ))
                        }
                        .animation(.easeInOut(duration: 0.45), value: visibleTipIndex)

                        if tips.count > 1 {
                            tipProgress
                                .padding(.top, isLandscape ? 16 : 24)
                                .padding(.horizontal, 48)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                }

                PrimaryActionButton(title: actionTitle, compact: isLandscape, action: advance)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, max(isLandscape ? 12 : 32, geometry.safeAreaInsets.bottom + 8))
            }
        }
        .onAppear {
            glow = true
        }
    }

    private var tipProgress: some View {
        HStack(spacing: 6) {
            ForEach(tips.indices, id: \.self) { index in
                Capsule()
                    .fill(index == visibleTipIndex ? MetricTheme.warmEmber : palette.progressTrack)
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
