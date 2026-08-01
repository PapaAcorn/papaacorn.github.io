//
//  FinalExamResultView.swift
//  Metricize
//

import SwiftUI

struct FinalExamResultView: View {
    let passed: Bool
    let correct: Int
    let total: Int
    let onContinue: () -> Void
    let onRetry: () -> Void
    let onReviewLearning: () -> Void

    @Environment(\.metricPalette) private var palette

    private var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total) * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (passed ? MetricTheme.success : MetricTheme.warmEmber).opacity(0.35),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: passed ? "star.circle.fill" : "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: passed
                                ? [MetricTheme.success, MetricTheme.warmGlow]
                                : [MetricTheme.warmEmber, MetricTheme.warmGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 28)

            Text(passed ? "You Passed!" : "Keep Practicing")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(palette.textPrimary)

            Text("\(correct) of \(total) correct (\(percent)%)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(passed ? MetricTheme.success : palette.textSecondary)
                .padding(.top, 8)

            Text(passed ? congratulatoryMessage : retryMessage)
                .font(.body)
                .foregroundStyle(palette.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 36)
                .padding(.top, 16)

            Spacer()

            VStack(spacing: 12) {
                PrimaryActionButton(title: passed ? "Finish" : "Try Again", action: passed ? onContinue : onRetry)

                if !passed {
                    Button("Review earlier rounds", action: onReviewLearning)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(palette.textTertiary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    private var congratulatoryMessage: String {
        "You've shown you can estimate everyday temperatures in both directions — within your accuracy setting — using what you've learned. Well done."
    }

    private var retryMessage: String {
        "You need 80% to pass. Review the earlier rounds to strengthen your anchors, then try the final exam again when you're ready."
    }
}
