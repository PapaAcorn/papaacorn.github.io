//
//  ModuleTileIcons.swift
//  Metricize
//

import SwiftUI

enum ModuleTileIconKind {
    case insideAndOut
    case kitchen
    case gym
    case onTheRoad
    case hereToThere
    case calculator

    init(tile: ModuleTileItem) {
        switch tile {
        case .insideAndOut:
            self = .insideAndOut
        case .comingSoon(let module):
            switch module {
            case .inTheKitchen: self = .kitchen
            case .atTheGym: self = .gym
            case .onTheRoad: self = .onTheRoad
            case .hereToThere: self = .hereToThere
            case .conversionCalculator: self = .calculator
            }
        }
    }
}

struct ModuleTileIconView: View {
    let kind: ModuleTileIconKind
    var size: CGFloat = 44

    var body: some View {
        switch kind {
        case .insideAndOut:
            InsideAndOutIcon(size: size)
        case .kitchen:
            KitchenCakeIcon(size: size)
        case .gym:
            DumbbellIcon(size: size)
        case .onTheRoad:
            SpeedometerIcon(size: size)
        case .hereToThere:
            RulerIcon(size: size)
        case .calculator:
            CalculatorIcon(size: size)
        }
    }
}

// MARK: - Inside & Out (half snowflake / half sun)

private struct InsideAndOutIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Image(systemName: "snowflake")
                    .font(.system(size: size * 0.42, weight: .light))
                    .foregroundStyle(MetricTheme.coolFrost)
                    .frame(width: size * 0.5, height: size)
                    .clipped()

                Image(systemName: "sun.max.fill")
                    .font(.system(size: size * 0.38, weight: .light))
                    .foregroundStyle(MetricTheme.warmGlow)
                    .frame(width: size * 0.5, height: size)
                    .clipped()
            }

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: size * 0.7)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Kitchen cake

private struct KitchenCakeIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(MetricTheme.warmGlow.opacity(0.85))
                .frame(width: size * 0.72, height: size * 0.22)
                .offset(y: -size * 0.02)

            RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
                .fill(MetricTheme.warmEmber.opacity(0.9))
                .frame(width: size * 0.58, height: size * 0.18)

            Capsule()
                .fill(MetricTheme.warmGlow)
                .frame(width: size * 0.06, height: size * 0.14)
                .offset(y: -size * 0.28)

            Circle()
                .fill(MetricTheme.warmEmber)
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(y: -size * 0.38)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Dumbbell

private struct DumbbellIcon: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: size * 0.06) {
            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(MetricTheme.textSecondary.opacity(0.9))
                .frame(width: size * 0.16, height: size * 0.44)

            Capsule()
                .fill(MetricTheme.textSecondary.opacity(0.75))
                .frame(width: size * 0.36, height: size * 0.08)

            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(MetricTheme.textSecondary.opacity(0.9))
                .frame(width: size * 0.16, height: size * 0.44)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Speedometer

private struct SpeedometerIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(MetricTheme.coolFrost.opacity(0.5), lineWidth: size * 0.06)
                .rotationEffect(.degrees(90))
                .frame(width: size * 0.72, height: size * 0.72)

            Circle()
                .trim(from: 0.15, to: 0.55)
                .stroke(MetricTheme.warmEmber, lineWidth: size * 0.06)
                .rotationEffect(.degrees(90))
                .frame(width: size * 0.72, height: size * 0.72)

            Capsule()
                .fill(MetricTheme.textPrimary.opacity(0.85))
                .frame(width: size * 0.06, height: size * 0.28)
                .offset(y: -size * 0.1)
                .rotationEffect(.degrees(-35))

            Circle()
                .fill(MetricTheme.textPrimary.opacity(0.85))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(y: size * 0.08)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Ruler

private struct RulerIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(MetricTheme.coolFrost.opacity(0.35))
                .frame(width: size * 0.82, height: size * 0.24)

            HStack(spacing: size * 0.07) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(MetricTheme.coolDeep.opacity(0.85))
                        .frame(
                            width: size * 0.025,
                            height: index.isMultiple(of: 2) ? size * 0.14 : size * 0.08
                        )
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Calculator

private struct CalculatorIcon: View {
    let size: CGFloat

    var body: some View {
        VStack(spacing: size * 0.05) {
            RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
                .fill(MetricTheme.coolFrost.opacity(0.35))
                .frame(width: size * 0.62, height: size * 0.14)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(size * 0.12), spacing: size * 0.05), count: 3), spacing: size * 0.05) {
                ForEach(0..<6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: size * 0.025, style: .continuous)
                        .fill(MetricTheme.textSecondary.opacity(0.55))
                        .frame(width: size * 0.12, height: size * 0.1)
                }
            }
        }
        .padding(size * 0.1)
        .background {
            RoundedRectangle(cornerRadius: size * 0.1, style: .continuous)
                .strokeBorder(MetricTheme.textSecondary.opacity(0.45), lineWidth: size * 0.035)
        }
        .frame(width: size, height: size)
    }
}
