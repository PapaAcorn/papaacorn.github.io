import SwiftUI

struct TemperatureGameView: View {
    @ObservedObject var viewModel: TemperatureGameViewModel
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        Group {
            if viewModel.showRoundTip {
                TipInterstitialView(
                    roundNumber: viewModel.pendingRoundAfterTip ?? viewModel.unlockedRound,
                    tipText: viewModel.roundTipText,
                    onContinue: { viewModel.continueFromRoundTip() }
                )
            } else {
                gameContent
            }
        }
        .onReceive(progressStore.$progress) { _ in
            viewModel.objectWillChange.send()
        }
    }

    private var gameContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                statsRow
                questionCard
                learningCard
                resetButton
            }
            .padding(20)
        }
        .background(Color(red: 0.07, green: 0.09, blue: 0.15).ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Metric Sense")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color.blue.opacity(0.75))
                .textCase(.uppercase)
                .kerning(1.3)

            Text("Temperature Trainer")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Build quick intuition for everyday weather from -15°F through 110°F. Approximation within a couple of degrees is the goal.")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(title: "Round", value: "\(viewModel.unlockedRound)")
            statCard(title: "Learned here", value: "\(viewModel.learnedInRoundCount)/\(viewModel.totalInRoundCount)")
            statCard(title: "Total learned", value: "\(viewModel.totalLearnedCount)")
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var questionCard: some View {
        let copy = viewModel.questionCopy
        let question = viewModel.currentQuestion
        let hasFeedback = viewModel.feedback != nil

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(question.card.phrase.uppercased())
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.secondary)
                    Text(copy.prompt)
                        .font(.title2.weight(.black))
                        .foregroundStyle(Color(red: 0.06, green: 0.09, blue: 0.15))
                }
                Spacer()
                Text("\(copy.givenValue)\(copy.givenUnit)")
                    .font(.title3.weight(.black))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.15))
                    .foregroundStyle(Color.blue)
                    .clipShape(Capsule())
            }

            if question.direction.usesSlider {
                VStack(spacing: 16) {
                    Text("\(viewModel.sliderValue)\(copy.answerUnit)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.03, green: 0.35, blue: 0.52))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.cyan.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    ThermometerSliderView(
                        minValue: copy.sliderMin,
                        maxValue: copy.sliderMax,
                        value: $viewModel.sliderValue,
                        unit: "°",
                        isDisabled: hasFeedback
                    )

                    nudgeRow(disabled: hasFeedback)
                }
            } else {
                MultipleChoiceQuestionView(
                    options: viewModel.multipleChoiceOptions,
                    unit: copy.answerUnit,
                    isDisabled: hasFeedback,
                    onSelect: { viewModel.submitMultipleChoice($0) }
                )
            }

            if let feedback = viewModel.feedback {
                feedbackPanel(feedback)
            } else if question.direction.usesSlider {
                Button(action: { viewModel.submitSliderAnswer() }) {
                    Text("Lock in estimate")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    private func nudgeRow(disabled: Bool) -> some View {
        let amounts = [-10, -5, -1, 1, 5, 10]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
            ForEach(amounts, id: \.self) { amount in
                Button {
                    viewModel.nudgeSlider(by: amount)
                } label: {
                    Text(amount > 0 ? "+\(amount)" : "\(amount)")
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(disabled)
            }
        }
    }

    private func feedbackPanel(_ feedback: AnswerFeedback) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(feedback.correct ? "Nice instinct." : "We'll show this again.")
                .font(.headline.weight(.black))

            Text("You chose \(feedback.selected)\(feedback.unit). \(feedback.summary) Within \(feedback.tolerance)\(feedback.unit) counts as close.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(feedback.cardTip)
                .font(.subheadline.weight(.semibold))

            Button(action: { viewModel.continueAfterFeedback() }) {
                Text("Continue")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(feedback.correct ? Color.green : Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(16)
        .background(feedback.correct ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var learningCard: some View {
        let streak = viewModel.currentProgress.streak
        let required = GameConstants.learnedStreakRequired
        let progressFraction = min(1, Double(streak) / Double(required))

        return VStack(alignment: .leading, spacing: 10) {
            Text("How this module teaches")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            Text("Answer correctly \(required) times in a row to learn a card. Missed cards return more often; learned cards from earlier rounds appear occasionally for review.")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.7))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(Color.green)
                        .frame(width: geo.size.width * progressFraction)
                }
            }
            .frame(height: 10)

            Text("Current prompt streak: \(streak)/\(required)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var resetButton: some View {
        Button("Reset practice progress", action: { viewModel.resetProgress() })
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.blue.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

#Preview {
    let store = ProgressStore()
    TemperatureGameView(viewModel: TemperatureGameViewModel(progressStore: store))
        .environmentObject(store)
}
