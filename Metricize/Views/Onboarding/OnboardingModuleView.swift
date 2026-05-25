//
//  OnboardingModuleView.swift
//  Metricize
//

import SwiftUI

struct OnboardingModuleView: View {
    let module: AppModule
    let pages: [OnboardingPage]
    let unlockStore: ModuleUnlockStore
    let finalButtonTitle: String

    @State private var pageIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.metricPalette) private var palette

    private var isLastPage: Bool {
        pageIndex >= pages.count - 1
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                progressHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                pageView(pages[pageIndex], in: geometry)
                    .animation(.easeInOut, value: pageIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(pageIndex)

                PrimaryActionButton(title: isLastPage ? finalButtonTitle : "Next") {
                    advance()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(24, geometry.safeAreaInsets.bottom + 12))
            }
        }
        .navigationTitle(module.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .metricScreenBackground()
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

    private func pageView(_ page: OnboardingPage, in geometry: GeometryProxy) -> some View {
        let sentences = OnboardingText.sentences(in: page.body)
        let titleSize = OnboardingText.titleFontSize(in: geometry)
        let bodySize = OnboardingText.bodyFontSize(
            in: geometry,
            sentenceCount: sentences.count,
            bulletCount: page.bulletItems.count,
            hasTitle: page.title != nil
        )
        let paragraphSpacing = max(bodySize * 0.55, 16)

        return ScrollView {
            VStack(alignment: .leading, spacing: paragraphSpacing) {
                if let title = page.title {
                    Text(title.withDecimalLineBreakProtection)
                        .font(.system(size: titleSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)
                }

                ForEach(Array(sentences.enumerated()), id: \.offset) { _, sentence in
                    Text(sentence)
                        .font(.system(size: bodySize, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                        .lineSpacing(bodySize * 0.2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !page.bulletItems.isEmpty {
                    VStack(alignment: .leading, spacing: max(bodySize * 0.45, 14)) {
                        ForEach(page.bulletItems, id: \.self) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Text("•")
                                    .font(.system(size: bodySize, weight: .semibold))
                                    .foregroundStyle(MetricTheme.warmGlow)
                                Text(item.withDecimalLineBreakProtection)
                                    .font(.system(size: bodySize * 0.92, weight: .regular, design: .rounded))
                                    .foregroundStyle(palette.textSecondary)
                                    .lineSpacing(bodySize * 0.15)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, max(28, geometry.size.width * 0.08))
            .padding(.vertical, 8)
            .frame(minHeight: geometry.size.height * 0.55, alignment: .center)
        }
    }

    private func advance() {
        if isLastPage {
            unlockStore.markComplete(module)
            dismiss()
        } else {
            withAnimation {
                pageIndex += 1
            }
        }
    }
}

private enum OnboardingText {
    static func sentences(in text: String) -> [String] {
        var sentences: [String] = []
        var current = ""
        let characters = Array(text)

        for index in characters.indices {
            let character = characters[index]
            current.append(character)

            if ".!?".contains(character) {
                let isDecimalPoint = character == "."
                    && index > 0
                    && characters[index - 1].isNumber
                    && index + 1 < characters.count
                    && characters[index + 1].isNumber
                if !isDecimalPoint {
                    let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        sentences.append(trimmed.withDecimalLineBreakProtection)
                    }
                    current = ""
                }
            }
        }

        let remainder = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !remainder.isEmpty {
            sentences.append(remainder.withDecimalLineBreakProtection)
        }

        return sentences
    }

    static func titleFontSize(in geometry: GeometryProxy) -> CGFloat {
        min(max(geometry.size.width * 0.075, 26), 34)
    }

    static func bodyFontSize(
        in geometry: GeometryProxy,
        sentenceCount: Int,
        bulletCount: Int,
        hasTitle: Bool
    ) -> CGFloat {
        let contentLines = CGFloat(sentenceCount + bulletCount + (hasTitle ? 2 : 0))
        let heightBased = geometry.size.height * 0.72 / max(contentLines, 4)
        let widthBased = geometry.size.width * 0.058
        return min(max(min(heightBased, widthBased), 22), 36)
    }
}

#Preview {
    NavigationStack {
        OnboardingModuleView(
            module: .howToUse,
            pages: HowToUseContent.pages,
            unlockStore: ModuleUnlockStore(),
            finalButtonTitle: "Get Started"
        )
    }
}
