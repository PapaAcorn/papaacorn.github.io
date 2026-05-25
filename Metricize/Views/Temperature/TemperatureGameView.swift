//
//  TemperatureGameView.swift
//  Metricize
//

import SwiftUI

struct TemperatureGameView: View {
    @State private var viewModel: TemperatureGameViewModel
    @State private var sliderValue: Double = 50
    @State private var multipleChoiceOptions: [Int] = []
    @State private var preparedCardID: String?
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .overlay(alignment: .bottom) {
            feedbackBanner
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.feedback)
        .onChange(of: viewModel.feedback) { _, feedback in
            switch feedback {
            case .correct:
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
                ThermometerSliderView(
                    celsius: card.celsius,
                    selectedFahrenheit: $sliderValue,
                    isEnabled: !viewModel.isSubmitting
                )
                .id(card.id)

                PrimaryActionButton(
                    title: "Check",
                    isEnabled: !viewModel.isSubmitting
                ) {
                    viewModel.submitSliderAnswer(guess: Int(sliderValue.rounded()), for: card)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

            case .multipleChoice:
                MultipleChoiceChallengeView(
                    celsius: card.celsius,
                    subtitle: card.label,
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
        .onChange(of: card.id, initial: true) { _, _ in
            prepareChallenge(for: card)
        }
    }

    private func prepareChallenge(for card: TemperatureCard) {
        guard preparedCardID != card.id else { return }
        preparedCardID = card.id

        if card.challengeType == .thermometerSlider {
            sliderValue = 50
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
        case .correct:
            FeedbackToast(text: "Close enough!", icon: "checkmark.circle.fill", isSuccess: true)
                .padding(.bottom, 28)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .incorrect(let correctFahrenheit):
            FeedbackToast(
                text: "About \(correctFahrenheit)°F",
                icon: "thermometer.medium",
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

            Text("You can now approximate everyday Celsius temperatures in Fahrenheit — within a couple of degrees, from memory.")
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
