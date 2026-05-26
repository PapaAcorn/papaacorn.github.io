//
//  HomeView.swift
//  Metricize
//

import SwiftUI

struct HomeView: View {
    @Environment(\.metricPalette) private var palette

    @State private var temperatureProgress = TemperatureProgressStore()
    @State private var unlockStore = ModuleUnlockStore()
    @State private var navigation = AppNavigationStore.shared
    @State private var openConversionCalculator = false

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
                        SettingsView(
                            unlockStore: unlockStore,
                            temperatureProgress: temperatureProgress
                        )
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
                        SettingsView(
                            unlockStore: unlockStore,
                            temperatureProgress: temperatureProgress
                        )
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }
            #endif
            .onAppear(perform: handlePendingDeepLink)
            .onChange(of: navigation.pendingDeepLink) { _, _ in
                handlePendingDeepLink()
            }
            .navigationDestination(isPresented: $openConversionCalculator) {
                ConversionCalculatorView()
            }
        }
    }

    private func handlePendingDeepLink() {
        if navigation.pendingDeepLink == .conversionCalculator {
            _ = navigation.consumePendingDeepLink()
            openConversionCalculator = true
        }
    }

    private var heroSection: some View {
        (
            Text("Metricize")
                .font(AppFont.sora(size: 38, weight: .bold))
                .foregroundStyle(palette.textPrimary)
            +
            Text("Me")
                .font(AppFont.sora(size: 42, weight: .heavy))
                .foregroundStyle(MetricTheme.warmEmber)
        )
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

            LazyVGrid(columns: tileColumns, alignment: .center, spacing: 20) {
                ForEach(ModuleTileItem.homeGrid) { tile in
                    moduleTile(for: tile)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                    .allowsHitTesting(false)
            }

        case .conversionCalculator:
            NavigationLink {
                ConversionCalculatorView()
            } label: {
                ModuleTileView(tile: tile, isLocked: false, progressCaption: nil)
            }
            .buttonStyle(.plain)

        case .comingSoon:
            ModuleTileView(tile: tile, isLocked: false, progressCaption: nil)
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
        case .conversionCalculator:
            ConversionCalculatorView()
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

    private var subtitle: String? {
        tile.subtitle
    }

    var body: some View {
        VStack(spacing: 10) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    GeometryReader { geometry in
                        let dimension = min(geometry.size.width, geometry.size.height)
                        ModuleTileIconView(kind: ModuleTileIconKind(tile: tile), size: dimension)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .opacity(isComingSoon ? 0.72 : 1)

            VStack(spacing: 3) {
                Text(tile.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isComingSoon ? palette.textSecondary : palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let progressCaption {
                    Text(progressCaption)
                        .font(.caption2)
                        .foregroundStyle(palette.textTertiary)
                        .multilineTextAlignment(.center)
                } else if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(palette.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            badgeOverlay
        }
    }

    @ViewBuilder
    private var badgeOverlay: some View {
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(palette.textTertiary)
                .padding(.top, 6)
                .padding(.trailing, 2)
        } else if isComingSoon {
            Text("Soon")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(palette.textTertiary)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Capsule().fill(palette.chipFill))
                .padding(.top, 6)
                .padding(.trailing, 2)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppSettingsStore())
        .environment(\.metricPalette, MetricPalette.dark)
}
