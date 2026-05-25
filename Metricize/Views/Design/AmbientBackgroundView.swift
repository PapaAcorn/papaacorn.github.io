//
//  AmbientBackgroundView.swift
//  Metricize
//

import SwiftUI

struct AmbientBackgroundView: View {
    var celsius: Int?

    @State private var drift = false

    private var palette: (primary: Color, secondary: Color, glow: Color) {
        if let celsius {
            return MetricTheme.palette(forCelsius: celsius)
        }
        return (MetricTheme.coolDeep, MetricTheme.ink, MetricTheme.coolFrost)
    }

    var body: some View {
        ZStack {
            MetricTheme.ink

            // Soft color pools
            Circle()
                .fill(palette.primary.opacity(0.35))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: drift ? -40 : 40, y: drift ? -120 : -80)

            Circle()
                .fill(palette.glow.opacity(0.22))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: drift ? 80 : -60, y: drift ? 200 : 160)

            Circle()
                .fill(palette.secondary.opacity(0.18))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: drift ? 20 : -20, y: drift ? 40 : 80)

            // Subtle grain overlay
            LinearGradient(
                colors: [.white.opacity(0.03), .clear, .black.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: drift)
        .onAppear { drift = true }
        .animation(.easeInOut(duration: 0.8), value: celsius)
    }
}
