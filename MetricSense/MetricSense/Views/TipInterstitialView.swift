import SwiftUI

struct TipInterstitialView: View {
    let roundNumber: Int
    let tipText: String
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("Quick temperature sense")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color.blue.opacity(0.8))
                .textCase(.uppercase)
                .kerning(1.2)

            Text("Loading round \(roundNumber)…")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)

            Text(tipText)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.blue.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(action: onContinue) {
                Text("Start next round")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.07, green: 0.09, blue: 0.15))
    }
}
