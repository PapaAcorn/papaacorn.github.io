//
//  TemperatureSliderGeometry.swift
//  Metricize
//

import CoreGraphics

enum TemperatureSliderGeometry {
    static let trackInset: CGFloat = 24

    static func dragBounds(in height: CGFloat) -> ClosedRange<CGFloat> {
        let top = trackInset
        let bottom = max(top, height - trackInset)
        return top...bottom
    }

    static func yPosition(for value: Double, in range: ClosedRange<Double>, height: CGFloat) -> CGFloat {
        let span = max(range.upperBound - range.lowerBound, 1)
        let normalized = (value - range.lowerBound) / span
        let travel = max(height - (trackInset * 2), 1)
        return height - trackInset - CGFloat(normalized) * travel
    }

    static func value(at y: CGFloat, in range: ClosedRange<Double>, height: CGFloat) -> Double {
        let span = max(range.upperBound - range.lowerBound, 1)
        let travel = max(height - (trackInset * 2), 1)
        let clampedY = min(max(y, dragBounds(in: height).lowerBound), dragBounds(in: height).upperBound)
        let normalized = 1 - Double((clampedY - trackInset) / travel)
        let value = range.lowerBound + normalized * span
        return min(max(value, range.lowerBound), range.upperBound)
    }
}
