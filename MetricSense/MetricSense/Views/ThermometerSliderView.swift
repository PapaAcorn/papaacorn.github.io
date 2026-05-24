import SwiftUI

struct ThermometerSliderView: View {
    let minValue: Int
    let maxValue: Int
    @Binding var value: Int
    let unit: String
    let isDisabled: Bool

    private let trackHeight: CGFloat = 280

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(spacing: 6) {
                Text("\(maxValue)\(unit)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(minValue)\(unit)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .frame(height: trackHeight)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.15), Color.orange.opacity(0.35), Color.red.opacity(0.45)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 56, height: trackHeight)
                    .overlay {
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 2)
                    }

                Circle()
                    .fill(Color.red.opacity(0.85))
                    .frame(width: 28, height: 28)
                    .offset(y: -10)

                GeometryReader { geo in
                    let ratio = CGFloat(value - minValue) / CGFloat(max(1, maxValue - minValue))
                    let y = geo.size.height * (1 - ratio)

                    ZStack {
                        Circle()
                            .fill(Color(.label))
                            .frame(width: 52, height: 52)
                            .overlay {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                            .overlay {
                                Text("\(value)")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(.systemBackground))
                            }
                            .position(x: geo.size.width / 2, y: y)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { gesture in
                                        guard !isDisabled else { return }
                                        updateValue(from: gesture.location.y, in: geo.size.height)
                                    }
                            )
                    }
                }
                .frame(width: 80, height: trackHeight)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Drag the marker")
                    .font(.subheadline.weight(.semibold))
                Text("Everyday range: \(minValue)°F to \(maxValue)°F")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func updateValue(from y: CGFloat, in height: CGFloat) {
        let clampedY = min(max(0, y), height)
        let ratio = 1 - (clampedY / height)
        let raw = Double(minValue) + Double(maxValue - minValue) * Double(ratio)
        value = Int(raw.rounded())
    }
}
