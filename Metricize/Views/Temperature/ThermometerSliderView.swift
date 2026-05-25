//
//  ThermometerSliderView.swift
//  Metricize
//

import SwiftUI

struct ThermometerSliderView: View {
    let celsius: Int
    @Binding var selectedFahrenheit: Double
    let isEnabled: Bool

    private let range = Double(TemperatureGameConstants.fahrenheitMin)...Double(TemperatureGameConstants.fahrenheitMax)

    private var guessHue: Color {
        MetricTheme.fahrenheitHue(selectedFahrenheit)
    }

    var body: some View {
        VStack(spacing: 28) {
            TemperaturePromptView(celsius: celsius, showUnitHint: false)

            Text("Drag the marker on the Fahrenheit scale")
                .font(.footnote.weight(.medium))
                .foregroundStyle(MetricTheme.textTertiary)

            HStack(alignment: .center, spacing: 28) {
                thermometerTrack
                fahrenheitReadout
            }
            .frame(maxHeight: 340)
        }
        .padding(.horizontal, 8)
    }

    private var thermometerTrack: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let knobY = yPosition(for: selectedFahrenheit, in: height)
            let fillHeight = max(0, height - knobY - 36)

            ZStack {
                // Scale ticks behind tube
                tickMarks(in: height)
                    .offset(x: 52)

                // Glass tube shell
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

                // Inner temperature gradient
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

                // Mercury bulb
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
                    .position(x: geometry.size.width / 2, y: height - 20)

                // Draggable marker
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
                            selectedFahrenheit = fahrenheit(for: clampedY, in: height)
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
                .foregroundStyle(MetricTheme.textTertiary)

            VStack(spacing: 2) {
                Text("\(Int(selectedFahrenheit.rounded()))")
                    .font(.system(size: 52, weight: .thin, design: .rounded))
                    .foregroundStyle(guessHue)
                    .contentTransition(.numericText())
                    .shadow(color: guessHue.opacity(0.3), radius: 12)

                Text("°F")
                    .font(.title3.weight(.light))
                    .foregroundStyle(MetricTheme.textSecondary)
            }

            Text("±\(TemperatureGameConstants.sliderToleranceFahrenheit)° counts")
                .font(.caption2)
                .foregroundStyle(MetricTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 110)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 16, padding: 12)
    }

    private func tickMarks(in height: CGFloat) -> some View {
        let ticks = [110, 86, 68, 50, 32, 14, 0, -15]
        let majorTicks: Set<Int> = [110, 68, 32, 0, -15]
        return ZStack(alignment: .topLeading) {
            ForEach(ticks, id: \.self) { tick in
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.white.opacity(majorTicks.contains(tick) ? 0.28 : 0.12))
                        .frame(width: majorTicks.contains(tick) ? 14 : 7, height: 1)
                    Text("\(tick)°")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(MetricTheme.textTertiary)
                }
                .position(x: 30, y: yPosition(for: Double(tick), in: height))
            }
        }
    }

    private func yPosition(for fahrenheit: Double, in height: CGFloat) -> CGFloat {
        let normalized = (fahrenheit - range.lowerBound) / (range.upperBound - range.lowerBound)
        return height - CGFloat(normalized) * (height - 48) - 24
    }

    private func fahrenheit(for y: CGFloat, in height: CGFloat) -> Double {
        let normalized = 1 - (y - 24) / (height - 48)
        let value = range.lowerBound + Double(normalized) * (range.upperBound - range.lowerBound)
        return min(max(value, range.lowerBound), range.upperBound)
    }
}

#Preview {
    @Previewable @State var value = 68.0
    ZStack {
        AmbientBackgroundView(celsius: 20).ignoresSafeArea()
        ThermometerSliderView(celsius: 20, selectedFahrenheit: $value, isEnabled: true)
    }
    .preferredColorScheme(.dark)
}
