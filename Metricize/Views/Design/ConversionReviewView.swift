//
//  ConversionReviewView.swift
//  Metricize
//

import SwiftUI

struct ConversionReviewView: View {
    let items: [ConversionReviewItem]
    let onContinue: () -> Void

    @Environment(\.metricPalette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text("Review these conversions")
                    .font(.caption.weight(.semibold))
                    .tracking(1.6)
                    .foregroundStyle(palette.textTertiary)

                Text("Take a moment to read through these conversions before you practice.")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
            }
            .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            Text(item.source)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(palette.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)

                            Image(systemName: "arrow.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(palette.textTertiary)

                            Text(item.target)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(MetricTheme.warmEmber)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.cardFill.opacity(0.9))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(palette.glassStroke, lineWidth: 1)
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            PrimaryActionButton(title: "Start Practice", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
    }
}
