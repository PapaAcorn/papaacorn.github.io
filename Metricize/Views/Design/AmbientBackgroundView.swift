//
//  AmbientBackgroundView.swift
//  Metricize
//

import SwiftUI

struct AmbientBackgroundView: View {
    var celsius: Int?

    @Environment(\.metricPalette) private var palette
    @State private var drift = false

    private var temperaturePalette: (primary: Color, secondary: Color, glow: Color) {
        if let celsius {
            return MetricTheme.palette(forCelsius: celsius)
        }
        return (MetricTheme.coolDeep, palette.ambientDefaultSecondary, MetricTheme.coolFrost)
    }

    var body: some View {
        ZStack {
            palette.ink

            ambientOrbs

            LinearGradient(
                colors: [palette.grainTop, .clear, palette.grainBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .onAppear {
            drift = true
        }
    }

    private var ambientOrbs: some View {
        ZStack {
            Circle()
                .fill(temperaturePalette.primary.opacity(0.35))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: drift ? -40 : 40, y: drift ? -120 : -80)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: drift)

            Circle()
                .fill(temperaturePalette.glow.opacity(0.22))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: drift ? 80 : -60, y: drift ? 200 : 160)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: drift)

            Circle()
                .fill(temperaturePalette.secondary.opacity(0.18))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: drift ? 20 : -20, y: drift ? 40 : 80)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: drift)
        }
        .animation(.easeInOut(duration: 0.8), value: celsius)
    }
}
