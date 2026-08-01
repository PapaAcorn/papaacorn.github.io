//
//  MetricUnitsIntroView.swift
//  Metricize
//

import SwiftUI

struct MetricUnitsIntroView: View {
    let onStartPractice: () -> Void
    let onSkipToPractice: () -> Void

    @State private var pageIndex = 0
    @Environment(\.metricPalette) private var palette

    private var pages: [MetricUnitsIntroPage] {
        MetricUnitsBasicsContent.pages
    }

    private var isLastPage: Bool {
        pageIndex >= pages.count - 1
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            VStack(spacing: 0) {
                progressHeader
                    .padding(.horizontal, 24)
                    .padding(.top, isLandscape ? 4 : 16)
                    .padding(.bottom, isLandscape ? 8 : 20)

                ScrollView {
                    pageContent(pages[pageIndex], isLandscape: isLandscape)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }

                VStack(spacing: 12) {
                    PrimaryActionButton(
                        title: isLastPage ? "Start Practice Questions" : "Next",
                        compact: isLandscape
                    ) {
                        advance()
                    }

                    if pageIndex == 0 {
                        Button("Skip to Practice", action: onSkipToPractice)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(palette.textTertiary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(isLandscape ? 12 : 24, geometry.safeAreaInsets.bottom + 8))
            }
        }
        .navigationTitle("Intro to the Metric Units")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .metricScreenBackground()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Skip", action: onSkipToPractice)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == pageIndex ? MetricTheme.warmEmber : palette.progressTrack)
                    .frame(width: index == pageIndex ? 28 : 8, height: 4)
                    .animation(.spring(response: 0.4), value: pageIndex)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func pageContent(_ page: MetricUnitsIntroPage, isLandscape: Bool) -> some View {
        VStack(alignment: .leading, spacing: isLandscape ? 16 : 24) {
            if let title = page.title {
                Text(title)
                    .font(isLandscape ? .title2.weight(.bold) : .title.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
            }

            Text(page.body)
                .font(isLandscape ? .body : .title3)
                .foregroundStyle(palette.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            if let example = page.hierarchyExample {
                MetricPrefixHierarchyView(example: example)
            }

            if let bodyAfterExample = page.bodyAfterExample {
                Text(bodyAfterExample)
                    .font(isLandscape ? .body : .title3)
                    .foregroundStyle(palette.textSecondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .id(pageIndex)
    }

    private func advance() {
        if isLastPage {
            onStartPractice()
        } else {
            withAnimation {
                pageIndex += 1
            }
        }
    }
}

private struct MetricPrefixHierarchyView: View {
    let example: MetricPrefixHierarchyExample

    @Environment(\.metricPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(example.rows) { row in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if row.prefix.isEmpty {
                        Text(row.unitName)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(palette.textPrimary)
                    } else {
                        Text(row.prefix)
                            .font(.body.weight(.semibold))
                            .italic()
                            .foregroundStyle(MetricTheme.warmEmber)
                        Text(row.unitSuffix)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(palette.textPrimary)
                    }

                    Spacer(minLength: 8)

                    Text(row.meaning)
                        .font(.subheadline)
                        .foregroundStyle(palette.textTertiary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(palette.cardFill.opacity(0.85))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(palette.glassStroke, lineWidth: 1)
                        }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MetricUnitsIntroView(onStartPractice: {}, onSkipToPractice: {})
    }
    .environment(\.metricPalette, MetricPalette.dark)
}
