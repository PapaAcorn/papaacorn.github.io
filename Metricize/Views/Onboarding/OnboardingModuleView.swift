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
    var marksCompletionOnFinish: Bool = true
    var onComplete: (() -> Void)? = nil

    @State private var pageIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.metricPalette) private var palette

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

                pageView(pages[pageIndex], in: geometry)
                    .frame(maxHeight: .infinity)
                    .animation(.easeInOut, value: pageIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(pageIndex)

                PrimaryActionButton(
                    title: isLastPage ? finalButtonTitle : "Next",
                    compact: isLandscape
                ) {
                    advance()
                }
                .padding(.horizontal, 24)
                .padding(.top, isLandscape ? 8 : 0)
                .padding(.bottom, max(isLandscape ? 12 : 24, geometry.safeAreaInsets.bottom + (isLandscape ? 8 : 12)))
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
            if marksCompletionOnFinish {
                unlockStore.markComplete(completionModule ?? module)
            }
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
    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    private var isLandscape: Bool {
        geometry.size.width > geometry.size.height
    }

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
        let base = OnboardingText.titleFontSize(in: geometry)
        return isLandscape ? base * 0.9 : base
    }

    private var bodySize: CGFloat {
        let base = OnboardingText.bodyFontSize(
            in: geometry,
            sentenceCount: leadingSentences.count + trailingSentences.count + (page.delayedFollowUp != nil ? 1 : 0),
            bulletCount: page.bulletItems.count,
            hasTitle: page.title != nil
        )
        return isLandscape ? base * 0.88 : base
    }

    private var paragraphSpacing: CGFloat {
        max(bodySize * 0.9, isLandscape ? 22 : 28)
    }

    private var showsMoreBelow: Bool {
        let remaining = contentHeight - viewportHeight - scrollOffset
        return contentHeight > viewportHeight + 8 && remaining > 24
    }

    private var contentMinHeight: CGFloat {
        if viewportHeight > 0 { return viewportHeight }
        let isLandscape = geometry.size.width > geometry.size.height
        return geometry.size.height * (isLandscape ? 0.72 : 0.68)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                pageContent
                    .background {
                        GeometryReader { contentGeometry in
                            Color.clear.preference(
                                key: OnboardingScrollContentHeightKey.self,
                                value: contentGeometry.size.height
                            )
                        }
                    }
                    .background {
                        GeometryReader { scrollGeometry in
                            Color.clear.preference(
                                key: OnboardingScrollOffsetKey.self,
                                value: -scrollGeometry.frame(in: .named("onboardingScroll")).minY
                            )
                        }
                    }
            }
            .coordinateSpace(name: "onboardingScroll")
            .background {
                GeometryReader { viewportGeometry in
                    Color.clear.onAppear {
                        viewportHeight = viewportGeometry.size.height
                    }
                    .onChange(of: viewportGeometry.size.height) { _, newValue in
                        viewportHeight = newValue
                    }
                }
            }
            .onPreferenceChange(OnboardingScrollContentHeightKey.self) { contentHeight = $0 }
            .onPreferenceChange(OnboardingScrollOffsetKey.self) { scrollOffset = $0 }

            if showsMoreBelow {
                scrollMoreIndicator
            }
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

    private var pageContent: some View {
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
        .padding(.bottom, showsMoreBelow ? 36 : 8)
        .frame(minHeight: contentMinHeight, alignment: .center)
    }

    private var scrollMoreIndicator: some View {
        VStack(spacing: 4) {
            LinearGradient(
                colors: [palette.ink.opacity(0), palette.ink.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 48)
            .allowsHitTesting(false)

            HStack(spacing: 6) {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                Text("More below")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(palette.textSecondary)
            .padding(.bottom, 6)
            .symbolEffect(.bounce, options: .repeating, value: showsMoreBelow)
        }
        .allowsHitTesting(false)
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

private struct OnboardingScrollContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct OnboardingScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
