//
//  ThermometerSliderView.swift
//  Metricize
//

import SwiftUI

struct ThermometerSliderView: View {
    let celsius: Int
    var label: String?
    @Binding var selectedFahrenheit: Double
    let isEnabled: Bool
    var layout: ChallengeLayout = .stacked
    var compact: Bool = false
    var showsAccuracyToleranceNote: Bool = true
    var showsStepButtons: Bool = false

    @Environment(\.metricPalette) private var palette
    @Environment(AppSettingsStore.self) private var settings

    private let range = Double(TemperatureGameConstants.fahrenheitMin)...Double(TemperatureGameConstants.fahrenheitMax)

    private var guessHue: Color {
        MetricTheme.fahrenheitHue(selectedFahrenheit)
    }

    var body: some View {
        Group {
            switch layout {
            case .stacked:
                VStack(spacing: 28) {
                    prompt
                    sliderControls
                }
            case .sideBySide:
                sliderControls
            }
        }
        .padding(.horizontal, 8)
    }

    private var prompt: some View {
        TemperaturePromptView(
            value: celsius,
            unit: "°C",
            compact: compact
        )
    }

    private var sliderControls: some View {
        HStack(alignment: .center, spacing: compact ? 16 : 28) {
            if showsStepButtons {
                temperatureStepButton(delta: -1)
            }

            thermometerTrack

            if showsStepButtons {
                temperatureStepButton(delta: 1)
            }

            fahrenheitReadout
        }
        .frame(maxHeight: sliderMaxHeight)
    }

    private var sliderMaxHeight: CGFloat {
        if layout == .sideBySide {
            return compact ? 180 : 240
        }
        return compact ? 220 : 280
    }

    private var thermometerTrack: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let knobY = yPosition(for: selectedFahrenheit, in: height)
            let fillHeight = max(0, height - knobY - 36)

            ZStack {
                tickMarks(in: height)
                    .offset(x: 52)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 52)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.45), .white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 4)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.35, blue: 0.28),
                                Color(red: 0.98, green: 0.65, blue: 0.22),
                                Color(red: 0.55, green: 0.82, blue: 0.95),
                                Color(red: 0.28, green: 0.52, blue: 0.92),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.55)
                    .frame(width: 36)
                    .mask {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Rectangle().frame(height: fillHeight + 36)
                        }
                        .frame(width: 36, height: height - 24)
                    }
                    .offset(y: -6)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [guessHue, guessHue.opacity(0.6)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 32
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: guessHue.opacity(0.5), radius: 12)
                    .position(x: geometry.size.width / 2, y: height - 28)

                ZStack {
                    Circle()
                        .fill(guessHue.opacity(0.25))
                        .frame(width: 36, height: 36)
                        .blur(radius: 4)

                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Circle()
                                .strokeBorder(guessHue, lineWidth: 3)
                        }
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                }
                .position(x: geometry.size.width / 2, y: knobY)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard isEnabled else { return }
                            let bounds = TemperatureSliderGeometry.dragBounds(in: height)
                            let clampedY = min(max(value.location.y, bounds.lowerBound), bounds.upperBound)
                            selectedFahrenheit = TemperatureSliderGeometry.value(at: clampedY, in: range, height: height)
                        }
                )
                .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.78), value: selectedFahrenheit)
            }
        }
        .frame(width: 80)
    }

    private var fahrenheitReadout: some View {
        VStack(spacing: 12) {
            Text("Your guess")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(palette.textTertiary)

            VStack(spacing: 2) {
                Text("\(Int(selectedFahrenheit.rounded()))")
                    .font(.system(size: 52, weight: .thin, design: .rounded))
                    .foregroundStyle(guessHue)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text("°F")
                    .font(.title3.weight(.light))
                    .foregroundStyle(palette.textSecondary)
            }

            Text("±\(settings.accuracyToleranceDegrees)° counts")
                .font(.caption2)
                .foregroundStyle(palette.textTertiary)
                .multilineTextAlignment(.center)
                .opacity(showsAccuracyToleranceNote ? 1 : 0)
                .frame(height: showsAccuracyToleranceNote ? nil : 0)
                .clipped()
        }
        .frame(width: 110)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 16, padding: 12)
    }

    private func tickMarks(in height: CGFloat) -> some View {
        let ticks = [-10, 0, 32, 50, 68, 86, 110]
        let majorTicks: Set<Int> = [-10, 32, 68, 110]
        return ZStack(alignment: .topLeading) {
            ForEach(ticks, id: \.self) { tick in
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(majorTicks.contains(tick) ? palette.textTertiary : palette.progressTrack)
                        .frame(width: majorTicks.contains(tick) ? 14 : 7, height: 1)
                    Text("\(tick)°")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(palette.textTertiary)
                }
                .position(x: 30, y: yPosition(for: Double(tick), in: height))
            }
        }
    }

    private func yPosition(for fahrenheit: Double, in height: CGFloat) -> CGFloat {
        TemperatureSliderGeometry.yPosition(for: fahrenheit, in: range, height: height)
    }

    private func temperatureStepButton(delta: Int) -> some View {
        Button {
            let next = Int(selectedFahrenheit.rounded()) + delta
            guard range.contains(Double(next)) else { return }
            selectedFahrenheit = Double(next)
        } label: {
            Text(delta > 0 ? "+1" : "−1")
                .font(.headline.weight(.bold).monospacedDigit())
                .frame(width: compact ? 40 : 48, height: compact ? 40 : 48)
                .foregroundStyle(guessHue)
                .background {
                    Circle()
                        .fill(guessHue.opacity(0.14))
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
