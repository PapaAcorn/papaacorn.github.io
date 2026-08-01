//
//  HereToThereGameView.swift
//  Metricize
//

import SwiftUI

struct HereToThereGameView: View {
    @State private var viewModel: HereToThereGameViewModel
    @State private var multipleChoiceOptions: [Int] = []
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.metricPalette) private var palette

    var onResetModule: (() -> Void)?
    var onReviewBasics: (() -> Void)?

    init(
        progressStore: HereToThereProgressStore,
        settings: AppSettingsStore,
        onResetModule: (() -> Void)? = nil,
        onReviewBasics: (() -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: HereToThereGameViewModel(progressStore: progressStore, settings: settings)
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
        return "Round \(HereToThereCurriculum.subRoundLabel(majorRoundIndex: major, subRoundIndex: minor))"
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
                        HereToThereFinalExamResultView(
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
        .navigationTitle("Here to There")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #else
        .navigationTitle("Here to There")
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
            "Reset all progress for Here to There?",
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
                HereToThereLearningPathView(
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
            HereToThereLearningPathView(
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
        return "Round \(roundIndex + 1): \(HereToThereCurriculum.roundTitle(for: roundIndex))"
    }

    private var progressStore: HereToThereProgressStore {
        viewModel.progressStore
    }

    @ViewBuilder
    private func challengeView(for card: HereToThereCard, isLandscape: Bool) -> some View {
        GeometryReader { geometry in
            let layout = ChallengeLayout.current(size: geometry.size)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if layout == .stacked {
                        Spacer(minLength: 0)
                    }

                    HereToThereMultipleChoiceChallengeView(
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

    private func prepareChallenge(for card: HereToThereCard) {
        multipleChoiceOptions = viewModel.multipleChoiceOptions(for: card)
    }

    @ViewBuilder
    private var feedbackBanner: some View {
        switch viewModel.feedback {
        case .none:
            EmptyView()
        case .exact:
            FeedbackToast(
                text: "Exactly Right!",
                icon: "checkmark.circle.fill",
                isSuccess: true
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        case .incorrect(_, let card):
            FeedbackToast(
                text: "Not quite — it's ≈ \(card.answerLabel)",
                icon: "xmark.circle.fill",
                isSuccess: false
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var roundCompletePlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MetricTheme.coolFrost)
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
                            colors: [MetricTheme.coolFrost.opacity(0.35), .clear],
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
                            colors: [MetricTheme.coolFrost, MetricTheme.coolFrost.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 28)

            Text("Ready to Go")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(palette.textPrimary)

            Text("You've passed the final exam and built practical mental reference points for lengths, room sizes, and building materials you'll see in metric countries.")
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
        HereToThereGameView(
            progressStore: HereToThereProgressStore(),
            settings: AppSettingsStore()
        )
    }
    .environment(AppSettingsStore())
}
