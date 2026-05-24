import Combine
import Foundation

@MainActor
final class TemperatureGameViewModel: ObservableObject {
    @Published private(set) var currentQuestion: TemperatureQuestion
    @Published var sliderValue: Int
    @Published var feedback: AnswerFeedback?
    @Published var showRoundTip = false
    @Published var pendingRoundAfterTip: Int?

    private let progressStore: ProgressStore
    private var previousQuestionKey: String?
    private var completedRoundPendingTip: Int?

    init(progressStore: ProgressStore) {
        self.progressStore = progressStore
        let pool = GameEngine.allQuestions(upToRound: GameEngine.unlockedRound(progress: progressStore.progress))
        let first = GameEngine.chooseQuestion(from: pool, progress: progressStore.progress, excluding: nil)
            ?? TemperatureQuestion(card: TemperatureDeck.cards[0], direction: .celsiusToFahrenheit)
        self.currentQuestion = first
        self.sliderValue = GameEngine.startingSliderValue(for: GameEngine.questionCopy(for: first))
    }

    var unlockedRound: Int {
        GameEngine.unlockedRound(progress: progressStore.progress)
    }

    var activeQuestions: [TemperatureQuestion] {
        GameEngine.allQuestions(upToRound: unlockedRound)
    }

    var questionCopy: QuestionCopy {
        GameEngine.questionCopy(for: currentQuestion)
    }

    var currentProgress: QuestionProgress {
        progressStore.progress(for: currentQuestion.key)
    }

    var learnedInRoundCount: Int {
        GameEngine.questions(forRound: unlockedRound)
            .filter { progressStore.progress(for: $0.key).learned }
            .count
    }

    var totalInRoundCount: Int {
        GameEngine.questions(forRound: unlockedRound).count
    }

    var totalLearnedCount: Int {
        GameEngine.allQuestions(upToRound: TemperatureDeck.maxRound)
            .filter { progressStore.progress(for: $0.key).learned }
            .count
    }

    var multipleChoiceOptions: [Int] {
        GameEngine.multipleChoiceOptions(for: currentQuestion)
    }

    var roundTipText: String {
        let round = pendingRoundAfterTip ?? unlockedRound
        return RoundTips.tip(forRound: round)
    }

    func nudgeSlider(by amount: Int) {
        guard feedback == nil else { return }
        let copy = questionCopy
        sliderValue = min(copy.sliderMax, max(copy.sliderMin, sliderValue + amount))
    }

    func submitSliderAnswer() {
        guard feedback == nil else { return }
        evaluate(selectedValue: sliderValue)
    }

    func submitMultipleChoice(_ value: Int) {
        guard feedback == nil else { return }
        evaluate(selectedValue: value)
    }

    func continueAfterFeedback() {
        guard feedback != nil else { return }
        feedback = nil

        if let finishedRound = completedRoundPendingTip {
            completedRoundPendingTip = nil
            pendingRoundAfterTip = finishedRound + 1
            showRoundTip = true
            return
        }

        advanceToNextQuestion()
    }

    func continueFromRoundTip() {
        showRoundTip = false
        pendingRoundAfterTip = nil
        advanceToNextQuestion()
    }

    func resetProgress() {
        progressStore.reset()
        previousQuestionKey = nil
        feedback = nil
        showRoundTip = false
        pendingRoundAfterTip = nil
        completedRoundPendingTip = nil

        let first = GameEngine.chooseQuestion(
            from: GameEngine.allQuestions(upToRound: 1),
            progress: [:],
            excluding: nil
        ) ?? TemperatureQuestion(card: TemperatureDeck.cards[0], direction: .celsiusToFahrenheit)

        loadQuestion(first)
    }

    private func evaluate(selectedValue: Int) {
        let roundBefore = unlockedRound
        let copy = questionCopy
        let delta = abs(selectedValue - copy.target)
        let correct = delta <= copy.tolerance

        progressStore.recordAnswer(for: currentQuestion.key, correct: correct)

        if GameEngine.unlockedRound(progress: progressStore.progress) > roundBefore {
            completedRoundPendingTip = roundBefore
        }

        feedback = AnswerFeedback(
            correct: correct,
            selected: selectedValue,
            target: copy.target,
            tolerance: copy.tolerance,
            unit: copy.answerUnit,
            summary: copy.correctSummary,
            cardTip: currentQuestion.card.tip
        )
    }

    private func advanceToNextQuestion() {
        guard let next = GameEngine.chooseQuestion(
            from: activeQuestions,
            progress: progressStore.progress,
            excluding: previousQuestionKey
        ) else { return }

        loadQuestion(next)
    }

    private func loadQuestion(_ question: TemperatureQuestion) {
        previousQuestionKey = currentQuestion.key
        currentQuestion = question
        sliderValue = GameEngine.startingSliderValue(for: GameEngine.questionCopy(for: question))
    }
}

struct AnswerFeedback {
    let correct: Bool
    let selected: Int
    let target: Int
    let tolerance: Int
    let unit: String
    let summary: String
    let cardTip: String
}
