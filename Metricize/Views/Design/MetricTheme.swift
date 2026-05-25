//
//  MetricTheme.swift
//  Metricize
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

enum MetricTheme {
    // MARK: - Accent palette (shared across appearances)

    static let warmEmber = Color(red: 1.0, green: 0.52, blue: 0.28)
    static let warmGlow = Color(red: 1.0, green: 0.68, blue: 0.38)
    static let coolFrost = Color(red: 0.45, green: 0.78, blue: 0.98)
    static let coolDeep = Color(red: 0.22, green: 0.48, blue: 0.82)

    static let success = Color(red: 0.36, green: 0.84, blue: 0.58)
    static let successSoft = Color(red: 0.28, green: 0.72, blue: 0.48)

    // MARK: - Legacy dark surfaces (prefer metricPalette in views)

    static let ink = Color(red: 0.07, green: 0.08, blue: 0.12)
    static let inkElevated = Color(red: 0.11, green: 0.12, blue: 0.18)
    static let inkSoft = Color(red: 0.16, green: 0.17, blue: 0.24)

    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)

    // MARK: - Temperature ambience

    static func palette(forCelsius celsius: Int) -> (primary: Color, secondary: Color, glow: Color) {
        let normalized = min(max(Double(celsius + 26) / 69.0, 0), 1)
        let primary = Color(
            red: 0.25 + normalized * 0.75,
            green: 0.45 + normalized * 0.15,
            blue: 0.95 - normalized * 0.55
        )
        let secondary = Color(
            red: 0.15 + normalized * 0.65,
            green: 0.35 + normalized * 0.25,
            blue: 0.85 - normalized * 0.45
        )
        let glow = normalized > 0.55 ? warmGlow : coolFrost
        return (primary, secondary, glow)
    }

    static func fahrenheitHue(_ fahrenheit: Double) -> Color {
        let normalized = (fahrenheit - Double(TemperatureGameConstants.fahrenheitMin))
            / Double(TemperatureGameConstants.fahrenheitMax - TemperatureGameConstants.fahrenheitMin)
        return Color(hue: 0.58 - normalized * 0.48, saturation: 0.72, brightness: 0.92)
    }

    // MARK: - Gradients

    static let homeHero = LinearGradient(
        colors: [
            Color(red: 0.18, green: 0.22, blue: 0.42),
            Color(red: 0.10, green: 0.11, blue: 0.20),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func moduleGradient(tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint.opacity(0.55), tint.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let glassStroke = LinearGradient(
        colors: [.white.opacity(0.35), .white.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [warmEmber, Color(red: 0.95, green: 0.38, blue: 0.22)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct MetricPalette {
    let ink: Color
    let inkSoft: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let cardFill: Color
    let cardFillMuted: Color
    let chipFill: Color
    let chipStroke: Color
    let divider: Color
    let progressTrack: Color
    let heroHighlight: Color
    let glassStrokeTop: Color
    let glassStrokeBottom: Color
    let ambientDefaultSecondary: Color
    let grainTop: Color
    let grainBottom: Color

    var glassStroke: LinearGradient {
        LinearGradient(
            colors: [glassStrokeTop, glassStrokeBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let dark = MetricPalette(
        ink: Color(red: 0.07, green: 0.08, blue: 0.12),
        inkSoft: Color(red: 0.16, green: 0.17, blue: 0.24),
        textPrimary: Color.white.opacity(0.95),
        textSecondary: Color.white.opacity(0.62),
        textTertiary: Color.white.opacity(0.38),
        cardFill: Color(red: 0.16, green: 0.17, blue: 0.24).opacity(0.75),
        cardFillMuted: Color(red: 0.16, green: 0.17, blue: 0.24).opacity(0.45),
        chipFill: Color.white.opacity(0.08),
        chipStroke: Color.white.opacity(0.12),
        divider: Color.white.opacity(0.1),
        progressTrack: Color.white.opacity(0.08),
        heroHighlight: Color.white.opacity(0.62),
        glassStrokeTop: Color.white.opacity(0.35),
        glassStrokeBottom: Color.white.opacity(0.08),
        ambientDefaultSecondary: MetricTheme.ink,
        grainTop: Color.white.opacity(0.03),
        grainBottom: Color.black.opacity(0.15)
    )

    static let light = MetricPalette(
        ink: Color(red: 0.96, green: 0.97, blue: 0.99),
        inkSoft: Color.white,
        textPrimary: Color(red: 0.08, green: 0.10, blue: 0.16),
        textSecondary: Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.68),
        textTertiary: Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.42),
        cardFill: Color.white.opacity(0.88),
        cardFillMuted: Color.white.opacity(0.72),
        chipFill: Color.black.opacity(0.05),
        chipStroke: Color.black.opacity(0.08),
        divider: Color.black.opacity(0.08),
        progressTrack: Color.black.opacity(0.08),
        heroHighlight: Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.72),
        glassStrokeTop: Color.black.opacity(0.1),
        glassStrokeBottom: Color.black.opacity(0.04),
        ambientDefaultSecondary: Color(red: 0.92, green: 0.94, blue: 0.98),
        grainTop: Color.white.opacity(0.35),
        grainBottom: Color.black.opacity(0.04)
    )

    static func forScheme(_ scheme: ColorScheme) -> MetricPalette {
        scheme == .dark ? .dark : .light
    }
}

private struct MetricPaletteKey: EnvironmentKey {
    static let defaultValue = MetricPalette.dark
}

extension EnvironmentValues {
    var metricPalette: MetricPalette {
        get { self[MetricPaletteKey.self] }
        set { self[MetricPaletteKey.self] = newValue }
    }
}

// MARK: - View modifiers

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 0
    @Environment(\.metricPalette) private var palette

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(palette.cardFill.opacity(0.65))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(palette.glassStroke, lineWidth: 1)
                    }
            }
    }
}

struct MetricScreenBackground: ViewModifier {
    var celsius: Int?

    func body(content: Content) -> some View {
        content
            .background {
                AmbientBackgroundView(celsius: celsius)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    func metricHaptic(_ style: MetricHapticStyle) {
        #if os(iOS)
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        #endif
    }
}

enum MetricHapticStyle {
    case light, success, warning
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 0) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }

    func metricScreenBackground(celsius: Int? = nil) -> some View {
        modifier(MetricScreenBackground(celsius: celsius))
    }
}

// MARK: - Shared components

struct TemperaturePromptView: View {
    let value: Int
    let unit: String
    var caption: String?
    var hint: String?

    @Environment(\.metricPalette) private var palette

    private var paletteColors: (primary: Color, secondary: Color, glow: Color) {
        let celsius = unit == "°C" ? value : TemperatureConversion.celsius(fromFahrenheit: value)
        return MetricTheme.palette(forCelsius: celsius)
    }

    var body: some View {
        VStack(spacing: 10) {
            if let caption {
                Text("Hint: \(caption)")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 8)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [paletteColors.glow, paletteColors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())
                    .shadow(color: paletteColors.glow.opacity(0.35), radius: 16, y: 4)

                Text(unit)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                    .offset(y: -8)
            }

            if let hint {
                Text(hint)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textTertiary)
            }
        }
        .multilineTextAlignment(.center)
    }
}

enum AnswerFormatting {
    static func degreesPhrase(value: Int, unit: String) -> String {
        TemperatureFormatting.degreesPhrase(value: value, unit: unit)
    }
}

struct LearningStreakView: View {
    let consecutiveCorrect: Int
    let required: Int

    @Environment(\.metricPalette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<required, id: \.self) { index in
                Capsule()
                    .fill(
                        index < consecutiveCorrect
                            ? AnyShapeStyle(MetricTheme.success)
                            : AnyShapeStyle(palette.progressTrack)
                    )
                    .frame(width: index < consecutiveCorrect ? 22 : 10, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.72), value: consecutiveCorrect)
            }

            Text("to learn")
                .font(.caption.weight(.medium))
                .foregroundStyle(palette.textTertiary)
        }
    }
}

struct PrimaryActionButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    @Environment(\.metricPalette) private var palette

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background {
                    Capsule(style: .continuous)
                        .fill(isEnabled ? AnyShapeStyle(MetricTheme.primaryButton) : AnyShapeStyle(palette.chipFill))
                        .shadow(color: MetricTheme.warmEmber.opacity(isEnabled ? 0.45 : 0), radius: 16, y: 6)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}

struct RoundProgressHeader: View {
    let roundLabel: String
    let learned: Int
    let total: Int

    @Environment(\.metricPalette) private var palette

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(learned) / Double(total)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                Text(roundLabel)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)

                Spacer()

                VStack(spacing: 8) {
                    Text("Learned")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.6)
                        .foregroundStyle(palette.textTertiary)

                    ZStack {
                        Circle()
                            .stroke(palette.progressTrack, lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AngularGradient(
                                    colors: [MetricTheme.warmEmber, MetricTheme.warmGlow, MetricTheme.warmEmber],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.5), value: progress)

                        Text("\(learned)/\(total)")
                            .font(.caption2.weight(.bold).monospacedDigit())
                            .foregroundStyle(palette.textSecondary)
                    }
                    .frame(width: 52, height: 52)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(palette.progressTrack)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [MetricTheme.coolFrost, MetricTheme.warmEmber],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * progress))
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 0, padding: 0)
        .background(palette.ink.opacity(0.35))
    }
}

struct FeedbackToast: View {
    let text: String
    let icon: String
    let isSuccess: Bool

    @Environment(\.metricPalette) private var palette

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .symbolEffect(.bounce, value: text)
            Text(text)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(isSuccess ? MetricTheme.success : Color(red: 1.0, green: 0.55, blue: 0.45))
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .frame(maxWidth: 320)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(palette.cardFill.opacity(0.95))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            (isSuccess ? MetricTheme.success : Color(red: 1.0, green: 0.45, blue: 0.38)).opacity(0.45),
                            lineWidth: 1.5
                        )
                }
        }
        .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
    }
}
