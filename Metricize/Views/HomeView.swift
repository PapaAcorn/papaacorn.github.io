//
//  HomeView.swift
//  Metricize
//

import SwiftUI

struct HomeView: View {
    @State private var temperatureProgress = TemperatureProgressStore()
    @State private var unlockStore = ModuleUnlockStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    heroSection
                    modulesSection
                    comingSoonSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .metricScreenBackground()
            #if os(iOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metricize")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, MetricTheme.textSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Develop an intuitive feel for metric units — through repetition, not calculators.")
                .font(.body)
                .foregroundStyle(MetricTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }

    private var modulesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Modules")

            moduleLink(for: .howToUse) {
                ModuleCard(
                    module: .howToUse,
                    isUnlocked: unlockStore.isUnlocked(.howToUse),
                    isComplete: unlockStore.isComplete(.howToUse)
                )
            }

            moduleLink(for: .insideOutsideBasics) {
                ModuleCard(
                    module: .insideOutsideBasics,
                    isUnlocked: unlockStore.isUnlocked(.insideOutsideBasics),
                    isComplete: unlockStore.isComplete(.insideOutsideBasics)
                )
            }

            moduleLink(for: .learnInsideOutside) {
                LearnModuleCard(
                    progressStore: temperatureProgress,
                    isUnlocked: unlockStore.isUnlocked(.learnInsideOutside),
                    isComplete: false
                )
            }
        }
    }

    @ViewBuilder
    private func moduleLink<Content: View>(for module: AppModule, @ViewBuilder content: () -> Content) -> some View {
        if unlockStore.isUnlocked(module) {
            NavigationLink {
                destination(for: module)
            } label: {
                content()
            }
            .buttonStyle(.plain)
        } else {
            content()
                .opacity(0.45)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func destination(for module: AppModule) -> some View {
        switch module {
        case .howToUse:
            OnboardingModuleView(
                module: .howToUse,
                pages: HowToUseContent.pages,
                unlockStore: unlockStore,
                finalButtonTitle: "Get Started"
            )
        case .insideOutsideBasics:
            OnboardingModuleView(
                module: .insideOutsideBasics,
                pages: InsideOutsideBasicsContent.pages,
                unlockStore: unlockStore,
                finalButtonTitle: "Get Started"
            )
        case .learnInsideOutside:
            TemperatureGameView(progressStore: temperatureProgress)
        }
    }

    private var comingSoonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Coming Soon")

            ModulePreviewCard(
                title: "Distance",
                subtitle: "Kilometers, meters, and pace",
                systemImage: "ruler"
            )

            ModulePreviewCard(
                title: "Volume",
                subtitle: "Liters and milliliters",
                systemImage: "drop.fill"
            )
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.4)
            .foregroundStyle(MetricTheme.textTertiary)
    }
}

// MARK: - Module cards

private struct ModuleCard: View {
    let module: AppModule
    let isUnlocked: Bool
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: module.systemImage)
                .font(.title2)
                .foregroundStyle(MetricTheme.coolFrost)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.white.opacity(0.08)))

            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.headline)
                    .foregroundStyle(MetricTheme.textPrimary)
                Text(module.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(MetricTheme.textSecondary)
            }

            Spacer()

            if !isUnlocked {
                Label("Locked", systemImage: "lock.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MetricTheme.textTertiary)
            } else if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(MetricTheme.success)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MetricTheme.textTertiary)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(MetricTheme.inkSoft.opacity(0.75))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(MetricTheme.glassStroke, lineWidth: 1)
                }
        }
    }
}

private struct LearnModuleCard: View {
    let progressStore: TemperatureProgressStore
    let isUnlocked: Bool
    let isComplete: Bool

    private var learned: Int {
        progressStore.learnedConversionCount(in: progressStore.currentRoundIndex)
    }

    private var totalConversions: Int {
        progressStore.anchorCount(in: progressStore.currentRoundIndex)
    }

    private var hasProgress: Bool {
        !progressStore.progressByCardID.isEmpty
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [MetricTheme.warmGlow.opacity(0.5), MetricTheme.warmEmber.opacity(0.15)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 36
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: AppModule.learnInsideOutside.systemImage)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(MetricTheme.warmGlow)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(AppModule.learnInsideOutside.title)
                    .font(.headline)
                    .foregroundStyle(MetricTheme.textPrimary)

                if !isUnlocked {
                    Text("Complete Inside/Outside Basics first")
                        .font(.caption)
                        .foregroundStyle(MetricTheme.textTertiary)
                } else if hasProgress {
                    Text("Round \(progressStore.currentRoundIndex + 1) · \(learned)/\(totalConversions) conversions")
                        .font(.caption)
                        .foregroundStyle(MetricTheme.textSecondary)
                } else {
                    Text(AppModule.learnInsideOutside.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(MetricTheme.textSecondary)
                }
            }

            Spacer()

            if !isUnlocked {
                Label("Locked", systemImage: "lock.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MetricTheme.textTertiary)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MetricTheme.textTertiary)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            MetricTheme.warmEmber.opacity(isUnlocked ? 0.22 : 0.08),
                            MetricTheme.inkSoft.opacity(0.85),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(MetricTheme.glassStroke, lineWidth: 1)
                }
        }
    }
}

private struct ModulePreviewCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(MetricTheme.textSecondary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white.opacity(0.06)))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(MetricTheme.textSecondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(MetricTheme.textTertiary)
            }

            Spacer()

            Text("Soon")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(MetricTheme.textTertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.06)))
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(MetricTheme.inkSoft.opacity(0.45))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                }
        }
        .opacity(0.7)
    }
}

#Preview {
    HomeView()
}
