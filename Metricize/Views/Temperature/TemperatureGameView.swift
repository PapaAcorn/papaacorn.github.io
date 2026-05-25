//
//  TemperatureGameView.swift
//  Metricize
//

import SwiftUI

struct TemperatureGameView: View {
    @State private var viewModel: TemperatureGameViewModel
    @State private var sliderValueFahrenheit: Double = TemperatureGameConstants.defaultSliderFahrenheit
    @State private var sliderValueCelsius: Double = TemperatureGameConstants.defaultSliderCelsius
    @State private var multipleChoiceOptions: [Int] = []
    @Environment(\.dismiss) private var dismiss

    init(progressStore: TemperatureProgressStore = TemperatureProgressStore()) {
        _viewModel = State(initialValue: TemperatureGameViewModel(progressStore: progressStore))
    }

    private var activeCelsius: Int? {
        if case .playing(let card) = viewModel.phase {
            return card.celsius
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            if !isFullScreenPhase {
                RoundProgressHeader(
                    roundTitle: viewModel.currentRound.title,
                    learned: progressStore.learnedCardCount(in: progressStore.currentRoundIndex),
                    total: viewModel.currentRound.cards.count
                )
            }

            Group {
                switch viewModel.phase {
                case .playing(let card):
                    challengeView(for: card)
                case .showingTip(let roundIndex, let tips):
                    RoundTipView(
                        roundTitle: TemperatureCurriculum.rounds[roundIndex].title,
                        tips: tips,
                        onContinue: viewModel.dismissTipAndContinue
                    )
                case .roundComplete:
                    roundCompletePlaceholder
                case .moduleComplete:
                    moduleCompleteView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .metricScreenBackground(celsius: activeCelsius)
        #if os(iOS)
        .navigationTitle("Learn Inside/Outside")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .overlay(alignment: .bottom) {
            feedbackBanner
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.feedback)
        .onChange(of: viewModel.feedback) { _, feedback in
            switch feedback {
            case .exact, .closeEnough:
                metricHaptic(.success)
            case .incorrect:
                metricHaptic(.warning)
            case .none:
                break
            }
        }
    }

    private var isFullScreenPhase: Bool {
        switch viewModel.phase {
        case .showingTip, .moduleComplete:
            return true
        default:
            return false
        }
    }

    private var progressStore: TemperatureProgressStore {
        viewModel.progressStore
    }

    @ViewBuilder
    private func challengeView(for card: TemperatureCard) -> some View {
        VStack(spacing: 0) {
            LearningStreakView(
                consecutiveCorrect: progressStore.progress(for: card).consecutiveCorrect,
                required: TemperatureGameConstants.requiredConsecutiveCorrect
            )
            .padding(.top, 20)
            .padding(.bottom, 8)

            Spacer(minLength: 0)

            switch card.challengeType {
            case .thermometerSlider:
                sliderChallenge(for: card)
            case .multipleChoice:
                MultipleChoiceChallengeView(
                    card: card,
                    choices: multipleChoiceOptions,
                    isEnabled: !viewModel.isSubmitting,
                    onSelect: { guess in
                        viewModel.submitMultipleChoice(guess: guess, for: card)
                    }
                )
                .id(card.id)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }

            Spacer(minLength: 0)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .id(card.id)
        .onChange(of: card.id) { _, _ in
            prepareChallenge(for: card)
        }
        .onChange(of: viewModel.phase, initial: true) { _, phase in
            if case .playing(let card) = phase {
                prepareChallenge(for: card)
            }
        }
    }

    @ViewBuilder
    private func sliderChallenge(for card: TemperatureCard) -> some View {
        switch card.direction {
        case .celsiusToFahrenheit:
            ThermometerSliderView(
                celsius: card.celsius,
                selectedFahrenheit: $sliderValueFahrenheit,
                isEnabled: !viewModel.isSubmitting
            )
            .id(card.id)

            PrimaryActionButton(
                title: "Check",
                isEnabled: !viewModel.isSubmitting
            ) {
                viewModel.submitSliderAnswer(
                    guess: Int(sliderValueFahrenheit.rounded()),
                    for: card
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)

        case .fahrenheitToCelsius:
            CelsiusSliderView(
                fahrenheit: card.promptValue,
                selectedCelsius: $sliderValueCelsius,
                isEnabled: !viewModel.isSubmitting
            )
            .id(card.id)

            PrimaryActionButton(
                title: "Check",
                isEnabled: !viewModel.isSubmitting
            ) {
                viewModel.submitSliderAnswer(
                    guess: Int(sliderValueCelsius.rounded()),
                    for: card
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private func prepareChallenge(for card: TemperatureCard) {
        switch card.direction {
        case .celsiusToFahrenheit:
            sliderValueFahrenheit = TemperatureGameConstants.defaultSliderFahrenheit
        case .fahrenheitToCelsius:
            sliderValueCelsius = TemperatureGameConstants.defaultSliderCelsius
        }
        if card.challengeType == .multipleChoice {
            multipleChoiceOptions = TemperatureGameViewModel.multipleChoiceOptions(for: card)
        }
    }

    @ViewBuilder
    private var feedbackBanner: some View {
        switch viewModel.feedback {
        case .none:
            EmptyView()
        case .exact:
            FeedbackToast(text: "Exactly Right!", icon: "checkmark.circle.fill", isSuccess: true)
                .padding(.bottom, 28)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .closeEnough(let answer, let unit):
            FeedbackToast(
                text: "Close enough! It's \(AnswerFormatting.degreesPhrase(value: answer, unit: unit))",
                icon: "checkmark.circle.fill",
                isSuccess: true
            )
            .padding(.bottom, 28)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        case .incorrect(let correctAnswer, let unit):
            FeedbackToast(
                text: "Not quite — it's \(AnswerFormatting.degreesPhrase(value: correctAnswer, unit: unit))",
                icon: "xmark.circle.fill",
                isSuccess: false
            )
            .padding(.bottom, 28)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var roundCompletePlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MetricTheme.warmEmber)
            Text("Preparing next round…")
                .font(.subheadline)
                .foregroundStyle(MetricTheme.textSecondary)
        }
        .onAppear {
            viewModel.continueAfterRoundComplete()
        }
    }

    private var moduleCompleteView: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [MetricTheme.warmGlow.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: "seal.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [MetricTheme.warmGlow, MetricTheme.warmEmber],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 28)

            Text("Range Mastered")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(MetricTheme.textPrimary)

            Text("You can now approximate everyday temperatures in both directions — within 3 degrees, from memory.")
                .font(.body)
                .foregroundStyle(MetricTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 36)
                .padding(.top, 12)

            Spacer()

            VStack(spacing: 12) {
                PrimaryActionButton(title: "Done") {
                    dismiss()
                }

                Button("Practice Again") {
                    viewModel.resetModule()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MetricTheme.textTertiary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }
}

#Preview {
    NavigationStack {
        TemperatureGameView()
    }
}
