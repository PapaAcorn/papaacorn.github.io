//
//  AppIconArtwork.swift
//  Metricize
//
//  Layered app icon artwork for Liquid Glass / Icon Composer export.
//  Keep layers free of shadows, blurs, and baked highlights — Icon Composer applies those.
//

import SwiftUI

enum AppIconPalette {
    static let backgroundTop = Color(red: 0.1, green: 0.14, blue: 0.28)
    static let backgroundBottom = Color(red: 0.07, green: 0.09, blue: 0.16)
    static let coolFrost = Color(red: 0.45, green: 0.78, blue: 0.98)
    static let coolDeep = Color(red: 0.22, green: 0.48, blue: 0.82)
    static let warmGlow = Color(red: 1.0, green: 0.68, blue: 0.38)
    static let warmText = Color(red: 0.45, green: 0.22, blue: 0.08)
}

enum AppIconLayer: String, CaseIterable {
    case background
    case bubbles
    case trail
    case person
    case composite

    var exportFilename: String {
        switch self {
        case .background: "AppIcon-background.png"
        case .bubbles: "AppIcon-bubbles.png"
        case .trail: "AppIcon-trail.png"
        case .person: "AppIcon-person.png"
        case .composite: "AppIcon-composite-preview.png"
        }
    }
}

struct AppIconArtworkLayout {
    let canvasSize: CGFloat
    let insetRatio: CGFloat = 0.08

    var artSize: CGFloat {
        canvasSize * (1 - (insetRatio * 2))
    }
}

struct AppIconBackgroundLayer: View {
    let layout: AppIconArtworkLayout

    var body: some View {
        LinearGradient(
            colors: [AppIconPalette.backgroundTop, AppIconPalette.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: layout.canvasSize, height: layout.canvasSize)
    }
}

struct AppIconBubblesLayer: View {
    let layout: AppIconArtworkLayout

    var body: some View {
        let size = layout.artSize

        ZStack {
            metricBubble("mm", fill: AppIconPalette.coolFrost, text: AppIconPalette.coolDeep)
                .frame(width: size * 0.36, height: size * 0.27)
                .position(x: size * 0.24, y: size * 0.26)

            metricBubble("°C", fill: AppIconPalette.warmGlow, text: AppIconPalette.warmText)
                .frame(width: size * 0.38, height: size * 0.29)
                .position(x: size * 0.5, y: size * 0.22)

            metricBubble("kg", fill: AppIconPalette.coolFrost, text: AppIconPalette.coolDeep)
                .frame(width: size * 0.36, height: size * 0.27)
                .position(x: size * 0.76, y: size * 0.29)
        }
        .frame(width: size, height: size)
        .frame(width: layout.canvasSize, height: layout.canvasSize)
    }

    private func metricBubble(_ label: String, fill: Color, text: Color) -> some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(fill)

                Text(label)
                    .font(.system(size: geo.size.height * 0.52, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(text)
            }
        }
    }
}

struct AppIconTrailLayer: View {
    let layout: AppIconArtworkLayout

    var body: some View {
        let size = layout.artSize

        Canvas { context, canvasSize in
            let head = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.61)
            let dots: [CGPoint] = [
                CGPoint(x: canvasSize.width * 0.44, y: canvasSize.height * 0.52),
                CGPoint(x: canvasSize.width * 0.38, y: canvasSize.height * 0.44),
                CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.36),
                CGPoint(x: canvasSize.width * 0.62, y: canvasSize.height * 0.32),
                CGPoint(x: canvasSize.width * 0.72, y: canvasSize.height * 0.34),
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
        .frame(width: size, height: size)
        .frame(width: layout.canvasSize, height: layout.canvasSize)
    }
}

struct AppIconPersonLayer: View {
    let layout: AppIconArtworkLayout

    var body: some View {
        let size = layout.artSize

        AppIconPersonShape()
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
            .position(x: size * 0.5, y: size * 0.71)
            .frame(width: layout.canvasSize, height: layout.canvasSize)
    }
}

struct AppIconCompositeLayer: View {
    let layout: AppIconArtworkLayout

    var body: some View {
        ZStack {
            AppIconBackgroundLayer(layout: layout)
            AppIconBubblesLayer(layout: layout)
            AppIconTrailLayer(layout: layout)
            AppIconPersonLayer(layout: layout)
        }
        .frame(width: layout.canvasSize, height: layout.canvasSize)
    }
}

struct AppIconLayerView: View {
    let layer: AppIconLayer
    let layout: AppIconArtworkLayout

    var body: some View {
        switch layer {
        case .background:
            AppIconBackgroundLayer(layout: layout)
        case .bubbles:
            AppIconBubblesLayer(layout: layout)
        case .trail:
            AppIconTrailLayer(layout: layout)
        case .person:
            AppIconPersonLayer(layout: layout)
        case .composite:
            AppIconCompositeLayer(layout: layout)
        }
    }
}

struct AppIconPersonShape: Shape {
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
