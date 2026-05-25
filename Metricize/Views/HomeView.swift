//
//  HomeView.swift
//  Metricize
//

import SwiftUI

struct HomeView: View {
    @Environment(\.metricPalette) private var palette

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }
            #endif
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metricize Me")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [palette.textPrimary, palette.heroHighlight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Develop an intuitive feel for metric units — through repetition, not calculators.")
                .font(.body)
                .foregroundStyle(palette.textSecondary)
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

            learnModuleRow
        }
    }

    @ViewBuilder
    private var learnModuleRow: some View {
        HStack(spacing: 12) {
            if unlockStore.isUnlocked(.learnInsideOutside) {
                NavigationLink {
                    TemperatureGameView(progressStore: temperatureProgress)
                } label: {
                    LearnModuleCard(
                        isUnlocked: true,
                        roundLabel: TemperatureCurriculum.subRoundLabel(
                            majorRoundIndex: temperatureProgress.currentRoundIndex,
                            subRoundIndex: temperatureProgress.currentSubRoundIndex
                        ),
                        learned: temperatureProgress.learnedCountInCurrentSubRound(),
                        total: temperatureProgress.totalCountInCurrentSubRound(),
                        hasProgress: !temperatureProgress.progressByCardID.isEmpty
                    )
                }
                .buttonStyle(.plain)

                Button {
                    temperatureProgress.resetProgress()
                } label: {
                    Text("Reset")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background {
                            Capsule(style: .continuous)
                                .fill(palette.chipFill)
                                .overlay {
                                    Capsule(style: .continuous)
                                        .strokeBorder(palette.chipStroke, lineWidth: 1)
                                }
                        }
                }
                .buttonStyle(.plain)
            } else {
                LearnModuleCard(
                    isUnlocked: false,
                    roundLabel: "1.1",
                    learned: 0,
                    total: 5,
                    hasProgress: false
                )
                .opacity(0.45)
                .allowsHitTesting(false)
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

            ForEach(ComingSoonModule.allCases) { module in
                ModulePreviewCard(
                    title: module.title,
                    subtitle: module.subtitle,
                    systemImage: module.systemImage
                )
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.4)
            .foregroundStyle(palette.textTertiary)
    }
}

// MARK: - Module cards

private struct ModuleCard: View {
    @Environment(\.metricPalette) private var palette

    let module: AppModule
    let isUnlocked: Bool
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: module.systemImage)
                .font(.title2)
                .foregroundStyle(MetricTheme.coolFrost)
                .frame(width: 48, height: 48)
                .background(Circle().fill(palette.chipFill))

            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
                Text(module.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(palette.textSecondary)
            }

            Spacer()

            if !isUnlocked {
                Label("Locked", systemImage: "lock.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(palette.textTertiary)
            } else if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(MetricTheme.success)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.textTertiary)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.cardFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(palette.glassStroke, lineWidth: 1)
                }
        }
    }
}

private struct LearnModuleCard: View {
    @Environment(\.metricPalette) private var palette

    let isUnlocked: Bool
    let roundLabel: String
    let learned: Int
    let total: Int
    let hasProgress: Bool

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
                    .foregroundStyle(palette.textPrimary)

                if !isUnlocked {
                    Text("Complete Inside/Outside Basics first")
                        .font(.caption)
                        .foregroundStyle(palette.textTertiary)
                } else if hasProgress {
                    Text("Round \(roundLabel) · \(learned)/\(total) learned")
                        .font(.caption)
                        .foregroundStyle(palette.textSecondary)
                } else {
                    Text(AppModule.learnInsideOutside.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(palette.textSecondary)
                }
            }

            Spacer()

            if !isUnlocked {
                Label("Locked", systemImage: "lock.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(palette.textTertiary)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.textTertiary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            MetricTheme.warmEmber.opacity(isUnlocked ? 0.22 : 0.08),
                            palette.cardFill,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(palette.glassStroke, lineWidth: 1)
                }
        }
    }
}

private struct ModulePreviewCard: View {
    @Environment(\.metricPalette) private var palette

    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(palette.textSecondary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(palette.chipFill))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(palette.textSecondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(palette.textTertiary)
            }

            Spacer()

            Text("Soon")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(palette.textTertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(palette.chipFill))
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.cardFillMuted)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(palette.chipStroke, lineWidth: 1)
                }
        }
        .opacity(0.85)
    }
}

#Preview {
    HomeView()
        .environment(AppSettingsStore())
        .modifier(MetricPaletteProvider())
}
