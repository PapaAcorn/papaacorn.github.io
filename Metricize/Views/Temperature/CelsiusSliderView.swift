//
//  CelsiusSliderView.swift
//  Metricize
//

import SwiftUI

struct CelsiusSliderView: View {
    let fahrenheit: Int
    var label: String?
    @Binding var selectedCelsius: Double
    let isEnabled: Bool

    @Environment(\.metricPalette) private var palette

    private let range = Double(TemperatureGameConstants.celsiusMin)...Double(TemperatureGameConstants.celsiusMax)

    private var guessHue: Color {
        MetricTheme.palette(forCelsius: Int(selectedCelsius.rounded())).glow
    }

    var body: some View {
        VStack(spacing: 28) {
            TemperaturePromptView(
                value: fahrenheit,
                unit: "°F",
                caption: label,
                hint: "Drag the marker on the Celsius scale"
            )

            HStack(alignment: .center, spacing: 28) {
                celsiusTrack
                celsiusReadout
            }
            .frame(maxHeight: 280)
        }
        .padding(.horizontal, 8)
    }

    private var celsiusTrack: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let knobY = yPosition(for: selectedCelsius, in: height)
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
                            let clampedY = min(max(value.location.y, 12), height - 36)
                            selectedCelsius = celsius(for: clampedY, in: height)
                        }
                )
                .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.78), value: selectedCelsius)
            }
        }
        .frame(width: 80)
    }

    private var celsiusReadout: some View {
        VStack(spacing: 12) {
            Text("Your guess")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(palette.textTertiary)

            VStack(spacing: 2) {
                Text("\(Int(selectedCelsius.rounded()))")
                    .font(.system(size: 52, weight: .thin, design: .rounded))
                    .foregroundStyle(guessHue)
                    .contentTransition(.numericText())

                Text("°C")
                    .font(.title3.weight(.light))
                    .foregroundStyle(palette.textSecondary)
            }

            Text("±\(TemperatureGameConstants.toleranceDegrees)° counts")
                .font(.caption2)
                .foregroundStyle(palette.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 110)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 16, padding: 12)
    }

    private func tickMarks(in height: CGFloat) -> some View {
        let ticks = [43, 30, 20, 10, 0, -10, -23]
        let majorTicks: Set<Int> = [43, 20, 0, -23]
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

    private func yPosition(for celsius: Double, in height: CGFloat) -> CGFloat {
        let normalized = (celsius - range.lowerBound) / (range.upperBound - range.lowerBound)
        return height - CGFloat(normalized) * (height - 48) - 24
    }

    private func celsius(for y: CGFloat, in height: CGFloat) -> Double {
        let normalized = 1 - (y - 24) / (height - 48)
        let value = range.lowerBound + Double(normalized) * (range.upperBound - range.lowerBound)
        return min(max(value, range.lowerBound), range.upperBound)
    }
}
