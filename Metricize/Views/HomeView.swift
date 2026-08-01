//
//  HomeView.swift
//  Metricize
//

import SwiftUI

struct LearningHomeView: View {
    @Environment(\.metricPalette) private var palette
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let unlockStore: ModuleUnlockStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore
    let onChangeMode: () -> Void

    private let tileColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    private var usesRegularTypography: Bool {
        horizontalSizeClass == .regular
    }

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
                ToolbarItem(placement: .topBarLeading) {
                    modeSwitcherButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsToolbarLink(
                        unlockStore: unlockStore,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    )
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    modeSwitcherButton
                }
                ToolbarItem(placement: .automatic) {
                    SettingsToolbarLink(
                        unlockStore: unlockStore,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    )
                }
            }
            #endif
        }
    }

    private var heroSection: some View {
        HStack(spacing: 0) {
            Text("Metricize")
                .font(AppFont.sora(size: 38, weight: .bold))
                .foregroundStyle(palette.textPrimary)
            Text("Me")
                .font(AppFont.sora(size: 42, weight: .heavy))
                .foregroundStyle(MetricTheme.warmEmber)
        }
        .padding(.top, 12)
    }

    private var howToUseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Start Here")

            moduleLink {
                HowToUseModuleCard(
                    isUnlocked: unlockStore.isUnlocked(.howToUse),
                    isComplete: unlockStore.isComplete(.howToUse),
                    usesRegularTypography: usesRegularTypography
                )
            }

            NavigationLink {
                MetricUnitsModuleView(
                    unlockStore: unlockStore,
                    progressStore: metricUnitsProgress,
                    temperatureProgress: temperatureProgress,
                    kitchenProgress: kitchenProgress,
                    roadProgress: roadProgress,
                    shopProgress: shopProgress,
                    hereToThereProgress: hereToThereProgress,
                    gymProgress: gymProgress
                )
            } label: {
                MetricUnitsPrimerCard(
                    isComplete: metricUnitsProgress.isModuleComplete,
                    progressCaption: metricUnitsProgressCaption,
                    usesRegularTypography: usesRegularTypography
                )
            }
            .buttonStyle(.plain)

            Divider()
                .overlay(palette.divider)
                .padding(.top, 4)
        }
    }

    private var moduleTileGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Modules")

            LazyVGrid(columns: tileColumns, alignment: .center, spacing: 20) {
                ForEach(ModuleTileItem.learningGrid) { tile in
                    moduleTile(for: tile)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
    }

    @ViewBuilder
    private func moduleTile(for tile: ModuleTileItem) -> some View {
        switch tile.productID {
        case .insideAndOut:
            if ModuleCatalog.isEntitled(.insideAndOut, unlockStore: unlockStore) {
                NavigationLink {
                    InsideAndOutModuleView(
                        unlockStore: unlockStore,
                        progressStore: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: insideAndOutProgressCaption,
                        usesRegularTypography: usesRegularTypography
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil, usesRegularTypography: usesRegularTypography)
                    .allowsHitTesting(false)
            }

        case .conversionCalculator:
            EmptyView()

        case .inTheKitchen:
            if ModuleCatalog.isEntitled(.inTheKitchen, unlockStore: unlockStore) {
                NavigationLink {
                    KitchenModuleView(
                        unlockStore: unlockStore,
                        progressStore: kitchenProgress,
                        temperatureProgress: temperatureProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: kitchenProgressCaption,
                        usesRegularTypography: usesRegularTypography
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil, usesRegularTypography: usesRegularTypography)
                    .allowsHitTesting(false)
            }

        case .onTheRoad:
            if ModuleCatalog.isEntitled(.onTheRoad, unlockStore: unlockStore) {
                NavigationLink {
                    RoadModuleView(
                        unlockStore: unlockStore,
                        progressStore: roadProgress,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: roadProgressCaption,
                        usesRegularTypography: usesRegularTypography
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil, usesRegularTypography: usesRegularTypography)
                    .allowsHitTesting(false)
            }

        case .hereToThere:
            if ModuleCatalog.isEntitled(.hereToThere, unlockStore: unlockStore) {
                NavigationLink {
                    HereToThereModuleView(
                        unlockStore: unlockStore,
                        progressStore: hereToThereProgress,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        gymProgress: gymProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: hereToThereProgressCaption,
                        usesRegularTypography: usesRegularTypography
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil, usesRegularTypography: usesRegularTypography)
                    .allowsHitTesting(false)
            }

        case .atTheGym:
            if ModuleCatalog.isEntitled(.atTheGym, unlockStore: unlockStore) {
                NavigationLink {
                    GymModuleView(
                        unlockStore: unlockStore,
                        progressStore: gymProgress,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: gymProgressCaption,
                        usesRegularTypography: usesRegularTypography
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil, usesRegularTypography: usesRegularTypography)
                    .allowsHitTesting(false)
            }

        case .atTheShop:
            if ModuleCatalog.isEntitled(.atTheShop, unlockStore: unlockStore) {
                NavigationLink {
                    ShopModuleView(
                        unlockStore: unlockStore,
                        progressStore: shopProgress,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    )
                } label: {
                    ModuleTileView(
                        tile: tile,
                        isLocked: false,
                        progressCaption: shopProgressCaption,
                        usesRegularTypography: usesRegularTypography
                    )
                }
                .buttonStyle(.plain)
            } else {
                ModuleTileView(tile: tile, isLocked: true, progressCaption: nil, usesRegularTypography: usesRegularTypography)
                    .allowsHitTesting(false)
            }
        }
    }

    private var metricUnitsProgressCaption: String? {
        if metricUnitsProgress.isModuleComplete {
            return "Complete"
        }
        guard !metricUnitsProgress.progressByCardID.isEmpty else { return nil }
        let roundLabel = MetricUnitsCurriculum.subRoundLabel(
            majorRoundIndex: 0,
            subRoundIndex: metricUnitsProgress.currentSubRoundIndex
        )
        let learned = metricUnitsProgress.learnedCountInCurrentSubRound()
        let total = metricUnitsProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    private var kitchenProgressCaption: String? {
        if kitchenProgress.hasPassedFinalExam {
            return "Complete"
        }
        guard !kitchenProgress.progressByCardID.isEmpty
            || kitchenProgress.finalExamSession != nil else { return nil }
        if kitchenProgress.isFinalExamRound(kitchenProgress.currentRoundIndex) {
            let answered = kitchenProgress.learnedCountInCurrentSubRound()
            let total = kitchenProgress.totalCountInCurrentSubRound()
            return "Final exam · \(answered)/\(total)"
        }
        let roundLabel = KitchenCurriculum.subRoundLabel(
            majorRoundIndex: kitchenProgress.currentRoundIndex,
            subRoundIndex: kitchenProgress.currentSubRoundIndex
        )
        let learned = kitchenProgress.learnedCountInCurrentSubRound()
        let total = kitchenProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    private var roadProgressCaption: String? {
        if roadProgress.hasPassedFinalExam {
            return "Complete"
        }
        guard !roadProgress.progressByCardID.isEmpty
            || roadProgress.finalExamSession != nil else { return nil }
        if roadProgress.isFinalExamRound(roadProgress.currentRoundIndex) {
            let answered = roadProgress.learnedCountInCurrentSubRound()
            let total = roadProgress.totalCountInCurrentSubRound()
            return "Final exam · \(answered)/\(total)"
        }
        let roundLabel = RoadCurriculum.subRoundLabel(
            majorRoundIndex: roadProgress.currentRoundIndex,
            subRoundIndex: roadProgress.currentSubRoundIndex
        )
        let learned = roadProgress.learnedCountInCurrentSubRound()
        let total = roadProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    private var shopProgressCaption: String? {
        if shopProgress.hasPassedFinalExam {
            return "Complete"
        }
        guard !shopProgress.progressByCardID.isEmpty
            || shopProgress.finalExamSession != nil else { return nil }
        if shopProgress.isFinalExamRound(shopProgress.currentRoundIndex) {
            let answered = shopProgress.learnedCountInCurrentSubRound()
            let total = shopProgress.totalCountInCurrentSubRound()
            return "Final exam · \(answered)/\(total)"
        }
        let roundLabel = ShopCurriculum.subRoundLabel(
            majorRoundIndex: shopProgress.currentRoundIndex,
            subRoundIndex: shopProgress.currentSubRoundIndex
        )
        let learned = shopProgress.learnedCountInCurrentSubRound()
        let total = shopProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    private var gymProgressCaption: String? {
        if gymProgress.hasPassedFinalExam {
            return "Complete"
        }
        guard !gymProgress.progressByCardID.isEmpty
            || gymProgress.finalExamSession != nil else { return nil }
        if gymProgress.isFinalExamRound(gymProgress.currentRoundIndex) {
            let answered = gymProgress.learnedCountInCurrentSubRound()
            let total = gymProgress.totalCountInCurrentSubRound()
            return "Final exam · \(answered)/\(total)"
        }
        let roundLabel = GymCurriculum.subRoundLabel(
            majorRoundIndex: gymProgress.currentRoundIndex,
            subRoundIndex: gymProgress.currentSubRoundIndex
        )
        let learned = gymProgress.learnedCountInCurrentSubRound()
        let total = gymProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    private var hereToThereProgressCaption: String? {
        if hereToThereProgress.hasPassedFinalExam {
            return "Complete"
        }
        guard !hereToThereProgress.progressByCardID.isEmpty
            || hereToThereProgress.finalExamSession != nil else { return nil }
        if hereToThereProgress.isFinalExamRound(hereToThereProgress.currentRoundIndex) {
            let answered = hereToThereProgress.learnedCountInCurrentSubRound()
            let total = hereToThereProgress.totalCountInCurrentSubRound()
            return "Final exam · \(answered)/\(total)"
        }
        let roundLabel = HereToThereCurriculum.subRoundLabel(
            majorRoundIndex: hereToThereProgress.currentRoundIndex,
            subRoundIndex: hereToThereProgress.currentSubRoundIndex
        )
        let learned = hereToThereProgress.learnedCountInCurrentSubRound()
        let total = hereToThereProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    private var insideAndOutProgressCaption: String? {
        if temperatureProgress.hasPassedFinalExam {
            return "Complete"
        }
        guard !temperatureProgress.progressByCardID.isEmpty
            || temperatureProgress.finalExamSession != nil else { return nil }
        if temperatureProgress.isFinalExamRound(temperatureProgress.currentRoundIndex) {
            let answered = temperatureProgress.learnedCountInCurrentSubRound()
            let total = temperatureProgress.totalCountInCurrentSubRound()
            return "Final exam · \(answered)/\(total)"
        }
        let roundLabel = TemperatureCurriculum.subRoundLabel(
            majorRoundIndex: temperatureProgress.currentRoundIndex,
            subRoundIndex: temperatureProgress.currentSubRoundIndex
        )
        let learned = temperatureProgress.learnedCountInCurrentSubRound()
        let total = temperatureProgress.totalCountInCurrentSubRound()
        return "Round \(roundLabel) · \(learned)/\(total)"
    }

    @ViewBuilder
    private func moduleLink<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if unlockStore.isUnlocked(.howToUse) {
            NavigationLink {
                OnboardingModuleView(
                    module: .howToUse,
                    pages: HowToUseContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Get Started"
                )
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

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(usesRegularTypography ? .footnote.weight(.semibold) : .caption.weight(.semibold))
            .tracking(usesRegularTypography ? 1.6 : 1.4)
            .foregroundStyle(palette.textTertiary)
    }

    private var modeSwitcherButton: some View {
        Button(action: onChangeMode) {
            Image(systemName: "chevron.left")
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.textSecondary)
        }
        .accessibilityLabel("Back")
    }
}

// MARK: - Metric Units primer row card

private struct MetricUnitsPrimerCard: View {
    @Environment(\.metricPalette) private var palette

    let isComplete: Bool
    let progressCaption: String?
    var usesRegularTypography: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: AppModule.metricUnitsIntro.systemImage)
                .font(usesRegularTypography ? .title : .title2)
                .foregroundStyle(MetricTheme.warmEmber)
                .frame(width: usesRegularTypography ? 56 : 48, height: usesRegularTypography ? 56 : 48)
                .background(Circle().fill(palette.chipFill))

            VStack(alignment: .leading, spacing: 4) {
                Text("Intro to the Metric Units")
                    .font(usesRegularTypography ? .title3.weight(.semibold) : .headline)
                    .foregroundStyle(palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Skip if you already know this.")
                    .font(usesRegularTypography ? .subheadline : .caption)
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let progressCaption {
                    Text(progressCaption)
                        .font(usesRegularTypography ? .caption.weight(.medium) : .caption2)
                        .foregroundStyle(palette.textTertiary)
                }
            }

            Spacer()

            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(usesRegularTypography ? .title3 : .body)
                    .foregroundStyle(MetricTheme.success)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(usesRegularTypography ? .subheadline.weight(.bold) : .caption.weight(.bold))
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

// MARK: - How to Use row card

private struct HowToUseModuleCard: View {
    @Environment(\.metricPalette) private var palette

    let isUnlocked: Bool
    let isComplete: Bool
    var usesRegularTypography: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: AppModule.howToUse.systemImage)
                .font(usesRegularTypography ? .title : .title2)
                .foregroundStyle(MetricTheme.coolFrost)
                .frame(width: usesRegularTypography ? 56 : 48, height: usesRegularTypography ? 56 : 48)
                .background(Circle().fill(palette.chipFill))

            VStack(alignment: .leading, spacing: 4) {
                Text("Read This to Unlock Learning Modules Below")
                    .font(usesRegularTypography ? .title3.weight(.semibold) : .headline)
                    .foregroundStyle(palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if !isUnlocked {
                Label("Locked", systemImage: "lock.fill")
                    .font(usesRegularTypography ? .caption.weight(.semibold) : .caption2.weight(.semibold))
                    .foregroundStyle(palette.textTertiary)
            } else if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(usesRegularTypography ? .title3 : .body)
                    .foregroundStyle(MetricTheme.success)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(usesRegularTypography ? .subheadline.weight(.bold) : .caption.weight(.bold))
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
    var usesRegularTypography: Bool = false

    private var titleFont: Font {
        usesRegularTypography ? .subheadline.weight(.semibold) : .caption.weight(.semibold)
    }

    private var detailFont: Font {
        usesRegularTypography ? .caption.weight(.medium) : .caption2
    }

    private var soonBadgeFont: Font {
        .system(size: usesRegularTypography ? 12 : 9, weight: .bold)
    }

    private var isComingSoon: Bool {
        tile.isComingSoon
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
                        let inset = min(geometry.size.width, geometry.size.height)
                        let dimension = inset * (isComingSoon ? 0.78 : 0.82)
                        ModuleTileIconView(kind: ModuleTileIconKind(tile: tile), size: dimension)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .padding(.top, isComingSoon ? 10 : 6)
                    .padding(.trailing, isComingSoon ? 8 : 4)
                }
                .opacity(isComingSoon ? 0.72 : 1)

            VStack(spacing: 3) {
                Text(tile.title)
                    .font(titleFont)
                    .foregroundStyle(isComingSoon ? palette.textSecondary : palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let progressCaption {
                    Text(progressCaption)
                        .font(detailFont)
                        .foregroundStyle(palette.textTertiary)
                        .multilineTextAlignment(.center)
                } else if let subtitle {
                    Text(subtitle)
                        .font(detailFont)
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
                .font(usesRegularTypography ? .caption.weight(.semibold) : .caption2.weight(.semibold))
                .foregroundStyle(palette.textTertiary)
                .padding(.top, 6)
                .padding(.trailing, 2)
        } else if isComingSoon {
            Text("Soon")
                .font(soonBadgeFont)
                .foregroundStyle(palette.textTertiary)
                .padding(.horizontal, usesRegularTypography ? 9 : 7)
                .padding(.vertical, usesRegularTypography ? 5 : 4)
                .background(Capsule().fill(palette.chipFill))
                .padding(.top, 6)
                .padding(.trailing, 2)
        }
    }
}

#Preview {
    LearningHomeView(
        unlockStore: ModuleUnlockStore(),
        temperatureProgress: TemperatureProgressStore(),
        kitchenProgress: KitchenProgressStore(),
        metricUnitsProgress: MetricUnitsProgressStore(),
        roadProgress: RoadProgressStore(),
        shopProgress: ShopProgressStore(),
        hereToThereProgress: HereToThereProgressStore(),
        gymProgress: GymProgressStore()
    ) {}
        .environment(AppSettingsStore())
        .environment(\.metricPalette, MetricPalette.dark)
}
