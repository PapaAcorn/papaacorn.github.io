//
//  MetricUnitsGameView.swift
//  Metricize
//

import SwiftUI

struct MetricUnitsGameView: View {
    @State private var viewModel: MetricUnitsGameViewModel
    @State private var choiceOrder: [Int] = []
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.metricPalette) private var palette

    var onResetModule: (() -> Void)?
    var onReviewIntro: (() -> Void)?

    init(
        progressStore: MetricUnitsProgressStore,
        onResetModule: (() -> Void)? = nil,
        onReviewIntro: (() -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: MetricUnitsGameViewModel(progressStore: progressStore)
        )
        self.onResetModule = onResetModule
        self.onReviewIntro = onReviewIntro
    }

    private var progressStore: MetricUnitsProgressStore {
        viewModel.progressStore
    }

    private var roundLabel: String {
        "Round \(MetricUnitsCurriculum.subRoundLabel(majorRoundIndex: 0, subRoundIndex: progressStore.currentSubRoundIndex))"
    }

    var body: some View {
        VStack(spacing: 0) {
            if !isFullScreenPhase {
                MetricUnitsLearningPathView(
                    progressStore: progressStore,
                    onRedoCompletedSubRound: { subRoundIndex in
                        viewModel.redoSubRound(subRoundIndex: subRoundIndex)
                    }
                )
                .padding(.top, 8)

                RoundProgressHeader(
                    roundLabel: roundLabel,
                    learned: progressStore.learnedCountInCurrentSubRound(),
                    total: progressStore.totalCountInCurrentSubRound(),
                    compact: false
                )
                .padding(.top, 8)

                Spacer()
                    .frame(height: 12)
            }

            Group {
                switch viewModel.phase {
                case .playing(let card):
                    ScrollView(.vertical, showsIndicators: false) {
                        MetricUnitsChallengeView(
                            card: card,
                            choiceOrder: choiceOrder,
                            isEnabled: !viewModel.isSubmitting,
                            onSelect: { index in
                                viewModel.submitAnswer(selectedIndex: index, for: card)
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                case .showingTip(let tips):
                    RoundTipView(
                        roundTitle: "Round 1: Metric Units & Prefixes",
                        tips: tips,
                        onContinue: viewModel.dismissTipAndContinue
                    )
                case .showingSubRoundReview(_, let items):
                    ConversionReviewView(
                        items: items,
                        onContinue: viewModel.dismissSubRoundReviewAndContinue
                    )
                case .moduleComplete:
                    moduleCompleteView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .metricScreenBackground()
        .navigationTitle("Intro to the Metric Units")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .toolbar {
            if onReviewIntro != nil {
                ToolbarItem(placement: .automatic) {
                    Button {
                        onReviewIntro?()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.body.weight(.medium))
                            .foregroundStyle(palette.textSecondary)
                    }
                    .accessibilityLabel("Review intro")
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
            "Reset progress for this primer?",
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
        }
        .overlay {
            feedbackBanner
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.feedback)
        .onChange(of: viewModel.phase) { _, phase in
            if case .playing(let card) = phase {
                choiceOrder = viewModel.choiceOrder(for: card)
            }
        }
        .onAppear {
            if case .playing(let card) = viewModel.phase {
                choiceOrder = viewModel.choiceOrder(for: card)
            }
        }
    }

    private var isFullScreenPhase: Bool {
        switch viewModel.phase {
        case .showingTip, .showingSubRoundReview, .moduleComplete:
            return true
        default:
            return false
        }
    }

    @ViewBuilder
    private var feedbackBanner: some View {
        switch viewModel.feedback {
        case .none:
            EmptyView()
        case .exact:
            FeedbackToast(text: "Correct!", icon: "checkmark.circle.fill", isSuccess: true)
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        case .closeEnough:
            EmptyView()
        case .incorrect(_, let unit):
            FeedbackToast(
                text: "Not quite — it's \(unit)",
                icon: "xmark.circle.fill",
                isSuccess: false
            )
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var moduleCompleteView: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(MetricTheme.warmEmber)
                .padding(.bottom, 28)

            Text("Primer Complete")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(palette.textPrimary)

            Text("You've practiced the core metric units and prefixes. You can revisit this any time from Start Here.")
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
