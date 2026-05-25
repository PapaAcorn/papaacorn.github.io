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

    @State private var showResetAllConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                appearanceSection
                learningSection
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
                unlockStore.resetAllProgress(temperatureStore: temperatureProgress)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears learning progress and requires viewing each module's introductory pages again before continuing.")
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

    private var learningSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Learning")

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Times correct to learn")
                        .font(.body.weight(.medium))
                        .foregroundStyle(palette.textPrimary)
                    Text("How many consecutive correct answers mark a temperature as learned.")
                        .font(.caption)
                        .foregroundStyle(palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 16) {
                    Button {
                        if settings.requiredConsecutiveCorrect > 1 {
                            settings.requiredConsecutiveCorrect -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                settings.requiredConsecutiveCorrect > 1
                                    ? MetricTheme.warmEmber
                                    : palette.textTertiary
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(settings.requiredConsecutiveCorrect <= 1)

                    Text("\(settings.requiredConsecutiveCorrect)")
                        .font(.title2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(palette.textPrimary)
                        .frame(minWidth: 32)

                    Button {
                        if settings.requiredConsecutiveCorrect < 5 {
                            settings.requiredConsecutiveCorrect += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                settings.requiredConsecutiveCorrect < 5
                                    ? MetricTheme.warmEmber
                                    : palette.textTertiary
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(settings.requiredConsecutiveCorrect >= 5)

                    Spacer()

                    Text("1–5")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(palette.textTertiary)
                }
            }
            .padding(20)
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
                        Text("Clears all module progress and intro completion.")
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

#Preview {
    NavigationStack {
        SettingsView(
            unlockStore: ModuleUnlockStore(),
            temperatureProgress: TemperatureProgressStore()
        )
    }
}
