//
//  HomeView.swift
//  Metricize
//

import SwiftUI

struct HomeView: View {
    @Environment(\.metricPalette) private var palette

    @State private var temperatureProgress = TemperatureProgressStore()
    @State private var unlockStore = ModuleUnlockStore()

    private let tileColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    heroSection
                    howToUseSection
                    moduleTileGrid
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

    private var howToUseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Start Here")

            moduleLink(for: .howToUse) {
                HowToUseModuleCard(
                    isUnlocked: unlockStore.isUnlocked(.howToUse),
                    isComplete: unlockStore.isComplete(.howToUse)
                )
            }

            Divider()
                .overlay(palette.divider)
                .padding(.top, 4)
        }
    }

    private var moduleTileGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Modules")

            LazyVGrid(columns: tileColumns, spacing: 20) {
                ForEach(ModuleTileItem.homeGrid) { tile in
                    moduleTile(for: tile)
                }
            }
        }
    }

    @ViewBuilder
    private func moduleTile(for tile: ModuleTileItem) -> some View {
        switch tile {
        case .insideAndOut:
            if unlockStore.isUnlocked(.insideAndOut) {
                NavigationLink {
                    InsideAndOutModuleView(
                        unlockStore: unlockStore,
                        progressStore: temperatureProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: insideAndOutProgressCaption
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil)
                    .opacity(0.45)
                    .allowsHitTesting(false)
            }

        case .comingSoon:
            ModuleTileView(tile: tile, isLocked: false, progressCaption: nil)
                .opacity(0.72)
                .allowsHitTesting(false)
        }
    }

    private var insideAndOutProgressCaption: String? {
        guard !temperatureProgress.progressByCardID.isEmpty else { return nil }
        let roundLabel = TemperatureCurriculum.subRoundLabel(
            majorRoundIndex: temperatureProgress.currentRoundIndex,
            subRoundIndex: temperatureProgress.currentSubRoundIndex
        )
        let learned = temperatureProgress.learnedCountInCurrentSubRound()
        let total = temperatureProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
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
        case .insideAndOut:
            InsideAndOutModuleView(
                unlockStore: unlockStore,
                progressStore: temperatureProgress
            )
        case .insideOutsideBasics, .learnInsideOutside:
            InsideAndOutModuleView(
                unlockStore: unlockStore,
                progressStore: temperatureProgress
            )
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.4)
            .foregroundStyle(palette.textTertiary)
    }
}

// MARK: - How to Use row card

private struct HowToUseModuleCard: View {
    @Environment(\.metricPalette) private var palette

    let isUnlocked: Bool
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: AppModule.howToUse.systemImage)
                .font(.title2)
                .foregroundStyle(MetricTheme.coolFrost)
                .frame(width: 48, height: 48)
                .background(Circle().fill(palette.chipFill))

            VStack(alignment: .leading, spacing: 4) {
                Text(AppModule.howToUse.title)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
                Text(AppModule.howToUse.subtitle)
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

// MARK: - Square module tiles

private struct ModuleTileView: View {
    @Environment(\.metricPalette) private var palette

    let tile: ModuleTileItem
    let isLocked: Bool
    let progressCaption: String?

    private var isComingSoon: Bool {
        if case .comingSoon = tile { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(tileBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(tileBorder, lineWidth: 1)
                    }
                    .overlay {
                        ModuleTileIconView(kind: ModuleTileIconKind(tile: tile), size: 44)
                    }
                    .aspectRatio(1, contentMode: .fit)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(palette.textTertiary)
                        .padding(8)
                } else if isComingSoon {
                    Text("Soon")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(palette.textTertiary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(palette.chipFill))
                        .padding(8)
                }
            }

            VStack(spacing: 3) {
                Text(tile.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isComingSoon || isLocked ? palette.textSecondary : palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let progressCaption {
                    Text(progressCaption)
                        .font(.caption2)
                        .foregroundStyle(palette.textTertiary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var tileBackground: AnyShapeStyle {
        switch tile {
        case .insideAndOut:
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        MetricTheme.coolFrost.opacity(isLocked ? 0.08 : 0.18),
                        MetricTheme.warmEmber.opacity(isLocked ? 0.06 : 0.14),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .comingSoon:
            AnyShapeStyle(palette.cardFillMuted)
        }
    }

    private var tileBorder: AnyShapeStyle {
        switch tile {
        case .insideAndOut:
            AnyShapeStyle(palette.glassStroke)
        case .comingSoon:
            AnyShapeStyle(palette.chipStroke)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppSettingsStore())
        .environment(\.metricPalette, MetricPalette.dark)
}
