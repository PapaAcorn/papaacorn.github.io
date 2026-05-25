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

    private var isLastPage: Bool {
        pageIndex >= pages.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            progressHeader
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

            pageView(pages[pageIndex])
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
            .padding(.bottom, 36)
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
                    .fill(index == pageIndex ? MetricTheme.warmEmber : Color.white.opacity(0.15))
                    .frame(width: index == pageIndex ? 28 : 8, height: 4)
                    .animation(.spring(response: 0.4), value: pageIndex)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let title = page.title {
                    Text(title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(MetricTheme.textPrimary)
                }

                Text(page.body)
                    .font(.title3.weight(.regular))
                    .foregroundStyle(MetricTheme.textSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                if !page.bulletItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(page.bulletItems, id: \.self) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Text("•")
                                    .foregroundStyle(MetricTheme.warmGlow)
                                Text(item)
                                    .font(.body)
                                    .foregroundStyle(MetricTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
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
