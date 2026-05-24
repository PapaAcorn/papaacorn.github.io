import SwiftUI

struct MultipleChoiceQuestionView: View {
    let options: [Int]
    let unit: String
    let isDisabled: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack {
                        Text("\(option)\(unit)")
                            .font(.title2.weight(.bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
            }
        }
    }
}
