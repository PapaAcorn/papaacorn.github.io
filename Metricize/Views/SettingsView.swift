//
//  SettingsView.swift
//  Metricize
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Environment(\.metricPalette) private var palette

    let unlockStore: ModuleUnlockStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    @State private var showResetAllConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                appearanceSection
                learningSettingsSection
                progressSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .metricScreenBackground()
        .confirmationDialog(
            "Reset all progress?",
            isPresented: $showResetAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset All Progress", role: .destructive) {
                showResetAllConfirmation = false
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(250))
                    unlockStore.resetAllProgress(
                        temperatureStore: temperatureProgress,
                        kitchenStore: kitchenProgress,
                        shopStore: shopProgress,
                        metricUnitsStore: metricUnitsProgress,
                        roadStore: roadProgress,
                        hereToThereStore: hereToThereProgress,
                        gymStore: gymProgress
                    )
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears learning progress and introductory pages. You will see those again the next time you open each learning module.")
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Appearance")

            VStack(spacing: 0) {
                ForEach(AppAppearanceMode.allCases) { mode in
                    Button {
                        settings.appearanceMode = mode
                    } label: {
                        HStack {
                            Text(mode.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(palette.textPrimary)

                            Spacer()

                            if settings.appearanceMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(MetricTheme.warmEmber)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if mode != AppAppearanceMode.allCases.last {
                        Divider()
                            .overlay(palette.divider)
                            .padding(.leading, 20)
                    }
                }
            }
            .background(settingsCardBackground)
        }
    }

    private var learningSettingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Learning Settings")

            VStack(spacing: 0) {
                SettingsStepperRow(
                    title: "Repetition Threshold",
                    subtitle: "Number of times you must be \"right\" for an item to be considered learned:",
                    value: settings.requiredConsecutiveCorrect,
                    range: 1...5,
                    onDecrement: {
                        settings.setRequiredConsecutiveCorrect(settings.requiredConsecutiveCorrect - 1)
                    },
                    onIncrement: {
                        settings.setRequiredConsecutiveCorrect(settings.requiredConsecutiveCorrect + 1)
                    }
                )

                Divider()
                    .overlay(palette.divider)
                    .padding(.leading, 20)

                SettingsStepperRow(
                    title: "Inside & Out - Accuracy Requirement",
                    subtitle: "How accurate is close enough?",
                    value: settings.accuracyToleranceDegrees,
                    range: 0...5,
                    onDecrement: {
                        settings.setAccuracyToleranceDegrees(settings.accuracyToleranceDegrees - 1)
                    },
                    onIncrement: {
                        settings.setAccuracyToleranceDegrees(settings.accuracyToleranceDegrees + 1)
                    }
                )
            }
            .background(settingsCardBackground)
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Progress")

            Button {
                showResetAllConfirmation = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reset All Progress")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color(red: 1.0, green: 0.45, blue: 0.38))
                        Text("Clears module progress and intro completion.")
                            .font(.caption)
                            .foregroundStyle(palette.textSecondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "arrow.counterclockwise")
                        .foregroundStyle(Color(red: 1.0, green: 0.45, blue: 0.38))
                }
                .padding(20)
                .background(settingsCardBackground)
            }
            .buttonStyle(.plain)
        }
    }

    private var settingsCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(palette.cardFill)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(palette.glassStroke, lineWidth: 1)
            }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.4)
            .foregroundStyle(palette.textTertiary)
    }
}

private struct SettingsStepperRow: View {
    @Environment(\.metricPalette) private var palette

    let title: String
    let subtitle: String
    let value: Int
    let range: ClosedRange<Int>
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 16) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            value > range.lowerBound
                                ? MetricTheme.warmEmber
                                : palette.textTertiary
                        )
                }
                .buttonStyle(.plain)
                .disabled(value <= range.lowerBound)

                Text("\(value)")
                    .font(.title2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(palette.textPrimary)
                    .frame(minWidth: 32)

                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            value < range.upperBound
                                ? MetricTheme.warmEmber
                                : palette.textTertiary
                        )
                }
                .buttonStyle(.plain)
                .disabled(value >= range.upperBound)

                Spacer()

                Text("\(range.lowerBound)–\(range.upperBound)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(palette.textTertiary)
            }
        }
        .padding(20)
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            unlockStore: ModuleUnlockStore(),
            temperatureProgress: TemperatureProgressStore(),
            kitchenProgress: KitchenProgressStore(),
            metricUnitsProgress: MetricUnitsProgressStore(),
            roadProgress: RoadProgressStore(),
            shopProgress: ShopProgressStore(),
            hereToThereProgress: HereToThereProgressStore(),
            gymProgress: GymProgressStore()
        )
    }
    .environment(AppSettingsStore())
}
