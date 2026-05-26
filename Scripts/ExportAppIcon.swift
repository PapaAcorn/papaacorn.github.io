#!/usr/bin/env swift

import AppKit
import SwiftUI

// MARK: - Icon artwork (mirrors AppIconView for standalone export)

private struct ExportAppIconView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
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
                        colors: [Color(red: 0.22, green: 0.48, blue: 0.82).opacity(0.35), .clear],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.52, blue: 0.28).opacity(0.22), .clear],
                        center: UnitPoint(x: 0.78, y: 0.82),
                        startRadius: 0,
                        endRadius: size * 0.45
                    )
                }

                Group {
                    bubble("mm", fill: Color(red: 0.45, green: 0.78, blue: 0.98), text: Color(red: 0.22, green: 0.48, blue: 0.82))
                        .frame(width: size * 0.34, height: size * 0.25)
                        .position(x: size * 0.29, y: size * 0.27)

                    bubble("°C", fill: Color(red: 1.0, green: 0.68, blue: 0.38), text: Color(red: 0.45, green: 0.22, blue: 0.08))
                        .frame(width: size * 0.36, height: size * 0.27)
                        .position(x: size * 0.52, y: size * 0.23)

                    bubble("kg", fill: Color(red: 0.45, green: 0.78, blue: 0.98), text: Color(red: 0.22, green: 0.48, blue: 0.82))
                        .frame(width: size * 0.34, height: size * 0.25)
                        .position(x: size * 0.75, y: size * 0.30)

                    thoughtTrail(size: size)

                    person(size: size)
                        .position(x: size * 0.5, y: size * 0.72)
                }
                .padding(size * 0.08)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func bubble(_ label: String, fill: Color, text: Color) -> some View {
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

    private func thoughtTrail(size: CGFloat) -> some View {
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
            for point in dots { path.addLine(to: point) }
            context.stroke(
                path,
                with: .color(.white.opacity(0.38)),
                style: StrokeStyle(lineWidth: size * 0.014, lineCap: .round, dash: [size * 0.022, size * 0.018])
            )
            for point in dots {
                let dot = CGRect(x: point.x - size * 0.016, y: point.y - size * 0.016, width: size * 0.032, height: size * 0.032)
                context.fill(Path(ellipseIn: dot), with: .color(.white.opacity(0.6)))
            }
        }
    }

    private func person(size: CGFloat) -> some View {
        PersonShape()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.98), Color.white.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size * 0.54, height: size * 0.5)
    }
}

private struct PersonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let headCenter = CGPoint(x: w * 0.5, y: h * 0.34)
        let headRadius = w * 0.22
        path.addEllipse(in: CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2))
        path.move(to: CGPoint(x: w * 0.06, y: h * 0.9))
        path.addQuadCurve(to: CGPoint(x: w * 0.94, y: h * 0.9), control: CGPoint(x: w * 0.5, y: h * 0.58))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.56))
        path.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.56), control: CGPoint(x: w * 0.5, y: h * 0.66))
        path.closeSubpath()
        return path
    }
}

@MainActor
func exportPNG(size: Int, to url: URL) throws {
    let view = ExportAppIconView().frame(width: CGFloat(size), height: CGFloat(size))
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1
    guard let image = renderer.nsImage else {
        throw NSError(domain: "ExportAppIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Render failed"])
    }
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ExportAppIcon", code: 2, userInfo: [NSLocalizedDescriptionKey: "PNG encode failed"])
    }
    try png.write(to: url)
}

let repoRoot = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let iconSet = repoRoot.appendingPathComponent("Metricize/Assets.xcassets/AppIcon.appiconset")

let exports: [(String, Int)] = [
    ("AppIcon-1024.png", 1024),
    ("AppIcon-512@2x.png", 1024),
    ("AppIcon-512.png", 512),
    ("AppIcon-256@2x.png", 512),
    ("AppIcon-256.png", 256),
    ("AppIcon-128@2x.png", 256),
    ("AppIcon-128.png", 128),
    ("AppIcon-32@2x.png", 64),
    ("AppIcon-32.png", 32),
    ("AppIcon-16@2x.png", 32),
    ("AppIcon-16.png", 16),
]

Task { @MainActor in
    do {
        for (filename, size) in exports {
            let url = iconSet.appendingPathComponent(filename)
            try exportPNG(size: size, to: url)
            print("Wrote \(filename) (\(size)px)")
        }
        print("Done.")
        exit(0)
    } catch {
        fputs("Error: \(error)\n", stderr)
        exit(1)
    }
}

RunLoop.main.run()
