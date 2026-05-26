//
//  AppIconView.swift
//  Metricize
//

import SwiftUI

/// Home-screen app icon artwork: person silhouette with metric thought bubbles.
struct AppIconView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                background(in: size)

                Group {
                    metricBubble("mm", tint: MetricTheme.coolFrost, textColor: MetricTheme.coolDeep)
                        .frame(width: size * 0.34, height: size * 0.25)
                        .position(x: size * 0.29, y: size * 0.27)

                    metricBubble("°C", tint: MetricTheme.warmGlow, textColor: Color(red: 0.45, green: 0.22, blue: 0.08))
                        .frame(width: size * 0.36, height: size * 0.27)
                        .position(x: size * 0.52, y: size * 0.23)

                    metricBubble("kg", tint: MetricTheme.coolFrost, textColor: MetricTheme.coolDeep)
                        .frame(width: size * 0.34, height: size * 0.25)
                        .position(x: size * 0.75, y: size * 0.30)

                    thoughtTrail(in: size)

                    personSilhouette(in: size)
                        .position(x: size * 0.5, y: size * 0.72)
                }
                .padding(size * 0.08)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func background(in size: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.14, blue: 0.28),
                    Color(red: 0.07, green: 0.09, blue: 0.16),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [MetricTheme.coolDeep.opacity(0.35), .clear],
                center: UnitPoint(x: 0.25, y: 0.2),
                startRadius: 0,
                endRadius: size * 0.55
            )

            RadialGradient(
                colors: [MetricTheme.warmEmber.opacity(0.22), .clear],
                center: UnitPoint(x: 0.78, y: 0.82),
                startRadius: 0,
                endRadius: size * 0.45
            )
        }
    }

    private func metricBubble(_ label: String, tint: Color, textColor: Color) -> some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(tint)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

                Text(label)
                    .font(.system(size: geo.size.height * 0.52, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(textColor)
            }
        }
    }

    private func thoughtTrail(in size: CGFloat) -> some View {
        Canvas { context, canvasSize in
            let head = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.61)
            let dots: [CGPoint] = [
                CGPoint(x: canvasSize.width * 0.46, y: canvasSize.height * 0.53),
                CGPoint(x: canvasSize.width * 0.41, y: canvasSize.height * 0.45),
                CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.37),
                CGPoint(x: canvasSize.width * 0.61, y: canvasSize.height * 0.34),
                CGPoint(x: canvasSize.width * 0.71, y: canvasSize.height * 0.36),
            ]

            var path = Path()
            path.move(to: head)
            for point in dots {
                path.addLine(to: point)
            }

            context.stroke(
                path,
                with: .color(.white.opacity(0.38)),
                style: StrokeStyle(lineWidth: size * 0.014, lineCap: .round, dash: [size * 0.022, size * 0.018])
            )

            for point in dots {
                let dot = CGRect(
                    x: point.x - size * 0.016,
                    y: point.y - size * 0.016,
                    width: size * 0.032,
                    height: size * 0.032
                )
                context.fill(Path(ellipseIn: dot), with: .color(.white.opacity(0.6)))
            }
        }
    }

    private func personSilhouette(in size: CGFloat) -> some View {
        PersonSilhouetteShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.98),
                        Color.white.opacity(0.82),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size * 0.54, height: size * 0.5)
            .shadow(color: .black.opacity(0.28), radius: size * 0.035, y: size * 0.025)
    }
}

private struct PersonSilhouetteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        let headCenter = CGPoint(x: w * 0.5, y: h * 0.34)
        let headRadius = w * 0.22
        path.addEllipse(in: CGRect(
            x: headCenter.x - headRadius,
            y: headCenter.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        ))

        // Shoulders only — wide bust, no torso below.
        path.move(to: CGPoint(x: w * 0.06, y: h * 0.9))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.94, y: h * 0.9),
            control: CGPoint(x: w * 0.5, y: h * 0.58)
        )
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.56))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.56),
            control: CGPoint(x: w * 0.5, y: h * 0.66)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    AppIconView()
        .frame(width: 256, height: 256)
        .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
}
