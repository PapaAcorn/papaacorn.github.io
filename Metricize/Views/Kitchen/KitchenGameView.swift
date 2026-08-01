//
//  KitchenGameView.swift
//  Metricize
//

import SwiftUI

struct KitchenGameView: View {
    @State private var viewModel: KitchenGameViewModel
    @State private var sliderValue: Double = KitchenGameConstants.defaultSliderMilliliters
    @State private var sliderValueFahrenheit: Double = TemperatureGameConstants.defaultSliderFahrenheit
    @State private var sliderValueCelsius: Double = TemperatureGameConstants.defaultSliderCelsius
    @State private var multipleChoiceOptions: [Int] = []
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.metricPalette) private var palette

    var onResetModule: (() -> Void)?
    var onReviewBasics: (() -> Void)?

    init(
        progressStore: KitchenProgressStore,
        settings: AppSettingsStore,
        onResetModule: (() -> Void)? = nil,
        onReviewBasics: (() -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: KitchenGameViewModel(progressStore: progressStore, settings: settings)
        )
        self.onResetModule = onResetModule
        self.onReviewBasics = onReviewBasics
    }

    private var roundLabel: String {
        if progressStore.isFinalExamRound(progressStore.currentRoundIndex) {
            if let session = progressStore.finalExamSession, !session.isComplete {
                let current = min(session.currentQuestionIndex + 1, session.totalQuestions)
                return "Final Exam · Question \(current) of \(session.totalQuestions)"
            }
            return "Final Exam"
        }
        let major = progressStore.currentRoundIndex
        let minor = progressStore.currentSubRoundIndex
        return "Round \(KitchenCurriculum.subRoundLabel(majorRoundIndex: major, subRoundIndex: minor))"
    }

    var body: some View {
        GeometryReader { geometry in
            let challengeLayout = ChallengeLayout.current(size: geometry.size)
            let isPhoneLandscape = verticalSizeClass == .compact && challengeLayout == .sideBySide

            VStack(spacing: 0) {
                if !isFullScreenPhase {
                    progressChrome(isPhoneLandscape: isPhoneLandscape)

                    if !isPhoneLandscape {
                        Spacer()
                            .frame(height: 12)
                    }
                }

                Group {
                    switch viewModel.phase {
                    case .playing(let card):
                        challengeView(for: card, isLandscape: isPhoneLandscape)
                    case .showingTip(let roundIndex, let tips):
                        RoundTipView(
                            roundTitle: tipTitle(for: roundIndex),
                            tips: tips,
                            onContinue: viewModel.dismissTipAndContinue
                        )
                    case .showingBatchReview(_, _, let items):
                        ConversionReviewView(
                            items: items,
                            onContinue: viewModel.dismissBatchReviewAndContinue
                        )
                    case .finalExamResult(let passed, let correct, let total):
                        KitchenFinalExamResultView(
                            passed: passed,
                            correct: correct,
                            total: total,
                            onContinue: viewModel.acknowledgeExamPass,
                            onRetry: viewModel.retryFinalExam,
                            onReviewLearning: viewModel.reviewEarlierRoundsAfterExam
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
        .metricScreenBackground()
        #if os(iOS)
        .navigationTitle("In the Kitchen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #else
        .navigationTitle("In the Kitchen")
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
            "Reset all progress for In the Kitchen?",
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
    }

    @ViewBuilder
    private func progressChrome(isPhoneLandscape: Bool) -> some View {
        let pathStyle: LearningPathStyle = isPhoneLandscape ? .compact : .standard
        let isExam = progressStore.isActiveFinalExamSession
        let header = RoundProgressHeader(
            roundLabel: roundLabel,
            learned: progressStore.learnedCountInCurrentSubRound(),
            total: progressStore.totalCountInCurrentSubRound(),
            metricLabel: isExam ? "Correct" : "Learned",
            remainingCount: isExam ? progressStore.examRemainingCount() : nil,
            compact: isPhoneLandscape
        )

        if isPhoneLandscape {
            HStack(alignment: .center, spacing: 10) {
                KitchenLearningPathView(
                    progressStore: progressStore,
                    style: pathStyle,
                    onRedoCompletedSubRound: { roundIndex, subRoundIndex in
                        viewModel.redoSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
                    },
                    onRedoFinalExam: {
                        viewModel.redoFinalExam()
                    }
                )
                    .frame(maxWidth: .infinity, alignment: .leading)

                header
                    .frame(maxWidth: 220)
            }
            .padding(.horizontal, 8)
            .padding(.top, 2)
        } else {
            KitchenLearningPathView(
                progressStore: progressStore,
                style: pathStyle,
                onRedoCompletedSubRound: { roundIndex, subRoundIndex in
                    viewModel.redoSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
                },
                onRedoFinalExam: {
                    viewModel.redoFinalExam()
                }
            )
                .padding(.top, 8)

            header
        }
    }

    private var isFullScreenPhase: Bool {
        switch viewModel.phase {
        case .showingTip, .showingBatchReview, .finalExamResult, .moduleComplete:
            return true
        default:
            return false
        }
    }

    private func tipTitle(for roundIndex: Int) -> String {
        if progressStore.isFinalExamRound(roundIndex) {
            return "Final Exam"
        }
        return "Round \(roundIndex + 1): \(KitchenCurriculum.roundTitle(for: roundIndex))"
    }

    private var progressStore: KitchenProgressStore {
        viewModel.progressStore
    }

    @ViewBuilder
    private func challengeView(for card: KitchenCard, isLandscape: Bool) -> some View {
        GeometryReader { geometry in
            let layout = ChallengeLayout.current(size: geometry.size)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if layout == .stacked {
                        Spacer(minLength: 0)
                    }

                    VStack(spacing: layout == .sideBySide ? 8 : 12) {
                        switch card.challengeType {
                        case .measurementSlider:
                            sliderChallenge(for: card, layout: layout, compact: isLandscape)
                        case .multipleChoice:
                            KitchenMultipleChoiceChallengeView(
                                card: card,
                                choices: multipleChoiceOptions,
                                choiceLabels: viewModel.activeChoiceLabels,
                                isEnabled: !viewModel.isSubmitting,
                                onSelect: { guess in
                                    viewModel.submitMultipleChoice(guess: guess, for: card)
                                },
                                layout: layout,
                                compact: isLandscape
                            )
                            .id(card.id)
                            .padding(.horizontal, layout == .sideBySide ? 12 : 20)
                        case .booleanChoice:
                            KitchenBooleanChoiceView(
                                card: card,
                                isEnabled: !viewModel.isSubmitting,
                                onSelect: { isYes in
                                    viewModel.submitBooleanChoice(isYes: isYes, for: card)
                                },
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
            .scrollDismissesKeyboard(.never)
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
    private func sliderChallenge(for card: KitchenCard, layout: ChallengeLayout, compact: Bool) -> some View {
        if card.usesTemperatureSlider {
            temperatureSliderChallenge(for: card, layout: layout, compact: compact)
        } else {
            measurementSliderChallenge(for: card, layout: layout, compact: compact)
        }
    }

    @ViewBuilder
    private func measurementSliderChallenge(for card: KitchenCard, layout: ChallengeLayout, compact: Bool) -> some View {
        Group {
            switch layout {
            case .stacked:
                VStack(spacing: compact ? 16 : 32) {
                    KitchenMeasurementSliderView(
                        card: card,
                        selectedValue: $sliderValue,
                        isEnabled: !viewModel.isSubmitting,
                        layout: layout,
                        compact: compact
                    )
                    .id(card.id)

                    PrimaryActionButton(
                        title: "Check",
                        isEnabled: !viewModel.isSubmitting,
                        compact: compact
                    ) {
                        viewModel.submitSliderAnswer(
                            guess: Int(sliderValue.rounded()),
                            for: card
                        )
                    }
                    .padding(.horizontal, 24)
                }
            case .sideBySide:
                HStack(alignment: .center, spacing: compact ? 16 : 24) {
                    KitchenPromptView(card: card, compact: compact)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: compact ? 14 : 28) {
                        KitchenMeasurementSliderView(
                            card: card,
                            selectedValue: $sliderValue,
                            isEnabled: !viewModel.isSubmitting,
                            layout: .sideBySide,
                            compact: compact
                        )
                        .id(card.id)

                        PrimaryActionButton(
                            title: "Check",
                            isEnabled: !viewModel.isSubmitting,
                            compact: true
                        ) {
                            viewModel.submitSliderAnswer(
                                guess: Int(sliderValue.rounded()),
                                for: card
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, compact ? 12 : 20)
            }
        }
    }

    @ViewBuilder
    private func temperatureSliderChallenge(for card: KitchenCard, layout: ChallengeLayout, compact: Bool) -> some View {
        Group {
            switch layout {
            case .stacked:
                VStack(spacing: compact ? 16 : 32) {
                    temperatureSliderView(for: card, layout: layout, compact: compact)

                    PrimaryActionButton(
                        title: "Check",
                        isEnabled: !viewModel.isSubmitting,
                        compact: compact
                    ) {
                        submitTemperatureSliderAnswer(for: card)
                    }
                    .padding(.horizontal, 24)
                }
            case .sideBySide:
                HStack(alignment: .center, spacing: compact ? 16 : 24) {
                    KitchenPromptView(card: card, compact: compact)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: compact ? 14 : 28) {
                        temperatureSliderView(for: card, layout: .sideBySide, compact: compact)

                        PrimaryActionButton(
                            title: "Check",
                            isEnabled: !viewModel.isSubmitting,
                            compact: true
                        ) {
                            submitTemperatureSliderAnswer(for: card)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, compact ? 12 : 20)
            }
        }
    }

    @ViewBuilder
    private func temperatureSliderView(for card: KitchenCard, layout: ChallengeLayout, compact: Bool) -> some View {
        switch card.direction {
        case .imperialToMetric:
            CelsiusSliderView(
                fahrenheit: card.promptValue ?? card.correctAnswer,
                label: nil,
                selectedCelsius: $sliderValueCelsius,
                isEnabled: !viewModel.isSubmitting,
                layout: layout,
                compact: compact,
                showsAccuracyToleranceNote: false,
                showsStepButtons: true
            )
            .id(card.id)
        case .metricToImperial:
            ThermometerSliderView(
                celsius: card.promptValue ?? card.correctAnswer,
                label: nil,
                selectedFahrenheit: $sliderValueFahrenheit,
                isEnabled: !viewModel.isSubmitting,
                layout: layout,
                compact: compact,
                showsAccuracyToleranceNote: false,
                showsStepButtons: true
            )
            .id(card.id)
        }
    }

    private func submitTemperatureSliderAnswer(for card: KitchenCard) {
        switch card.direction {
        case .imperialToMetric:
            viewModel.submitSliderAnswer(
                guess: Int(sliderValueCelsius.rounded()),
                for: card
            )
        case .metricToImperial:
            viewModel.submitSliderAnswer(
                guess: Int(sliderValueFahrenheit.rounded()),
                for: card
            )
        }
    }

    private func prepareChallenge(for card: KitchenCard) {
        sliderValue = defaultSliderValue(for: card)
        if card.usesTemperatureSlider {
            switch card.direction {
            case .imperialToMetric:
                sliderValueCelsius = KitchenConversion.neutralSliderDefault(for: card)
            case .metricToImperial:
                sliderValueFahrenheit = KitchenConversion.neutralSliderDefault(for: card)
            }
        }

        if card.challengeType == .multipleChoice || card.challengeType == .booleanChoice {
            multipleChoiceOptions = viewModel.multipleChoiceOptions(for: card)
        }
    }

    private func defaultSliderValue(for card: KitchenCard) -> Double {
        KitchenConversion.neutralSliderDefault(for: card)
    }

    @ViewBuilder
    private var feedbackBanner: some View {
        switch viewModel.feedback {
        case .none:
            EmptyView()
        case .exact(_, _, let card):
            FeedbackToast(
                text: feedbackText(for: card, exact: true),
                icon: "checkmark.circle.fill",
                isSuccess: true
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        case .closeEnough(let answer, let unit, let card):
            FeedbackToast(
                text: "Correct! It's \(formattedAnswer(answer, unit: unit, card: card))",
                icon: "checkmark.circle.fill",
                isSuccess: true
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        case .incorrect(let correctAnswer, let unit, let card):
            FeedbackToast(
                text: "Not quite — it's \(formattedAnswer(correctAnswer, unit: unit, card: card))",
                icon: "xmark.circle.fill",
                isSuccess: false
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private func feedbackText(for card: KitchenCard, exact: Bool) -> String {
        if card.kind == .booleanComparison {
            return exact ? "Exactly Right!" : ""
        }
        return "Exactly Right!"
    }

    private func formattedAnswer(_ value: Int, unit: String, card: KitchenCard) -> String {
        if let labels = viewModel.activeChoiceLabels, labels.indices.contains(value) {
            return labels[value]
        }
        return KitchenFormatting.displayAnswer(for: card, value: value)
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

            Text("Kitchen Mastered")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(palette.textPrimary)

            Text("You've passed the final exam and know the kitchen measurement, oven, and food-safety anchors from what you've learned.")
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
        KitchenGameView(
            progressStore: KitchenProgressStore(),
            settings: AppSettingsStore()
        )
    }
    .environment(AppSettingsStore())
}
