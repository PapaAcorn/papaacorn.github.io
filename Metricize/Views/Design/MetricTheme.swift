//
//  MetricTheme.swift
//  Metricize
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

enum MetricTheme {
    // MARK: - Palette

    static let ink = Color(red: 0.07, green: 0.08, blue: 0.12)
    static let inkElevated = Color(red: 0.11, green: 0.12, blue: 0.18)
    static let inkSoft = Color(red: 0.16, green: 0.17, blue: 0.24)

    static let warmEmber = Color(red: 1.0, green: 0.52, blue: 0.28)
    static let warmGlow = Color(red: 1.0, green: 0.68, blue: 0.38)
    static let coolFrost = Color(red: 0.45, green: 0.78, blue: 0.98)
    static let coolDeep = Color(red: 0.22, green: 0.48, blue: 0.82)

    static let success = Color(red: 0.36, green: 0.84, blue: 0.58)
    static let successSoft = Color(red: 0.28, green: 0.72, blue: 0.48)

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

// MARK: - View modifiers

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(MetricTheme.inkSoft.opacity(0.45))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(MetricTheme.glassStroke, lineWidth: 1)
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
            .preferredColorScheme(.dark)
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
    let celsius: Int
    var caption: String?
    var showUnitHint: Bool = true

    private var palette: (primary: Color, secondary: Color, glow: Color) {
        MetricTheme.palette(forCelsius: celsius)
    }

    var body: some View {
        VStack(spacing: 10) {
            if let caption {
                Text(caption.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(MetricTheme.textTertiary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(celsius)")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [palette.glow, palette.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())
                    .shadow(color: palette.glow.opacity(0.35), radius: 16, y: 4)

                Text("°C")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(MetricTheme.textSecondary)
                    .offset(y: -8)
            }

            if showUnitHint {
                Text("Match this in Fahrenheit")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MetricTheme.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }
}

struct LearningStreakView: View {
    let consecutiveCorrect: Int
    let required: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<required, id: \.self) { index in
                Capsule()
                    .fill(
                        index < consecutiveCorrect
                            ? AnyShapeStyle(MetricTheme.success)
                            : AnyShapeStyle(Color.white.opacity(0.12))
                    )
                    .frame(width: index < consecutiveCorrect ? 22 : 10, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.72), value: consecutiveCorrect)
            }

            Text("to learn")
                .font(.caption.weight(.medium))
                .foregroundStyle(MetricTheme.textTertiary)
        }
    }
}

struct PrimaryActionButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background {
                    Capsule(style: .continuous)
                        .fill(isEnabled ? AnyShapeStyle(MetricTheme.primaryButton) : AnyShapeStyle(Color.white.opacity(0.15)))
                        .shadow(color: MetricTheme.warmEmber.opacity(isEnabled ? 0.45 : 0), radius: 16, y: 6)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}

struct RoundProgressHeader: View {
    let roundTitle: String
    let learned: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(learned) / Double(total)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Round")
                        .font(.caption2.weight(.semibold))
                        .tracking(1)
                        .foregroundStyle(MetricTheme.textTertiary)
                    Text(roundTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MetricTheme.textPrimary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
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
                        .foregroundStyle(MetricTheme.textSecondary)
                }
                .frame(width: 44, height: 44)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
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
        .background(MetricTheme.ink.opacity(0.35))
    }
}

struct FeedbackToast: View {
    let text: String
    let icon: String
    let isSuccess: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .symbolEffect(.bounce, value: text)
            Text(text)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(isSuccess ? MetricTheme.success : Color(red: 1.0, green: 0.55, blue: 0.45))
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            (isSuccess ? MetricTheme.success : Color(red: 1.0, green: 0.45, blue: 0.38)).opacity(0.45),
                            lineWidth: 1
                        )
                }
        }
        .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
    }
}
