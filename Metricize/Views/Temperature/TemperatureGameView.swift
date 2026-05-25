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
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.metricPalette) private var palette

    var onResetModule: (() -> Void)?
    var onReviewBasics: (() -> Void)?

    init(
        progressStore: TemperatureProgressStore = TemperatureProgressStore(),
        onResetModule: (() -> Void)? = nil,
        onReviewBasics: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: TemperatureGameViewModel(progressStore: progressStore))
        self.onResetModule = onResetModule
        self.onReviewBasics = onReviewBasics
    }

    private var activeCelsius: Int? {
        if case .playing(let card) = viewModel.phase {
            return card.celsius
        }
        return nil
    }

    private var roundLabel: String {
        let major = progressStore.currentRoundIndex
        let minor = progressStore.currentSubRoundIndex
        let totalMajor = TemperatureCurriculum.rounds.count
        let totalMinor = TemperatureGameConstants.subRoundsPerRound
        return "Round \(TemperatureCurriculum.subRoundLabel(majorRoundIndex: major, subRoundIndex: minor)) of \(totalMajor).\(totalMinor)"
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = ChallengeLayout.current(size: geometry.size) == .sideBySide

            VStack(spacing: 0) {
                if !isFullScreenPhase {
                    RoundProgressHeader(
                        roundLabel: roundLabel,
                        learned: progressStore.learnedCountInCurrentSubRound(),
                        total: progressStore.totalCountInCurrentSubRound(),
                        compact: isLandscape
                    )

                    if !isLandscape {
                        Spacer()
                            .frame(height: 20)
                    }
                }

                Group {
                    switch viewModel.phase {
                    case .playing(let card):
                        challengeView(for: card, isLandscape: isLandscape)
                    case .showingTip(let roundIndex, let tips):
                        RoundTipView(
                            roundTitle: "Round \(roundIndex + 1)",
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
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .metricScreenBackground(celsius: activeCelsius)
        #if os(iOS)
        .navigationTitle("Inside & Out")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #else
        .navigationTitle("Inside & Out")
        #endif
        .toolbar {
            if onReviewBasics != nil {
                ToolbarItem(placement: .automatic) {
                    Button {
                        onReviewBasics?()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.body.weight(.medium))
                            .foregroundStyle(palette.textSecondary)
                    }
                    .accessibilityLabel("Review basics")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button("Reset") {
                    showResetConfirmation = true
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.textSecondary)
            }
        }
        .confirmationDialog(
            "Reset all progress for Inside & Out?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                if let onResetModule {
                    onResetModule()
                } else {
                    viewModel.resetModule()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your learning progress and returns you to the introductory screens.")
        }
        .overlay {
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
    private func challengeView(for card: TemperatureCard, isLandscape: Bool) -> some View {
        GeometryReader { geometry in
            let layout = ChallengeLayout.current(size: geometry.size)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if layout == .stacked {
                        Spacer(minLength: 0)
                    }

                    VStack(spacing: layout == .sideBySide ? 8 : 12) {
                        switch card.challengeType {
                        case .thermometerSlider:
                            sliderChallenge(for: card, layout: layout, compact: isLandscape)
                        case .multipleChoice:
                            MultipleChoiceChallengeView(
                                card: card,
                                choices: multipleChoiceOptions,
                                isEnabled: !viewModel.isSubmitting,
                                onSelect: { guess in
                                    viewModel.submitMultipleChoice(guess: guess, for: card)
                                },
                                layout: layout,
                                compact: isLandscape
                            )
                            .id(card.id)
                            .padding(.horizontal, layout == .sideBySide ? 12 : 20)
                        }
                    }
                    .padding(.vertical, layout == .sideBySide ? 8 : 0)

                    if layout == .stacked {
                        Spacer(minLength: 0)
                    }
                }
                .frame(minHeight: layout == .sideBySide ? geometry.size.height : nil)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
    private func sliderChallenge(for card: TemperatureCard, layout: ChallengeLayout, compact: Bool) -> some View {
        Group {
            switch layout {
            case .stacked:
                stackedSliderChallenge(for: card, layout: layout, compact: compact)
            case .sideBySide:
                sideBySideSliderChallenge(for: card, layout: layout, compact: compact)
            }
        }
    }

    @ViewBuilder
    private func stackedSliderChallenge(for card: TemperatureCard, layout: ChallengeLayout, compact: Bool) -> some View {
        VStack(spacing: compact ? 12 : 20) {
            sliderView(for: card, layout: layout, compact: compact)

            PrimaryActionButton(
                title: "Check",
                isEnabled: !viewModel.isSubmitting,
                compact: compact
            ) {
                submitSliderAnswer(for: card)
            }
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private func sideBySideSliderChallenge(for card: TemperatureCard, layout: ChallengeLayout, compact: Bool) -> some View {
        HStack(alignment: .center, spacing: compact ? 16 : 24) {
            sliderPrompt(for: card, compact: compact)
                .frame(maxWidth: .infinity)

            VStack(spacing: compact ? 10 : 20) {
                sliderView(for: card, layout: .sideBySide, compact: compact)

                PrimaryActionButton(
                    title: "Check",
                    isEnabled: !viewModel.isSubmitting,
                    compact: true
                ) {
                    submitSliderAnswer(for: card)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, compact ? 12 : 20)
    }

    @ViewBuilder
    private func sliderPrompt(for card: TemperatureCard, compact: Bool = false) -> some View {
        switch card.direction {
        case .celsiusToFahrenheit:
            TemperaturePromptView(
                value: card.celsius,
                unit: "°C",
                caption: card.label,
                hint: "Drag the marker on the Fahrenheit scale",
                compact: compact
            )
        case .fahrenheitToCelsius:
            TemperaturePromptView(
                value: card.promptValue,
                unit: "°F",
                caption: card.label,
                hint: "Drag the marker on the Celsius scale",
                compact: compact
            )
        }
    }

    @ViewBuilder
    private func sliderView(for card: TemperatureCard, layout: ChallengeLayout, compact: Bool) -> some View {
        switch card.direction {
        case .celsiusToFahrenheit:
            ThermometerSliderView(
                celsius: card.celsius,
                label: card.label,
                selectedFahrenheit: $sliderValueFahrenheit,
                isEnabled: !viewModel.isSubmitting,
                layout: layout,
                compact: compact
            )
            .id(card.id)
        case .fahrenheitToCelsius:
            CelsiusSliderView(
                fahrenheit: card.promptValue,
                label: card.label,
                selectedCelsius: $sliderValueCelsius,
                isEnabled: !viewModel.isSubmitting,
                layout: layout,
                compact: compact
            )
            .id(card.id)
        }
    }

    private func submitSliderAnswer(for card: TemperatureCard) {
        switch card.direction {
        case .celsiusToFahrenheit:
            viewModel.submitSliderAnswer(
                guess: Int(sliderValueFahrenheit.rounded()),
                for: card
            )
        case .fahrenheitToCelsius:
            viewModel.submitSliderAnswer(
                guess: Int(sliderValueCelsius.rounded()),
                for: card
            )
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
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        case .closeEnough(let answer, let unit):
            FeedbackToast(
                text: "Close enough! It's \(AnswerFormatting.degreesPhrase(value: answer, unit: unit))",
                icon: "checkmark.circle.fill",
                isSuccess: true
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        case .incorrect(let correctAnswer, let unit):
            FeedbackToast(
                text: "Not quite — it's \(AnswerFormatting.degreesPhrase(value: correctAnswer, unit: unit))",
                icon: "xmark.circle.fill",
                isSuccess: false
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var roundCompletePlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MetricTheme.warmEmber)
            Text("Preparing next round…")
                .font(.subheadline)
                .foregroundStyle(palette.textSecondary)
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
                .foregroundStyle(palette.textPrimary)

            Text("You can now approximate everyday temperatures in both directions — within 3°, from memory.")
                .font(.body)
                .foregroundStyle(palette.textSecondary)
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
                .foregroundStyle(palette.textTertiary)
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
