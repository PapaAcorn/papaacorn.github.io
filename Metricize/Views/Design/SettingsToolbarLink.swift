//
//  SettingsToolbarLink.swift
//  Metricize
//

import SwiftUI

struct SettingsToolbarLink: View {
    @Environment(\.metricPalette) private var palette

    let unlockStore: ModuleUnlockStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    var body: some View {
        NavigationLink {
            SettingsView(
                unlockStore: unlockStore,
                temperatureProgress: temperatureProgress,
                kitchenProgress: kitchenProgress,
                metricUnitsProgress: metricUnitsProgress,
                roadProgress: roadProgress,
                shopProgress: shopProgress,
                hereToThereProgress: hereToThereProgress,
                gymProgress: gymProgress
            )
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.textSecondary)
        }
        .accessibilityLabel("Settings")
    }
}
