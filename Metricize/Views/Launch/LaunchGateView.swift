//
//  LaunchGateView.swift
//  Metricize
//

import SwiftUI

struct LaunchGateView: View {
    @Environment(\.metricPalette) private var palette

    let unlockStore: ModuleUnlockStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore
    let onSelect: (AppLaunchDestination) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                branding

                VStack(spacing: 14) {
                    Text("What would you like to do?")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(palette.textPrimary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
                    destinationButton(
                        title: "Conversion Calculator",
                        subtitle: "Convert and calculate in your units",
                        systemImage: "function",
                        tint: MetricTheme.coolFrost
                    ) {
                        onSelect(.conversion)
                    }

                    destinationButton(
                        title: "Learning",
                        subtitle: "Build intuition with guided modules",
                        systemImage: "book.pages.fill",
                        tint: MetricTheme.warmEmber
                    ) {
                        onSelect(.learning)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .metricScreenBackground()
            #if os(iOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
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

    private var branding: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("Metricize")
                    .font(AppFont.sora(size: 42, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                Text("Me")
                    .font(AppFont.sora(size: 46, weight: .heavy))
                    .foregroundStyle(MetricTheme.warmEmber)
            }

            VStack(spacing: 1) {
                Text("Imperial ↔ Metric")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(palette.textSecondary)

                Text("Metric ↔ Imperial")
                    .font(.subheadline.italic())
                    .foregroundStyle(palette.textTertiary.opacity(0.55))
            }
        }
    }

    private func destinationButton(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 52, height: 52)
                    .background {
                        Circle()
                            .fill(palette.chipFill)
                            .overlay {
                                Circle()
                                    .strokeBorder(palette.chipStroke, lineWidth: 1)
                            }
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(palette.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textTertiary)
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
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

#Preview {
    LaunchGateView(
        unlockStore: ModuleUnlockStore(),
        temperatureProgress: TemperatureProgressStore(),
        kitchenProgress: KitchenProgressStore(),
        metricUnitsProgress: MetricUnitsProgressStore(),
        roadProgress: RoadProgressStore(),
        shopProgress: ShopProgressStore(),
        hereToThereProgress: HereToThereProgressStore(),
        gymProgress: GymProgressStore()
    ) { _ in }
        .environment(AppSettingsStore())
        .environment(\.metricPalette, MetricPalette.dark)
}
