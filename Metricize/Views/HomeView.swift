//
//  HomeView.swift
//  Metricize
//

import SwiftUI

struct HomeView: View {
    @State private var temperatureProgress = TemperatureProgressStore()

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
            sectionLabel("Practice")

            NavigationLink {
                TemperatureGameView(progressStore: temperatureProgress)
            } label: {
                TemperatureModuleCard(progressStore: temperatureProgress)
            }
            .buttonStyle(.plain)
        }
    }

    private var comingSoonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Coming Soon")

            ModulePreviewCard(
                title: "Distance",
                subtitle: "Kilometers, meters, and pace",
                systemImage: "ruler",
                gradient: LinearGradient(
                    colors: [Color(red: 0.35, green: 0.55, blue: 0.95), MetricTheme.inkSoft],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            ModulePreviewCard(
                title: "Volume",
                subtitle: "Liters and milliliters",
                systemImage: "drop.fill",
                gradient: LinearGradient(
                    colors: [Color(red: 0.25, green: 0.75, blue: 0.85), MetricTheme.inkSoft],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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

private struct TemperatureModuleCard: View {
    let progressStore: TemperatureProgressStore

    private var round: TemperatureRound {
        TemperatureCurriculum.rounds[progressStore.currentRoundIndex]
    }

    private var learned: Int {
        progressStore.learnedCardCount(in: progressStore.currentRoundIndex)
    }

    private var hasProgress: Bool {
        !progressStore.progressByCardID.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
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
                        .frame(width: 56, height: 56)

                    Image(systemName: "thermometer.medium")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(MetricTheme.warmGlow)
                        .symbolRenderingMode(.hierarchical)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MetricTheme.textTertiary)
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Temperature")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(MetricTheme.textPrimary)

                Text("Celsius ↔ Fahrenheit intuition")
                    .font(.subheadline)
                    .foregroundStyle(MetricTheme.textSecondary)
            }

            if hasProgress {
                HStack(spacing: 10) {
                    Label(round.title, systemImage: "circle.grid.2x2")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MetricTheme.textSecondary)

                    Spacer()

                    Text("\(learned)/\(round.cards.count) learned")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(MetricTheme.warmGlow)
                }
                .padding(.top, 4)
            } else {
                Text("Start with environmental temperatures")
                    .font(.caption)
                    .foregroundStyle(MetricTheme.textTertiary)
            }
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            MetricTheme.warmEmber.opacity(0.22),
                            MetricTheme.inkSoft.opacity(0.85),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(MetricTheme.glassStroke, lineWidth: 1)
                }
                .shadow(color: MetricTheme.warmEmber.opacity(0.15), radius: 24, y: 12)
        }
    }
}

private struct ModulePreviewCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let gradient: LinearGradient

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
                .fill(gradient.opacity(0.35))
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
