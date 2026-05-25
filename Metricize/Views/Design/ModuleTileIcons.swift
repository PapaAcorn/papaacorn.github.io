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

    fileprivate var tilePlacement: ModuleTileIconPlacement {
        switch self {
        case .kitchen:
            ModuleTileIconPlacement(scale: 0.74, yOffset: 0.14)
        case .hereToThere:
            ModuleTileIconPlacement(scale: 0.8, yOffset: 0.1)
        case .calculator:
            ModuleTileIconPlacement(scale: 0.76, yOffset: 0.1)
        case .gym:
            ModuleTileIconPlacement(scale: 0.86, yOffset: 0.04)
        case .insideAndOut, .onTheRoad:
            ModuleTileIconPlacement(scale: 1, yOffset: 0)
        }
    }
}

private struct ModuleTileIconPlacement {
    let scale: CGFloat
    let yOffset: CGFloat
}

struct ModuleTileIconView: View {
    let kind: ModuleTileIconKind
    var size: CGFloat = 100

    var body: some View {
        icon
            .scaleEffect(kind.tilePlacement.scale)
            .offset(y: size * kind.tilePlacement.yOffset)
            .frame(width: size, height: size)
    }

    @ViewBuilder
    private var icon: some View {
        switch kind {
        case .insideAndOut:
            InsideAndOutIcon(size: size)
        case .kitchen:
            KitchenCakeIcon(size: size)
        case .gym:
            DumbbellIcon(size: size)
        case .onTheRoad:
            CarIcon(size: size)
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
        HStack(spacing: 0) {
            Image(systemName: "snowflake")
                .font(.system(size: size * 0.34, weight: .light))
                .foregroundStyle(MetricTheme.coolDeep)
                .frame(width: size * 0.5, height: size)

            Image(systemName: "sun.max.fill")
                .font(.system(size: size * 0.32, weight: .light))
                .foregroundStyle(MetricTheme.warmEmber)
                .frame(width: size * 0.5, height: size)
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
                .fill(MetricTheme.warmEmber)
                .frame(width: size * 0.72, height: size * 0.2)
                .overlay(alignment: .top) {
                    wavyFrosting(width: size * 0.72)
                        .offset(y: -size * 0.035)
                }

            RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
                .fill(Color(red: 0.85, green: 0.55, blue: 0.35))
                .frame(width: size * 0.54, height: size * 0.16)
                .offset(y: -size * 0.17)
                .overlay(alignment: .top) {
                    wavyFrosting(width: size * 0.54)
                        .offset(y: -size * 0.03)
                }

            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(MetricTheme.warmGlow)
                .frame(width: size * 0.34, height: size * 0.12)
                .offset(y: -size * 0.3)

            RoundedRectangle(cornerRadius: size * 0.01, style: .continuous)
                .fill(MetricTheme.coolDeep)
                .frame(width: size * 0.035, height: size * 0.1)
                .offset(y: -size * 0.4)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [MetricTheme.warmGlow, MetricTheme.warmEmber],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: size * 0.06, height: size * 0.07)
                .offset(y: -size * 0.48)
        }
        .frame(width: size, height: size)
    }

    private func wavyFrosting(width: CGFloat) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.85))
            .frame(width: width, height: width * 0.1)
    }
}

// MARK: - Dumbbell

private struct DumbbellIcon: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: size * 0.04) {
            weightPlate
            Capsule()
                .fill(MetricTheme.coolDeep)
                .frame(width: size * 0.34, height: size * 0.07)
            weightPlate
        }
        .frame(width: size, height: size)
    }

    private var weightPlate: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.03, style: .continuous)
                .fill(MetricTheme.coolDeep)
                .frame(width: size * 0.18, height: size * 0.48)
            RoundedRectangle(cornerRadius: size * 0.025, style: .continuous)
                .fill(MetricTheme.warmEmber)
                .frame(width: size * 0.12, height: size * 0.38)
        }
    }
}

// MARK: - Car

private struct CarIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                .fill(MetricTheme.coolDeep)
                .frame(width: size * 0.72, height: size * 0.28)
                .offset(y: size * 0.06)

            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(MetricTheme.coolFrost)
                .frame(width: size * 0.38, height: size * 0.2)
                .offset(x: -size * 0.04, y: -size * 0.1)

            HStack(spacing: size * 0.28) {
                wheel
                wheel
            }
            .offset(y: size * 0.2)

            Circle()
                .fill(MetricTheme.warmGlow)
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: size * 0.3, y: size * 0.04)
        }
        .frame(width: size, height: size)
    }

    private var wheel: some View {
        Circle()
            .fill(Color.primary.opacity(0.75))
            .frame(width: size * 0.14, height: size * 0.14)
            .overlay {
                Circle()
                    .fill(Color.primary.opacity(0.35))
                    .frame(width: size * 0.06, height: size * 0.06)
            }
    }
}

// MARK: - Ruler

private struct RulerIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
                .fill(MetricTheme.warmGlow)
                .frame(width: size * 0.76, height: size * 0.24)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
                        .strokeBorder(MetricTheme.warmEmber, lineWidth: size * 0.025)
                }
                .shadow(color: MetricTheme.warmEmber.opacity(0.25), radius: size * 0.04)

            HStack(spacing: size * 0.06) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(MetricTheme.coolDeep)
                        .frame(
                            width: size * 0.026,
                            height: index.isMultiple(of: 2) ? size * 0.14 : size * 0.08
                        )
                }
            }
        }
        .rotationEffect(.degrees(-25))
        .frame(width: size, height: size)
    }
}

// MARK: - Calculator

private struct CalculatorIcon: View {
    let size: CGFloat

    private var bodyWidth: CGFloat { size * 0.52 }
    private var bodyHeight: CGFloat { size * 0.72 }

    var body: some View {
        VStack(spacing: size * 0.045) {
            RoundedRectangle(cornerRadius: size * 0.025, style: .continuous)
                .fill(MetricTheme.coolFrost)
                .frame(width: bodyWidth * 0.88, height: bodyHeight * 0.18)
                .overlay(alignment: .trailing) {
                    Text("123")
                        .font(.system(size: size * 0.065, weight: .bold, design: .rounded))
                        .foregroundStyle(MetricTheme.coolDeep)
                        .padding(.trailing, size * 0.04)
                }

            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(bodyWidth * 0.24), spacing: size * 0.035), count: 3),
                spacing: size * 0.035
            ) {
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: size * 0.02, style: .continuous)
                        .fill(index == 5 ? MetricTheme.warmEmber : MetricTheme.coolDeep.opacity(0.85))
                        .frame(width: bodyWidth * 0.24, height: bodyHeight * 0.12)
                }
            }
        }
        .padding(.horizontal, size * 0.06)
        .padding(.vertical, size * 0.07)
        .frame(width: bodyWidth, height: bodyHeight)
        .background {
            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(MetricTheme.coolDeep.opacity(0.15))
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                        .strokeBorder(MetricTheme.coolDeep, lineWidth: size * 0.03)
                }
        }
        .frame(width: size, height: size)
    }
}
