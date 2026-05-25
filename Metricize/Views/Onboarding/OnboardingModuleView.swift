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
    var completionModule: AppModule? = nil
    var onComplete: (() -> Void)? = nil

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
        OnboardingPageContentView(page: page, geometry: geometry)
    }

    private func advance() {
        if isLastPage {
            unlockStore.markComplete(completionModule ?? module)
            if let onComplete {
                onComplete()
            } else {
                dismiss()
            }
        } else {
            withAnimation {
                pageIndex += 1
            }
        }
    }
}

private struct OnboardingPageContentView: View {
    let page: OnboardingPage
    let geometry: GeometryProxy

    @Environment(\.metricPalette) private var palette
    @State private var revealedItemCount = 0
    @State private var revealTask: Task<Void, Never>?

    private var leadingSentences: [String] {
        OnboardingText.sentences(in: page.body)
    }

    private var trailingSentences: [String] {
        guard let bodyAfterBullets = page.bodyAfterBullets else { return [] }
        return OnboardingText.sentences(in: bodyAfterBullets)
    }

    private var revealItems: [OnboardingRevealItem] {
        var items = leadingSentences.indices.map { OnboardingRevealItem.leadingSentence($0) }
        items += page.bulletItems.indices.map { OnboardingRevealItem.bullet($0) }
        items += trailingSentences.indices.map { OnboardingRevealItem.trailingSentence($0) }
        if page.delayedFollowUp != nil {
            items.append(.followUp)
        }
        return items
    }

    private var titleSize: CGFloat {
        OnboardingText.titleFontSize(in: geometry)
    }

    private var bodySize: CGFloat {
        OnboardingText.bodyFontSize(
            in: geometry,
            sentenceCount: leadingSentences.count + trailingSentences.count + (page.delayedFollowUp != nil ? 1 : 0),
            bulletCount: page.bulletItems.count,
            hasTitle: page.title != nil
        )
    }

    private var paragraphSpacing: CGFloat {
        max(bodySize * 0.9, 28)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: paragraphSpacing) {
                if let title = page.title {
                    Text(title.withDecimalLineBreakProtection)
                        .font(.system(size: titleSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)
                }

                ForEach(Array(leadingSentences.enumerated()), id: \.offset) { index, sentence in
                    if isRevealed(.leadingSentence(index)) {
                        Text(sentence)
                            .font(.system(size: bodySize, weight: .regular, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(bodySize * 0.2)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .offset(y: 8)))
                    }
                }

                if !page.bulletItems.isEmpty {
                    VStack(alignment: .center, spacing: max(bodySize * 0.55, 18)) {
                        ForEach(Array(page.bulletItems.enumerated()), id: \.offset) { index, item in
                            if isRevealed(.bullet(index)) {
                                HStack(alignment: .top, spacing: 12) {
                                    Text("•")
                                        .font(.system(size: bodySize, weight: .semibold))
                                        .foregroundStyle(MetricTheme.warmGlow)
                                    Text(item.withDecimalLineBreakProtection)
                                        .font(.system(size: bodySize * 0.92, weight: .regular, design: .rounded))
                                        .foregroundStyle(palette.textSecondary)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(bodySize * 0.15)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .transition(.opacity.combined(with: .offset(y: 8)))
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                ForEach(Array(trailingSentences.enumerated()), id: \.offset) { index, sentence in
                    if isRevealed(.trailingSentence(index)) {
                        Text(sentence)
                            .font(.system(size: bodySize, weight: .regular, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(bodySize * 0.2)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .offset(y: 8)))
                    }
                }

                if isRevealed(.followUp), let followUp = page.delayedFollowUp {
                    Text(followUp)
                        .font(.system(size: bodySize, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(bodySize * 0.2)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .offset(y: 8)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, max(28, geometry.size.width * 0.08))
            .padding(.vertical, 8)
            .frame(minHeight: geometry.size.height * 0.55, alignment: .center)
        }
        .onAppear {
            startRevealSequence()
        }
        .onChange(of: page.id) { _, _ in
            startRevealSequence()
        }
        .onDisappear {
            revealTask?.cancel()
        }
    }

    private func isRevealed(_ item: OnboardingRevealItem) -> Bool {
        guard let index = revealItems.firstIndex(of: item) else { return false }
        return index < revealedItemCount
    }

    private func startRevealSequence() {
        revealTask?.cancel()
        revealedItemCount = 0

        let items = revealItems
        guard !items.isEmpty else { return }

        revealTask = Task {
            for index in items.indices {
                if index > 0 {
                    try? await Task.sleep(for: .seconds(2))
                }
                if Task.isCancelled { return }
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        revealedItemCount = index + 1
                    }
                }
            }
        }
    }
}

private enum OnboardingRevealItem: Equatable {
    case leadingSentence(Int)
    case bullet(Int)
    case trailingSentence(Int)
    case followUp
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
