import AppKit
import SwiftUI

@MainActor
enum AppIconExporter {
    static func exportPNG<Content: View>(content: Content, size: Int, to url: URL) throws {
        let view = content.frame(width: CGFloat(size), height: CGFloat(size))
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

    static func run(repoRoot: URL) throws {
        let layerOutputDirectory = repoRoot.appendingPathComponent("Metricize/AppIconLayers")
        let legacyIconSet = repoRoot.appendingPathComponent("Metricize/Assets.xcassets/AppIcon.appiconset")
        let exportSize = 1024
        let layout = AppIconArtworkLayout(canvasSize: CGFloat(exportSize))

        let legacyExports: [(String, AppIconLayer)] = [
            ("AppIcon-1024.png", .composite),
            ("AppIcon-512@2x.png", .composite),
            ("AppIcon-512.png", .composite),
            ("AppIcon-256@2x.png", .composite),
            ("AppIcon-256.png", .composite),
            ("AppIcon-128@2x.png", .composite),
            ("AppIcon-128.png", .composite),
            ("AppIcon-32@2x.png", .composite),
            ("AppIcon-32.png", .composite),
            ("AppIcon-16@2x.png", .composite),
            ("AppIcon-16.png", .composite),
        ]

        let legacySizes: [String: Int] = [
            "AppIcon-1024.png": 1024,
            "AppIcon-512@2x.png": 1024,
            "AppIcon-512.png": 512,
            "AppIcon-256@2x.png": 512,
            "AppIcon-256.png": 256,
            "AppIcon-128@2x.png": 256,
            "AppIcon-128.png": 128,
            "AppIcon-32@2x.png": 64,
            "AppIcon-32.png": 32,
            "AppIcon-16@2x.png": 32,
            "AppIcon-16.png": 16,
        ]

        try FileManager.default.createDirectory(at: layerOutputDirectory, withIntermediateDirectories: true)

        for layer in AppIconLayer.allCases {
            let url = layerOutputDirectory.appendingPathComponent(layer.exportFilename)
            try exportPNG(
                content: AppIconLayerView(layer: layer, layout: layout),
                size: exportSize,
                to: url
            )
            print("Wrote \(layer.exportFilename)")
        }

        for (filename, layer) in legacyExports {
            guard let size = legacySizes[filename] else { continue }
            let scaledLayout = AppIconArtworkLayout(canvasSize: CGFloat(size))
            let url = legacyIconSet.appendingPathComponent(filename)
            do {
                try exportPNG(
                    content: AppIconLayerView(layer: layer, layout: scaledLayout),
                    size: size,
                    to: url
                )
                print("Wrote legacy \(filename) (\(size)px)")
            } catch {
                fputs("Warning: Could not update \(filename) in AppIcon.appiconset: \(error.localizedDescription)\n", stderr)
            }
        }

        print("Done. Import the PNGs from Metricize/AppIconLayers/ into Icon Composer.")
    }
}

@main
enum ExportAppIconCLI {
    static func main() {
        let repoRoot: URL
        if CommandLine.arguments.count > 1 {
            repoRoot = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        } else {
            repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        }

        do {
            try AppIconExporter.run(repoRoot: repoRoot)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
    }
}
